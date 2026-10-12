import 'package:http/http.dart' as http;

/// HTTP client for the public config endpoints.
///
/// It sends no credentials, so no token ships in the binary.
class AppConfigApi {
  AppConfigApi({
    required http.Client client,
    required this.baseUrl,
    this.timeout = const Duration(seconds: 5),
  }) : _client = client;

  final http.Client _client;

  /// Without a trailing slash.
  final String baseUrl;
  final Duration timeout;

  /// Raw body of GET /app-config. Throws on network errors, timeouts and
  /// non-200 responses.
  Future<String> fetchAppConfig() async {
    final response = await _client
        .get(Uri.parse('$baseUrl/app-config'))
        .timeout(timeout);
    if (response.statusCode != 200) {
      throw AppConfigApiException(response.statusCode);
    }
    return response.body;
  }

  String customIconUrl(String sha) =>
      '$baseUrl/brand/icon.png?v=${Uri.encodeQueryComponent(sha)}';
}

class AppConfigApiException implements Exception {
  const AppConfigApiException(this.statusCode);

  final int statusCode;

  @override
  String toString() => 'AppConfigApiException: HTTP $statusCode';
}
