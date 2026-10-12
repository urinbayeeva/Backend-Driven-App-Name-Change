import 'package:flutter_test/flutter_test.dart';
import 'package:brand_switcher/core/config/app_env.dart';
import 'package:brand_switcher/core/config/distribution.dart';

void main() {
  test('defaults to the store variant and the aurora/rocket pair', () {
    const env = AppEnv.fromEnvironment();
    expect(env.distribution, Distribution.store);
    expect(env.primaryBrand, 'aurora');
    expect(env.primaryIcon, 'rocket');
  });

  group('resolveApiBaseUrl', () {
    test('uses API_URL without a trailing slash', () {
      const env = AppEnv(apiUrl: 'https://api.example.com/');
      expect(
        env.resolveApiBaseUrl(isRelease: true, isAndroid: true),
        'https://api.example.com',
      );
    });

    test('falls back to a local API in debug builds', () {
      const env = AppEnv();
      expect(
        env.resolveApiBaseUrl(isRelease: false, isAndroid: true),
        'http://10.0.2.2:8080',
      );
      expect(
        env.resolveApiBaseUrl(isRelease: false, isAndroid: false),
        'http://localhost:8080',
      );
    });

    test('never guesses in release builds', () {
      const env = AppEnv();
      expect(env.resolveApiBaseUrl(isRelease: true, isAndroid: true), isNull);
    });
  });
}
