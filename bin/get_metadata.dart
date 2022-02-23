import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const allPackagesUri = 'https://pub.dev/api/package-names';
const packageUri = 'https://pub.dev/api/packages';

Future<List<String>> getPackages(http.Client client) async {
  final uri = Uri.parse(allPackagesUri);
  final response = await client.get(uri);
  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    return List<String>.from(body['packages'] as List);
  } else {
    throw HttpException('Failed to download Uri', uri: uri);
  }
}

Future<String> getPackageMetadata(
    http.Client client, String packageName) async {
  final uri = Uri.parse('$packageUri/$packageName');
  final response = await client.get(uri);
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw HttpException('Failed to download Uri', uri: uri);
  }
}

void main() async {
  final httpClient = http.Client();
  final packages = await getPackages(httpClient);

  for (final packageName in packages) {
    final packageJson = await getPackageMetadata(httpClient, packageName);
    print('Writing $packageName.json');
    File('data/$packageName.json').writeAsStringSync(packageJson);
  }
  httpClient.close();
}
