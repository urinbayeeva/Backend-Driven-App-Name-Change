import 'package:flutter/services.dart';

import '../../domain/repositories/launcher_repository.dart';

/// Method channels to the native launcher code: Android BrandSwitcher.kt
/// (both channels), iOS AppIconHandler in AppDelegate.swift (app/icon only).
/// Channel and method names are a contract with that code.
class LauncherRepositoryImpl implements LauncherRepository {
  const LauncherRepositoryImpl({
    MethodChannel nameChannel = const MethodChannel('app/name'),
    MethodChannel iconChannel = const MethodChannel('app/icon'),
  }) : _name = nameChannel,
       _icon = iconChannel;

  final MethodChannel _name;
  final MethodChannel _icon;

  @override
  Future<LauncherResult> setNameKey(String key) =>
      _invoke(_name, 'setNameKey', {'key': key});

  @override
  Future<LauncherResult> setIconKey(String key) =>
      _invoke(_icon, 'setIconKey', {'key': key});

  @override
  Future<LauncherResult> reconcile({
    required String activeName,
    required String activeIcon,
  }) => _invoke(_icon, 'reconcile', {
    'activeName': activeName,
    'activeIcon': activeIcon,
  });

  static Future<LauncherResult> _invoke(
    MethodChannel channel,
    String method,
    Map<String, String> arguments,
  ) async {
    try {
      await channel.invokeMethod<Object?>(method, arguments);
      return LauncherResult.applied;
    } on PlatformException catch (e) {
      return e.code == 'NOT_ACTIVE'
          ? LauncherResult.notActive
          : LauncherResult.failed;
    } on MissingPluginException {
      return LauncherResult.failed;
    }
  }
}
