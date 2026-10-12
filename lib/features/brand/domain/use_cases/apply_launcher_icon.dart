import 'package:flutter/foundation.dart';

import '../../../../core/config/app_env.dart';
import '../brand_catalog.dart';
import '../models/app_config.dart';
import '../repositories/brand_state_repository.dart';
import '../repositories/launcher_repository.dart';

/// Store builds: switches the launcher icon between bundled icon sets.
class ApplyLauncherIcon {
  ApplyLauncherIcon({
    required this.build,
    required AppEnv env,
    required TargetPlatform platform,
    required LauncherRepository launcher,
    required BrandStateRepository state,
    this.iosSettleDelay = const Duration(seconds: 2),
  }) : _env = env,
       _platform = platform,
       _launcher = launcher,
       _state = state;

  final int build;
  final AppEnv _env;
  final TargetPlatform _platform;
  final LauncherRepository _launcher;
  final BrandStateRepository _state;

  /// Lets the home screen settle so the iOS alert lands at a calm moment.
  final Duration iosSettleDelay;

  // A key the platform rejected for a reason other than notActive;
  // not retried until the next launch.
  String? _failedKey;

  Future<void> call(AppConfig config) async {
    if (_env.isDirect) return;

    final key = applicableKey(
      config.iconKey,
      iconKeys,
      build: build,
      minBuild: config.minBuild,
    );
    if (key == null || key == _failedKey || key == _state.appliedIconKey) {
      return;
    }

    if (_platform == TargetPlatform.iOS) {
      await Future<void>.delayed(iosSettleDelay);
    }
    switch (await _launcher.setIconKey(key)) {
      case LauncherResult.applied:
        await _state.saveAppliedIconKey(key);
      case LauncherResult.notActive:
        break; // Retried on the next resume.
      case LauncherResult.failed:
        _failedKey = key;
    }
  }
}
