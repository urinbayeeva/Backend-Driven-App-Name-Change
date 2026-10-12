import 'package:flutter/foundation.dart';

import '../../../../core/config/app_env.dart';
import '../brand_catalog.dart';
import '../models/app_config.dart';
import '../models/brand_state.dart';
import '../repositories/app_config_repository.dart';

/// Turns a config into what the UI shows. Pure: no platform calls.
class ResolveBrandState {
  const ResolveBrandState({
    required this.build,
    required AppEnv env,
    required TargetPlatform platform,
    required AppConfigRepository configs,
  }) : _env = env,
       _platform = platform,
       _configs = configs;

  /// URL schemes the update button may open. Everything else (intent:,
  /// file:, custom app schemes) is dropped, because the URL comes from the
  /// network.
  static const allowedUpdateSchemes = {'https', 'http', 'itms-services'};

  final int build;
  final AppEnv _env;
  final TargetPlatform _platform;
  final AppConfigRepository _configs;

  bool get _isIos => _platform == TargetPlatform.iOS;

  /// Shown before the first config arrives: the name baked into the build.
  BrandState initial() {
    final name = _env.isDirect && _env.bakedCustomName.isNotEmpty
        ? _env.bakedCustomName
        : nameKeys[_env.primaryBrand] ?? '';
    return BrandState(
      inAppName: name,
      switcherName: name,
      iconKey: _env.primaryIcon,
    );
  }

  BrandState call(AppConfig config, {required BrandState previous}) {
    // Direct builds show the uploaded name right away, before the next
    // build bakes it in.
    final serverName = _env.isDirect
        ? config.customName ?? config.inAppName
        : config.inAppName;
    final inAppName = serverName ?? previous.inAppName;
    final sha = config.customIconSha;

    return BrandState(
      inAppName: inAppName,
      switcherName: config.switcherName ?? inAppName,
      iconKey:
          applicableKey(
            config.iconKey,
            iconKeys,
            build: build,
            minBuild: config.minBuild,
          ) ??
          previous.iconKey,
      customIconUrl: sha == null ? null : _configs.customIconUrl(sha),
      updateOffer: _env.isDirect ? _directOffer(config) : _storeOffer(config),
    );
  }

  /// True when the server's custom pair differs from the one in this build.
  bool customBrandChanged(AppConfig config) {
    final name = config.customName;
    final sha = config.customIconSha;
    return (name != null && name != _env.bakedCustomName) ||
        (sha != null && sha != _env.bakedCustomIconSha);
  }

  /// iOS builds older than `ios_name_build` still carry the old home
  /// screen name.
  UpdateOffer? _storeOffer(AppConfig config) {
    if (!_isIos || build >= config.iosNameBuild) return null;
    return UpdateOffer(
      'A new version with the updated app name is available.',
      safeUpdateUri(_env.appStoreUrl),
    );
  }

  UpdateOffer? _directOffer(AppConfig config) {
    if (!customBrandChanged(config)) return null;
    return UpdateOffer(
      'A new build with the updated name and icon is available.',
      safeUpdateUri(_isIos ? config.updateUrlIos : config.updateUrlAndroid),
    );
  }

  static Uri? safeUpdateUri(String? url) {
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    return uri != null && allowedUpdateSchemes.contains(uri.scheme)
        ? uri
        : null;
  }
}
