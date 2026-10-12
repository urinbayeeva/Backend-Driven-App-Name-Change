import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:brand_switcher/features/brand/data/models/app_config_json.dart';
import 'package:brand_switcher/features/brand/data/repositories/app_config_repository_impl.dart';
import 'package:brand_switcher/features/brand/data/services/app_config_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const payload = {
    'name_key': 'nova',
    'icon_key': 'heart',
    'in_app_name': 'NOVA PLUS',
    'switcher_name': '',
    'min_build': 142,
    'ios_name_build': 143,
    'custom_name': 'My Brand',
    'custom_icon_sha': '0123456789ab',
    'update_url_ios': '',
    'update_url_android': 'http://host/app.apk',
  };

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  AppConfigRepositoryImpl repo(MockClientHandler handler) =>
      AppConfigRepositoryImpl(
        prefs: prefs,
        api: AppConfigApi(client: MockClient(handler), baseUrl: 'http://api'),
      );

  test('parses /app-config and treats empty strings as missing', () {
    final cfg = AppConfigJson.fromJson(payload);
    expect(cfg.nameKey, 'nova');
    expect(cfg.iconKey, 'heart');
    expect(cfg.inAppName, 'NOVA PLUS');
    expect(cfg.switcherName, isNull);
    expect(cfg.minBuild, 142);
    expect(cfg.iosNameBuild, 143);
    expect(cfg.customName, 'My Brand');
    expect(cfg.customIconSha, '0123456789ab');
    expect(cfg.updateUrlIos, isNull);
    expect(cfg.updateUrlAndroid, 'http://host/app.apk');
  });

  test('ignores fields with the wrong type', () {
    final cfg = AppConfigJson.fromJson({'min_build': '142', 'name_key': 7});
    expect(cfg.minBuild, 0);
    expect(cfg.nameKey, isNull);
  });

  test('versions the custom icon URL', () {
    final r = repo((_) async => http.Response('', 200));
    expect(r.customIconUrl('abc'), 'http://api/brand/icon.png?v=abc');
  });

  test('falls back to the cached config when the request fails', () async {
    final online = repo((_) async => http.Response(jsonEncode(payload), 200));
    expect((await online.load())?.nameKey, 'nova');

    final offline = repo((_) async => http.Response('unavailable', 503));
    expect((await offline.load())?.iconKey, 'heart');
  });

  test('never caches a body that does not parse', () async {
    await repo((_) async => http.Response(jsonEncode(payload), 200)).load();
    final broken = repo((_) async => http.Response('<html>', 200));
    expect((await broken.load())?.nameKey, 'nova');
  });

  test('returns null with no network and no cache', () async {
    final r = repo((_) async => throw http.ClientException('offline'));
    expect(await r.load(), isNull);
  });

  test('runs from cache when the build has no API', () async {
    await repo((_) async => http.Response(jsonEncode(payload), 200)).load();
    final noApi = AppConfigRepositoryImpl(prefs: prefs);
    expect((await noApi.load())?.nameKey, 'nova');
    expect(noApi.customIconUrl('abc'), isNull);
  });
}
