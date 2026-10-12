/// Keys bundled in this build. Mirrors the Gradle registry, BrandSwitcher.kt and
/// AppDelegate.swift. Append-only: never rename or remove a key a user may
/// have enabled.
const nameKeys = {
  'aurora': 'AURORA',
  'nova': 'NOVA',
  'pulse': 'PULSE',
  'orbit': 'ORBIT',
};
const iconKeys = {'rocket', 'star', 'heart'};

/// Returns [key] when this build can apply it, otherwise null: missing keys,
/// keys not bundled here and builds below `min_build` are ignored.
String? applicableKey(
  String? key,
  Iterable<String> bundled, {
  required int build,
  required int minBuild,
}) => key != null && bundled.contains(key) && build >= minBuild ? key : null;
