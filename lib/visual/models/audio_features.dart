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
  });

  static const silent = AudioFeatures();

  final double energy;
  final double bass;
  final double mid;
  final double treble;
  final double beatPulse;
  final double intensity;
  final bool isPlaying;

  AudioFeatures copyWith({
    double? energy,
    double? bass,
    double? mid,
    double? treble,
    double? beatPulse,
    double? intensity,
    bool? isPlaying,
  }) {
    return AudioFeatures(
      energy: energy ?? this.energy,
      bass: bass ?? this.bass,
      mid: mid ?? this.mid,
      treble: treble ?? this.treble,
      beatPulse: beatPulse ?? this.beatPulse,
      intensity: intensity ?? this.intensity,
      isPlaying: isPlaying ?? this.isPlaying,
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
        other.isPlaying == isPlaying;
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
      );
}
