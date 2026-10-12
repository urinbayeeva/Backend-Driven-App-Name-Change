import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/brand_state_repository.dart';

/// Keys are part of the on-device format: renaming one makes every
/// installed app re-apply its brand once.
class BrandStateRepositoryImpl implements BrandStateRepository {
  const BrandStateRepositoryImpl(this._prefs);

  static const _appliedNameKey = 'applied_name_key';
  static const _appliedIconKey = 'applied_icon_key';
  static const _lastBuildKey = 'last_build';

  final SharedPreferences _prefs;

  @override
  String? get appliedNameKey => _prefs.getString(_appliedNameKey);

  @override
  Future<void> saveAppliedNameKey(String key) =>
      _prefs.setString(_appliedNameKey, key);

  @override
  String? get appliedIconKey => _prefs.getString(_appliedIconKey);

  @override
  Future<void> saveAppliedIconKey(String key) =>
      _prefs.setString(_appliedIconKey, key);

  @override
  int? get lastReconciledBuild => _prefs.getInt(_lastBuildKey);

  @override
  Future<void> saveLastReconciledBuild(int build) =>
      _prefs.setInt(_lastBuildKey, build);
}
