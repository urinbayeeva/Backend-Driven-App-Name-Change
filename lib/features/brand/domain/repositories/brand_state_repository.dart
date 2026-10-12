/// What this device has already applied, so each change runs only once.
abstract interface class BrandStateRepository {
  String? get appliedNameKey;
  Future<void> saveAppliedNameKey(String key);

  String? get appliedIconKey;
  Future<void> saveAppliedIconKey(String key);

  /// Build number of the last successful `ReconcileBrand` run.
  int? get lastReconciledBuild;
  Future<void> saveLastReconciledBuild(int build);
}
