import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brand_switcher/core/config/app_env.dart';
import 'package:brand_switcher/core/config/distribution.dart';
import 'package:brand_switcher/features/brand/domain/models/app_config.dart';
import 'package:brand_switcher/features/brand/domain/repositories/launcher_repository.dart';
import 'package:brand_switcher/features/brand/domain/use_cases/apply_home_screen_name.dart';
import 'package:brand_switcher/features/brand/domain/use_cases/apply_launcher_icon.dart';
import 'package:brand_switcher/features/brand/domain/use_cases/reconcile_brand.dart';

import '../fakes.dart';

void main() {
  const directEnv = AppEnv(distribution: Distribution.direct);
  late FakeLauncher launcher;
  late FakeBrandState state;

  setUp(() {
    launcher = FakeLauncher();
    state = FakeBrandState();
  });

  group('ApplyLauncherIcon', () {
    ApplyLauncherIcon useCase({AppEnv env = const AppEnv()}) =>
        ApplyLauncherIcon(
          build: 142,
          env: env,
          platform: TargetPlatform.iOS,
          launcher: launcher,
          state: state,
          iosSettleDelay: Duration.zero,
        );

    test('applies a new key once', () async {
      final apply = useCase();
      await apply(const AppConfig(iconKey: 'star'));
      await apply(const AppConfig(iconKey: 'star'));
      expect(launcher.calls, ['icon:star']);
      expect(state.appliedIconKey, 'star');
    });

    test('retries notActive, gives up on failed until relaunch', () async {
      final apply = useCase();
      launcher.result = LauncherResult.notActive;
      await apply(const AppConfig(iconKey: 'star'));
      await apply(const AppConfig(iconKey: 'star'));
      expect(launcher.calls, ['icon:star', 'icon:star']);

      launcher.result = LauncherResult.failed;
      await apply(const AppConfig(iconKey: 'heart'));
      await apply(const AppConfig(iconKey: 'heart'));
      expect(launcher.calls.where((c) => c == 'icon:heart'), hasLength(1));
      expect(state.appliedIconKey, isNull);
    });

    test('does nothing in direct builds', () async {
      await useCase(env: directEnv)(const AppConfig(iconKey: 'star'));
      expect(launcher.calls, isEmpty);
    });
  });

  group('ApplyHomeScreenName', () {
    ApplyHomeScreenName useCase(TargetPlatform platform) => ApplyHomeScreenName(
      build: 142,
      env: const AppEnv(),
      platform: platform,
      launcher: launcher,
      state: state,
    );

    test('switches bundled names on Android only', () async {
      await useCase(TargetPlatform.iOS)(const AppConfig(nameKey: 'pulse'));
      expect(launcher.calls, isEmpty);

      await useCase(TargetPlatform.android)(const AppConfig(nameKey: 'pulse'));
      expect(launcher.calls, ['name:pulse']);
      expect(state.appliedNameKey, 'pulse');
    });

    test('keeps the key unsaved on failure so the next sync retries', () async {
      launcher.result = LauncherResult.failed;
      await useCase(TargetPlatform.android)(const AppConfig(nameKey: 'pulse'));
      expect(state.appliedNameKey, isNull);
    });
  });

  group('ReconcileBrand', () {
    ReconcileBrand useCase({int build = 142}) => ReconcileBrand(
      build: build,
      env: const AppEnv(),
      launcher: launcher,
      state: state,
    );

    test('runs once per build and adopts the baked pair', () async {
      const config = AppConfig(nameKey: 'aurora', iconKey: 'rocket');
      await useCase()(config);
      await useCase()(config);
      expect(launcher.calls, ['reconcile:aurora/rocket']);
      expect(state.appliedNameKey, 'aurora');
      expect(state.appliedIconKey, 'rocket');
      expect(state.lastReconciledBuild, 142);
    });

    test('retries on the next launch when the platform fails', () async {
      launcher.result = LauncherResult.failed;
      await useCase()(const AppConfig(nameKey: 'pulse', iconKey: 'star'));
      expect(state.lastReconciledBuild, isNull);
    });
  });
}
