import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brand_switcher/core/config/app_env.dart';
import 'package:brand_switcher/core/config/distribution.dart';
import 'package:brand_switcher/features/brand/domain/models/app_config.dart';
import 'package:brand_switcher/features/brand/domain/use_cases/resolve_brand_state.dart';

import '../fakes.dart';

void main() {
  ResolveBrandState resolver({
    AppEnv env = const AppEnv(),
    TargetPlatform platform = TargetPlatform.android,
    int build = 142,
  }) => ResolveBrandState(
    build: build,
    env: env,
    platform: platform,
    configs: FakeConfigs(),
  );

  const direct = AppEnv(
    distribution: Distribution.direct,
    bakedCustomName: 'My Brand',
    bakedCustomIconSha: '0123456789ab',
  );

  test('starts from the name and icon baked into the build', () {
    final store = resolver().initial();
    expect(store.inAppName, 'AURORA');
    expect(store.iconKey, 'rocket');
    expect(resolver(env: direct).initial().inAppName, 'My Brand');
  });

  test('store builds show in_app_name and the selected bundled icon', () {
    final r = resolver();
    final state = r(
      const AppConfig(inAppName: 'NOVA PLUS', iconKey: 'star'),
      previous: r.initial(),
    );
    expect(state.inAppName, 'NOVA PLUS');
    expect(state.switcherName, 'NOVA PLUS');
    expect(state.iconKey, 'star');
  });

  test('keeps the previous icon when the key does not apply', () {
    final r = resolver();
    final state = r(const AppConfig(iconKey: 'unknown'), previous: r.initial());
    expect(state.iconKey, 'rocket');
  });

  test('direct builds prefer the uploaded custom name', () {
    final r = resolver(env: direct);
    final state = r(
      const AppConfig(customName: 'Brand 2', inAppName: 'ignored'),
      previous: r.initial(),
    );
    expect(state.inAppName, 'Brand 2');
  });

  test('customBrandChanged compares against the baked pair', () {
    final r = resolver(env: direct);
    expect(r.customBrandChanged(const AppConfig()), isFalse);
    expect(
      r.customBrandChanged(
        const AppConfig(customName: 'My Brand', customIconSha: '0123456789ab'),
      ),
      isFalse,
    );
    expect(r.customBrandChanged(const AppConfig(customName: 'New')), isTrue);
    expect(
      r.customBrandChanged(const AppConfig(customIconSha: 'ffffffffffff')),
      isTrue,
    );
  });

  test('offers an iOS store update to builds without the new name', () {
    final r = resolver(
      env: const AppEnv(appStoreUrl: 'https://apps.apple.com/app/id1'),
      platform: TargetPlatform.iOS,
    );
    final offer = r(
      const AppConfig(iosNameBuild: 143),
      previous: r.initial(),
    ).updateOffer;
    expect(offer?.url, Uri.parse('https://apps.apple.com/app/id1'));
    expect(
      r(const AppConfig(iosNameBuild: 142), previous: r.initial()).updateOffer,
      isNull,
    );
  });

  test('update URLs from the network are limited to safe schemes', () {
    expect(ResolveBrandState.safeUpdateUri('https://x/app.apk'), isNotNull);
    expect(
      ResolveBrandState.safeUpdateUri(
        'itms-services://?action=download-manifest&url=https://x/m.plist',
      ),
      isNotNull,
    );
    expect(ResolveBrandState.safeUpdateUri('intent://evil#Intent;end'), isNull);
    expect(ResolveBrandState.safeUpdateUri('file:///etc/hosts'), isNull);
    expect(ResolveBrandState.safeUpdateUri(''), isNull);
    expect(ResolveBrandState.safeUpdateUri(null), isNull);
  });
}
