import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../domain/models/brand_state.dart';
import '../../domain/repositories/app_config_repository.dart';
import '../../domain/use_cases/apply_home_screen_name.dart';
import '../../domain/use_cases/apply_launcher_icon.dart';
import '../../domain/use_cases/reconcile_brand.dart';
import '../../domain/use_cases/resolve_brand_state.dart';

/// Startup order: load /app-config, reconcile once per update, show the new
/// names, then apply the home screen name and icon. Runs again on every
/// resume so changes made during the day land without a restart.
class BrandViewModel extends ChangeNotifier with WidgetsBindingObserver {
  BrandViewModel({
    required this.isDirectBuild,
    required AppConfigRepository configs,
    required ReconcileBrand reconcile,
    required ResolveBrandState resolveState,
    required ApplyHomeScreenName applyHomeScreenName,
    required ApplyLauncherIcon applyLauncherIcon,
    Duration? pollInterval,
  }) : _pollInterval = pollInterval,
       _configs = configs,
       _reconcile = reconcile,
       _resolveState = resolveState,
       _applyHomeScreenName = applyHomeScreenName,
       _applyLauncherIcon = applyLauncherIcon,
       _state = resolveState.initial();

  final bool isDirectBuild;
  final AppConfigRepository _configs;
  final ReconcileBrand _reconcile;
  final ResolveBrandState _resolveState;
  final ApplyHomeScreenName _applyHomeScreenName;
  final ApplyLauncherIcon _applyLauncherIcon;
  final Duration? _pollInterval;
  Timer? _poll;

  BrandState _state;
  BrandState get state => _state;

  bool _syncing = false;
  bool _disposed = false;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    unawaited(sync());
    _startPolling();
  }

  void _startPolling() {
    final interval = _pollInterval;
    if (interval == null || _poll != null) return;
    _poll = Timer.periodic(interval, (_) => unawaited(sync()));
  }

  void _stopPolling() {
    _poll?.cancel();
    _poll = null;
  }

  Future<void> sync() async {
    if (_syncing) return;
    _syncing = true;
    try {
      final config = await _configs.load();
      if (config == null || _disposed) return;
      await _reconcile(config);
      _state = _resolveState(config, previous: _state);
      notifyListeners();
      await _applyHomeScreenName(config);
      await _applyLauncherIcon(config);
    } finally {
      _syncing = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(sync());
      _startPolling();
    } else {
      _stopPolling();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _stopPolling();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
