import '../../../../core/config/app_env.dart';
import '../models/app_config.dart';
import '../repositories/brand_state_repository.dart';
import '../repositories/launcher_repository.dart';

/// Store builds, once per app update. When the active brand is the one
/// baked into this build, runtime overrides are dropped so the device
/// returns to the build-defined state.
///
/// Call after /app-config is loaded and before the names and icon are
/// applied.
class ReconcileBrand {
  const ReconcileBrand({
    required this.build,
    required AppEnv env,
    required LauncherRepository launcher,
    required BrandStateRepository state,
  }) : _env = env,
       _launcher = launcher,
       _state = state;

  final int build;
  final AppEnv _env;
  final LauncherRepository _launcher;
  final BrandStateRepository _state;

  Future<void> call(AppConfig config) async {
    // Direct builds bake their pair in; there is nothing to reconcile.
    if (_env.isDirect) return;
    if (_state.lastReconciledBuild == build) return; // not an update
    final name = config.nameKey;
    final icon = config.iconKey;
    if (name == null || icon == null) return; // no active brand yet

    final result = await _launcher.reconcile(
      activeName: name,
      activeIcon: icon,
    );
    // Retried on the next launch; never blocks startup.
    if (result != LauncherResult.applied) return;

    if (name == _env.primaryBrand && icon == _env.primaryIcon) {
      // Runtime state == baked state.
      await _state.saveAppliedNameKey(name);
      await _state.saveAppliedIconKey(icon);
    }
    await _state.saveLastReconciledBuild(build);
  }
}
