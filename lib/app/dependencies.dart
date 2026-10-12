import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/app_env.dart';
import '../features/brand/data/repositories/app_config_repository_impl.dart';
import '../features/brand/data/repositories/brand_state_repository_impl.dart';
import '../features/brand/data/repositories/launcher_repository_impl.dart';
import '../features/brand/data/services/app_config_api.dart';
import '../features/brand/domain/use_cases/apply_home_screen_name.dart';
import '../features/brand/domain/use_cases/apply_launcher_icon.dart';
import '../features/brand/domain/use_cases/reconcile_brand.dart';
import '../features/brand/domain/use_cases/resolve_brand_state.dart';
import '../features/brand/presentation/view_models/brand_view_model.dart';

/// Composition root: the only place that picks concrete implementations.
/// Everything below it receives its dependencies through constructors.
Future<BrandViewModel> createBrandViewModel(AppEnv env) async {
  final (prefs, info) = await (
    SharedPreferences.getInstance(),
    PackageInfo.fromPlatform(),
  ).wait;
  final build = int.tryParse(info.buildNumber) ?? 0;
  final platform = defaultTargetPlatform;

  final baseUrl = env.resolveApiBaseUrl(
    isRelease: kReleaseMode,
    isAndroid: platform == TargetPlatform.android,
  );
  final configs = AppConfigRepositoryImpl(
    prefs: prefs,
    api: baseUrl == null
        ? null
        : AppConfigApi(client: http.Client(), baseUrl: baseUrl),
  );
  final state = BrandStateRepositoryImpl(prefs);
  const launcher = LauncherRepositoryImpl();

  return BrandViewModel(
    isDirectBuild: env.isDirect,
    pollInterval: env.configPollSeconds > 0
        ? Duration(seconds: env.configPollSeconds)
        : null,
    configs: configs,
    reconcile: ReconcileBrand(
      build: build,
      env: env,
      launcher: launcher,
      state: state,
    ),
    resolveState: ResolveBrandState(
      build: build,
      env: env,
      platform: platform,
      configs: configs,
    ),
    applyHomeScreenName: ApplyHomeScreenName(
      build: build,
      env: env,
      platform: platform,
      launcher: launcher,
      state: state,
    ),
    applyLauncherIcon: ApplyLauncherIcon(
      build: build,
      env: env,
      platform: platform,
      launcher: launcher,
      state: state,
    ),
  );
}
