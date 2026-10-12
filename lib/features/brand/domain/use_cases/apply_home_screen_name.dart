import 'package:flutter/foundation.dart';

import '../../../../core/config/app_env.dart';
import '../brand_catalog.dart';
import '../models/app_config.dart';
import '../repositories/brand_state_repository.dart';
import '../repositories/launcher_repository.dart';

/// Android store builds: switches the home screen name between the labels
/// bundled in this build. On iOS, and in direct builds, the home screen name
/// changes only through a new build.
class ApplyHomeScreenName {
  const ApplyHomeScreenName({
    required this.build,
    required AppEnv env,
    required TargetPlatform platform,
    required LauncherRepository launcher,
    required BrandStateRepository state,
  }) : _env = env,
       _platform = platform,
       _launcher = launcher,
       _state = state;

  final int build;
  final AppEnv _env;
  final TargetPlatform _platform;
  final LauncherRepository _launcher;
  final BrandStateRepository _state;

  Future<void> call(AppConfig config) async {
    if (_env.isDirect || _platform != TargetPlatform.android) return;

    final key = applicableKey(
      config.nameKey,
      nameKeys.keys,
      build: build,
      minBuild: config.minBuild,
    );
    if (key == null || key == _state.appliedNameKey) return;

    // On failure the key stays unsaved and is retried on the next sync.
    if (await _launcher.setNameKey(key) == LauncherResult.applied) {
      await _state.saveAppliedNameKey(key);
    }
  }
}
