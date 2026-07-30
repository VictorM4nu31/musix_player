import 'package:flutter/foundation.dart';

/// Pseudo audio features for visualizers (not real FFT).
@immutable
class AudioFeatures {
  const AudioFeatures({
    this.energy = 0,
    this.bass = 0,
    this.mid = 0,
    this.treble = 0,
    this.beatPulse = 0,
    this.intensity = 0,
    this.isPlaying = false,
    this.bands = const [],
  });

  static const silent = AudioFeatures();

  static const bandCount = 32;

  final double energy;
  final double bass;
  final double mid;
  final double treble;
  final double beatPulse;
  final double intensity;
  final bool isPlaying;

  /// Normalized 0–1 spectrum bins (pseudo). Empty when silent/disabled.
  final List<double> bands;

  double bandAt(int index) {
    if (bands.isEmpty) return 0;
    return bands[index % bands.length];
  }

  AudioFeatures copyWith({
    double? energy,
    double? bass,
    double? mid,
    double? treble,
    double? beatPulse,
    double? intensity,
    bool? isPlaying,
    List<double>? bands,
  }) {
    return AudioFeatures(
      energy: energy ?? this.energy,
      bass: bass ?? this.bass,
      mid: mid ?? this.mid,
      treble: treble ?? this.treble,
      beatPulse: beatPulse ?? this.beatPulse,
      intensity: intensity ?? this.intensity,
      isPlaying: isPlaying ?? this.isPlaying,
      bands: bands ?? this.bands,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AudioFeatures &&
        other.energy == energy &&
        other.bass == bass &&
        other.mid == mid &&
        other.treble == treble &&
        other.beatPulse == beatPulse &&
        other.intensity == intensity &&
        other.isPlaying == isPlaying &&
        listEquals(other.bands, bands);
  }

  @override
  int get hashCode => Object.hash(
        energy,
        bass,
        mid,
        treble,
        beatPulse,
        intensity,
        isPlaying,
        Object.hashAll(bands),
      );
}
