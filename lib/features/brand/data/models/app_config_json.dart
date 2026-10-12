import '../../domain/models/app_config.dart';

/// Maps the GET /app-config payload to [AppConfig]. The server sends ""
/// for "not set", so empty strings become null; wrong types fall back to
/// the default instead of throwing.
abstract final class AppConfigJson {
  static AppConfig fromJson(Map<String, Object?> json) => AppConfig(
    nameKey: _string(json['name_key']),
    iconKey: _string(json['icon_key']),
    inAppName: _string(json['in_app_name']),
    switcherName: _string(json['switcher_name']),
    minBuild: _int(json['min_build']),
    iosNameBuild: _int(json['ios_name_build']),
    customName: _string(json['custom_name']),
    customIconSha: _string(json['custom_icon_sha']),
    updateUrlIos: _string(json['update_url_ios']),
    updateUrlAndroid: _string(json['update_url_android']),
  );

  static String? _string(Object? v) => v is String && v.isNotEmpty ? v : null;

  static int _int(Object? v) => v is num ? v.toInt() : 0;
}
