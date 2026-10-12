import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/app_config.dart';
import '../../domain/repositories/app_config_repository.dart';
import '../models/app_config_json.dart';
import '../services/app_config_api.dart';

/// Network first, cache second. Only a body that parses is cached, so a
/// broken response can never replace a good offline copy.
class AppConfigRepositoryImpl implements AppConfigRepository {
  AppConfigRepositoryImpl({required SharedPreferences prefs, AppConfigApi? api})
    : _prefs = prefs,
      _api = api;

  static const _cacheKey = 'app_config';

  final SharedPreferences _prefs;

  /// Null when the build has no API URL; the app then runs from cache.
  final AppConfigApi? _api;

  @override
  Future<AppConfig?> load() async {
    final fresh = await _fetch();
    if (fresh != null) {
      final config = _decode(fresh);
      if (config != null) {
        await _prefs.setString(_cacheKey, fresh);
        return config;
      }
    }
    final cached = _prefs.getString(_cacheKey);
    return cached == null ? null : _decode(cached);
  }

  @override
  String? customIconUrl(String sha) => _api?.customIconUrl(sha);

  Future<String?> _fetch() async {
    final api = _api;
    if (api == null) return null;
    try {
      return await api.fetchAppConfig();
    } on Exception {
      return null; // Offline or server down: use the cache.
    }
  }

  static AppConfig? _decode(String body) {
    try {
      final json = jsonDecode(body);
      return json is Map<String, Object?> ? AppConfigJson.fromJson(json) : null;
    } on FormatException {
      return null;
    }
  }
}
