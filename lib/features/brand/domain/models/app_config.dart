/// What the backend says this device should show (GET /app-config).
class AppConfig {
  const AppConfig({
    this.nameKey,
    this.iconKey,
    this.inAppName,
    this.switcherName,
    this.minBuild = 0,
    this.iosNameBuild = 0,
    this.customName,
    this.customIconSha,
    this.updateUrlIos,
    this.updateUrlAndroid,
  });

  /// Home screen name; must be bundled in the build.
  final String? nameKey;

  /// Launcher icon; must be bundled in the build.
  final String? iconKey;

  /// Free text shown inside the app.
  final String? inAppName;

  /// Free text for the app switcher.
  final String? switcherName;

  /// Builds below this ignore [nameKey] and [iconKey].
  final int minBuild;

  /// First iOS build that contains the current home screen name.
  final int iosNameBuild;

  /// Custom name set on the backend. Direct builds bake it in.
  final String? customName;

  /// Version of GET /brand/icon.png; null until an icon is uploaded.
  final String? customIconSha;

  /// Direct builds: itms-services:// link to the latest ad hoc build.
  final String? updateUrlIos;

  /// Direct builds: link to the latest APK.
  final String? updateUrlAndroid;
}
