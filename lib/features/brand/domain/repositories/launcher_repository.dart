enum LauncherResult {
  applied,

  /// iOS only switches icons while the app is in the foreground.
  notActive,

  failed,
}

/// The home screen name and icon, owned by the OS launcher.
abstract interface class LauncherRepository {
  /// Android only. Staged and applied when the app leaves the foreground.
  Future<LauncherResult> setNameKey(String key);

  /// Android stages the switch until onStop; iOS applies it immediately
  /// and shows a system alert.
  Future<LauncherResult> setIconKey(String key);

  /// Drops runtime overrides after an app update.
  Future<LauncherResult> reconcile({
    required String activeName,
    required String activeIcon,
  });
}
