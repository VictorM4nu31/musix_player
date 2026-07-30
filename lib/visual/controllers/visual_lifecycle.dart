import 'package:flutter/widgets.dart';

/// Tracks whether heavy visuals should run (foreground + player visible).
class VisualLifecycle with WidgetsBindingObserver, ChangeNotifier {
  VisualLifecycle() {
    WidgetsBinding.instance.addObserver(this);
    _appResumed =
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.paused &&
            WidgetsBinding.instance.lifecycleState != AppLifecycleState.detached &&
            WidgetsBinding.instance.lifecycleState != AppLifecycleState.hidden;
  }

  bool _appResumed = true;
  bool _playerVisible = false;

  bool get appResumed => _appResumed;
  bool get playerVisible => _playerVisible;

  /// True when full-player visualizers may animate.
  bool get allowHeavyVisuals => _appResumed && _playerVisible;

  void setPlayerVisible(bool visible) {
    if (_playerVisible == visible) return;
    _playerVisible = visible;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final resumed = state == AppLifecycleState.resumed;
    if (resumed == _appResumed) return;
    _appResumed = resumed;
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
