/// How this build reaches devices. CI passes `--dart-define=DISTRIBUTION`.
///
/// Neither iOS nor Android lets an app put a downloaded icon or name on the
/// home screen, so the two variants differ in where the pair comes from:
/// - [Distribution.store] (App Store / Play): switches at runtime between
///   the keys bundled in the build (brand_catalog.dart).
/// - [Distribution.direct] (ad hoc / enterprise / APK, no review): the
///   custom name and icon are baked into the build, and the app
///   links to the next direct build once the server's pair changes.
enum Distribution { store, direct }
