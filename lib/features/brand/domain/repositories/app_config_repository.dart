import '../models/app_config.dart';

abstract interface class AppConfigRepository {
  /// Latest config, falling back to the last cached copy; null when neither
  /// exists. Never throws, so it can never block app start.
  Future<AppConfig?> load();

  /// Versioned so a new upload is never served from the image cache.
  /// Null when the build has no API to load it from.
  String? customIconUrl(String sha);
}
