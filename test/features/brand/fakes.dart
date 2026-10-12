import 'package:brand_switcher/features/brand/domain/models/app_config.dart';
import 'package:brand_switcher/features/brand/domain/repositories/app_config_repository.dart';
import 'package:brand_switcher/features/brand/domain/repositories/brand_state_repository.dart';
import 'package:brand_switcher/features/brand/domain/repositories/launcher_repository.dart';

class FakeLauncher implements LauncherRepository {
  LauncherResult result = LauncherResult.applied;
  final calls = <String>[];

  @override
  Future<LauncherResult> setNameKey(String key) async {
    calls.add('name:$key');
    return result;
  }

  @override
  Future<LauncherResult> setIconKey(String key) async {
    calls.add('icon:$key');
    return result;
  }

  @override
  Future<LauncherResult> reconcile({
    required String activeName,
    required String activeIcon,
  }) async {
    calls.add('reconcile:$activeName/$activeIcon');
    return result;
  }
}

class FakeBrandState implements BrandStateRepository {
  @override
  String? appliedNameKey;
  @override
  String? appliedIconKey;
  @override
  int? lastReconciledBuild;

  @override
  Future<void> saveAppliedNameKey(String key) async => appliedNameKey = key;

  @override
  Future<void> saveAppliedIconKey(String key) async => appliedIconKey = key;

  @override
  Future<void> saveLastReconciledBuild(int build) async =>
      lastReconciledBuild = build;
}

class FakeConfigs implements AppConfigRepository {
  FakeConfigs([this.config]);

  AppConfig? config;

  @override
  Future<AppConfig?> load() async => config;

  @override
  String? customIconUrl(String sha) => 'http://api/brand/icon.png?v=$sha';
}
