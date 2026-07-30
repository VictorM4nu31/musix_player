enum VisualQuality {
  low,
  medium,
  high,
  ultra;

  String get storageId => name;

  String get displayName => switch (this) {
        VisualQuality.low => 'Baja',
        VisualQuality.medium => 'Media',
        VisualQuality.high => 'Alta',
        VisualQuality.ultra => 'Ultra',
      };

  static VisualQuality? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final q in VisualQuality.values) {
      if (q.storageId == value || q.name == value) return q;
    }
    return null;
  }

  bool get allowsComplexEffects =>
      this == VisualQuality.high || this == VisualQuality.ultra;

  bool get allowsParticles => this != VisualQuality.low;

  bool get allowsShaders =>
      this == VisualQuality.high || this == VisualQuality.ultra;
}
