// Tiny mock backend for local demos. No dependencies.
//
//   dart run tools/mock_server/server.dart [port]
//
// Serves GET /app-config from config.json next to this file. The file is
// re-read on every request, so edit it and pull to refresh in the app.
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? int.parse(args.first) : 8080;
  final config = File.fromUri(Platform.script.resolve('config.json'));
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  stdout.writeln('Mock server on http://localhost:$port/app-config');

  await for (final request in server) {
    final response = request.response;
    if (request.method == 'GET' && request.uri.path == '/app-config') {
      final body = await config.readAsString();
      jsonDecode(body); // fail loudly on a typo instead of serving bad JSON
      response.headers.contentType = ContentType.json;
      response.write(body);
    } else {
      response.statusCode = HttpStatus.notFound;
    }
    stdout.writeln('${request.method} ${request.uri} ${response.statusCode}');
    await response.close();
  }
}
