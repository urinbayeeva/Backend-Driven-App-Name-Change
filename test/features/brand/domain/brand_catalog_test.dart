import 'package:flutter_test/flutter_test.dart';
import 'package:brand_switcher/core/config/app_env.dart';
import 'package:brand_switcher/features/brand/domain/brand_catalog.dart';

void main() {
  test('applicableKey accepts only bundled keys on new enough builds', () {
    expect(
      applicableKey('pulse', nameKeys.keys, build: 142, minBuild: 142),
      'pulse',
    );
    expect(applicableKey(null, nameKeys.keys, build: 142, minBuild: 0), isNull);
    expect(
      applicableKey('leader', nameKeys.keys, build: 142, minBuild: 0),
      isNull,
    );
    expect(applicableKey('star', iconKeys, build: 141, minBuild: 142), isNull);
  });

  test('home screen names fit the launcher', () {
    for (final label in nameKeys.values) {
      expect(label.length, inInclusiveRange(1, 12));
    }
  });

  test('primary pair is bundled', () {
    const env = AppEnv.fromEnvironment();
    expect(nameKeys, contains(env.primaryBrand));
    expect(iconKeys, contains(env.primaryIcon));
  });
}
