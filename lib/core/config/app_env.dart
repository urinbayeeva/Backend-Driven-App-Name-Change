import 'distribution.dart';

/// Build-time configuration from `--dart-define` / `--dart-define-from-file`
/// (see env/example.json). Read once in main.dart and injected from there,
/// so no other file calls `String.fromEnvironment`.
///
/// SECURITY: every value here is compiled into the app binary and can be
/// extracted from a released APK or IPA. Only public settings belong here.
/// Credentials such as CI tokens stay on the CI machine and are never passed
/// to the app.
class AppEnv {
  const AppEnv({
    this.apiUrl = '',
    this.appStoreUrl = '',
    this.distribution = Distribution.store,
    this.primaryBrand = _defaultBrand,
    this.primaryIcon = _defaultIcon,
    this.bakedCustomName = '',
    this.bakedCustomIconSha = '',
    this.configPollSeconds = 0,
  });

  const AppEnv.fromEnvironment()
    : apiUrl = const String.fromEnvironment('API_URL'),
      appStoreUrl = const String.fromEnvironment('APP_STORE_URL'),
      distribution = const String.fromEnvironment('DISTRIBUTION') == 'direct'
          ? Distribution.direct
          : Distribution.store,
      primaryBrand = const String.fromEnvironment(
        'PRIMARY_BRAND',
        defaultValue: _defaultBrand,
      ),
      primaryIcon = const String.fromEnvironment(
        'PRIMARY_ICON',
        defaultValue: _defaultIcon,
      ),
      bakedCustomName = const String.fromEnvironment('CUSTOM_NAME'),
      bakedCustomIconSha = const String.fromEnvironment('CUSTOM_ICON_SHA'),
      configPollSeconds = const int.fromEnvironment('CONFIG_POLL_SECONDS');

  static const _defaultBrand = 'aurora';
  static const _defaultIcon = 'rocket';

  /// Base URL of the config backend; empty means "not configured".
  final String apiUrl;

  /// App Store page for the iOS update banner; empty disables the button.
  final String appStoreUrl;

  final Distribution distribution;

  /// Primary pair baked into this build (PRIMARY_BRAND / PRIMARY_ICON).
  final String primaryBrand;
  final String primaryIcon;

  /// Custom pair baked into a direct build (CUSTOM_NAME / CUSTOM_ICON_SHA).
  final String bakedCustomName;
  final String bakedCustomIconSha;

  /// Re-fetch /app-config this often while the app is in the foreground,
  /// so a server change shows up without leaving the app. 0 disables it;
  /// resume always re-fetches.
  final int configPollSeconds;

  bool get isDirect => distribution == Distribution.direct;

  /// API base URL without a trailing slash, or null when there is none.
  ///
  /// Debug and profile builds fall back to a local server on port 8080
  /// (10.0.2.2 is the host machine as seen from the Android emulator).
  /// Release builds never guess: a shipped build calling localhost is
  /// always a mistake, so it runs from the cached config instead.
  String? resolveApiBaseUrl({
    required bool isRelease,
    required bool isAndroid,
  }) {
    if (apiUrl.isNotEmpty) return apiUrl.replaceFirst(RegExp(r'/+$'), '');
    if (isRelease) return null;
    return isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
  }
}
