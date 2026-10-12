/// A newer build carries the server's home screen name or icon.
class UpdateOffer {
  const UpdateOffer(this.message, this.url);

  final String message;

  /// Where the UPDATE button leads; null disables it.
  final Uri? url;
}

/// Everything the UI shows about the brand. Immutable: every sync produces
/// a new snapshot.
class BrandState {
  const BrandState({
    required this.inAppName,
    required this.switcherName,
    required this.iconKey,
    this.customIconUrl,
    this.updateOffer,
  });

  final String inAppName;

  /// MaterialApp.title, which is also the app switcher label.
  final String switcherName;

  /// Bundled icon the server selected, shown inside the app in store builds.
  final String iconKey;

  /// Uploaded custom icon, shown inside the app in direct builds.
  final String? customIconUrl;

  /// Non-blocking update banner; null hides it.
  final UpdateOffer? updateOffer;
}
