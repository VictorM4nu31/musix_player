import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../models/audio_features.dart';

/// Generates smooth pseudo audio features from play state + song identity.
///
/// Not real FFT. Deterministic enough to feel musical, cheap enough for Low.
class AudioFeatureBus with ChangeNotifier {
  AudioFeatureBus({
    this.targetFps = 36,
    this.bandCount = AudioFeatures.bandCount,
  });

  final int targetFps;
  final int bandCount;

  AudioFeatures _features = AudioFeatures.silent;
  AudioFeatures get features => _features;

  bool _isPlaying = false;
  int _songId = 0;
  Duration _position = Duration.zero;
  bool _enabled = true;
  bool _visible = true;
  bool _audioReactive = true;
  double _intensity = 0.7;

  Ticker? _ticker;
  Duration _lastTick = Duration.zero;
  double _beatPhase = 0;
  double _smoothedEnergy = 0;
  List<double> _smoothedBands = const [];

  void attachTicker(TickerProvider vsync) {
    if (_smoothedBands.length != bandCount) {
      _smoothedBands = List<double>.filled(bandCount, 0);
    }
    _ticker?.dispose();
    _ticker = vsync.createTicker(_onTick);
    _syncTicker();
  }

  void updatePlayback({
    required bool isPlaying,
    required int songId,
    required Duration position,
  }) {
    final songChanged = songId != _songId;
    _isPlaying = isPlaying;
    _songId = songId;
    _position = position;
    if (songChanged) {
      _beatPhase = 0;
      _smoothedEnergy = 0;
      _smoothedBands = List<double>.filled(bandCount, 0);
    }
    _syncTicker();
    if (!isPlaying) {
      _emitPaused();
    }
  }

  void updateSettings({
    required bool enabled,
    required bool visible,
    required bool audioReactive,
    required double intensity,
  }) {
    _enabled = enabled;
    _visible = visible;
    _audioReactive = audioReactive;
    _intensity = intensity.clamp(0.0, 1.0);
    _syncTicker();
    if (!_shouldRun) {
      _emitPaused();
    }
  }

  bool get _shouldRun =>
      _enabled && _visible && _isPlaying && _audioReactive && _intensity > 0;

  void _syncTicker() {
    final ticker = _ticker;
    if (ticker == null) return;
    if (_shouldRun) {
      if (!ticker.isActive) {
        _lastTick = Duration.zero;
        ticker.start();
      }
    } else if (ticker.isActive) {
      ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    final minDelta = Duration(milliseconds: (1000 / targetFps).round());
    if (_lastTick != Duration.zero && elapsed - _lastTick < minDelta) {
      return;
    }
    final dt = _lastTick == Duration.zero
        ? 1 / targetFps
        : (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    _step(dt.clamp(0.0, 0.05));
  }

  void _step(double dt) {
    final seed = _songId * 12.9898;
    final t = _position.inMilliseconds / 1000.0;

    final waveA = _sin01(t * 2.1 + seed);
    final waveB = _sin01(t * 3.4 + seed * 1.7);
    final waveC = _sin01(t * 5.2 + seed * 0.3);
    final slow = _sin01(t * 0.35 + seed);

    final bpmPeriod = 0.48 + (_songId % 7) * 0.02;
    _beatPhase += dt / bpmPeriod;
    final beatRaw = math.pow(
      (0.5 + 0.5 * math.cos(_beatPhase * math.pi * 2)).clamp(0.0, 1.0),
      3,
    ) as double;

    final targetEnergy =
        (0.35 + 0.35 * waveA + 0.2 * waveB + 0.1 * slow) * _intensity;
    _smoothedEnergy +=
        (targetEnergy - _smoothedEnergy) * (1 - math.exp(-dt * 8));

    final bass = (_smoothedEnergy * 0.55 + beatRaw * 0.45 * _intensity)
        .clamp(0.0, 1.0);
    final mid =
        (0.3 + 0.5 * waveB + 0.2 * beatRaw).clamp(0.0, 1.0) * _intensity;
    final treble =
        (0.25 + 0.55 * waveC + 0.15 * waveA).clamp(0.0, 1.0) * _intensity;

    final bands = List<double>.generate(bandCount, (i) {
      final frac = i / (bandCount - 1);
      // Low bins lean bass, high bins lean treble.
      final envelope = frac < 0.25
          ? bass
          : frac < 0.6
              ? mid
              : treble;
      final wobble = _sin01(
        t * (2.4 + frac * 4.5) + seed + i * 0.37 + _beatPhase,
      );
      final peak = beatRaw * (1.0 - frac * 0.55);
      final raw =
          (0.18 + envelope * 0.55 + wobble * 0.35 + peak * 0.4) * _intensity;
      final target = raw.clamp(0.05, 1.0);
      _smoothedBands[i] +=
          (target - _smoothedBands[i]) * (1 - math.exp(-dt * (10 + frac * 6)));
      return _smoothedBands[i].clamp(0.0, 1.0);
    });

    final next = AudioFeatures(
      energy: _smoothedEnergy.clamp(0.0, 1.0),
      bass: bass,
      mid: mid,
      treble: treble,
      beatPulse: (beatRaw * _intensity).clamp(0.0, 1.0),
      intensity: _intensity,
      isPlaying: true,
      bands: bands,
    );

    if (!_nearlyEqual(next, _features)) {
      _features = next;
      notifyListeners();
    }
  }

  void _emitPaused() {
    if (_smoothedBands.length != bandCount) {
      _smoothedBands = List<double>.filled(bandCount, 0.08);
    }
    final bands = List<double>.generate(bandCount, (i) {
      final target = 0.08 + (i % 3) * 0.02;
      _smoothedBands[i] += (target - _smoothedBands[i]) * 0.2;
      return _smoothedBands[i].clamp(0.0, 1.0);
    });
    final next = AudioFeatures(
      energy: _smoothedEnergy * 0.15,
      bass: _smoothedEnergy * 0.1,
      mid: 0.08,
      treble: 0.06,
      beatPulse: 0,
      intensity: _intensity,
      isPlaying: false,
      bands: bands,
    );
    if (next != _features) {
      _features = next;
      notifyListeners();
    }
  }

  static double _sin01(double x) => 0.5 + 0.5 * math.sin(x);

  static bool _nearlyEqual(AudioFeatures a, AudioFeatures b) {
    const eps = 0.014;
    if ((a.energy - b.energy).abs() >= eps ||
        (a.bass - b.bass).abs() >= eps ||
        (a.mid - b.mid).abs() >= eps ||
        (a.treble - b.treble).abs() >= eps ||
        (a.beatPulse - b.beatPulse).abs() >= eps ||
        a.isPlaying != b.isPlaying) {
      return false;
    }
    if (a.bands.length != b.bands.length) return false;
    for (var i = 0; i < a.bands.length; i += 2) {
      if ((a.bands[i] - b.bands[i]).abs() >= eps) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _ticker = null;
    super.dispose();
  }
}
