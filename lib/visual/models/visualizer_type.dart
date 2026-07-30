enum VisualizerType {
  none,
  minimal,
  pulse,
  vinyl,
  waves,
  equalizer,
  spectrum;

  String get storageId => name;

  String get displayName => switch (this) {
        VisualizerType.none => 'Sin animación',
        VisualizerType.minimal => 'Minimalista',
        VisualizerType.pulse => 'Pulso',
        VisualizerType.vinyl => 'Vinilo',
        VisualizerType.waves => 'Ondas',
        VisualizerType.equalizer => 'Ecualizador',
        VisualizerType.spectrum => 'Espectro',
      };

  static VisualizerType? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final type in VisualizerType.values) {
      if (type.storageId == value || type.name == value) return type;
    }
    return null;
  }

  /// Legacy [PlayerAnimationType] index order:
  /// waves, equalizer, pulse, vinyl, minimal, none
  static VisualizerType fromLegacyIndex(int index) {
    return switch (index) {
      0 => VisualizerType.waves,
      1 => VisualizerType.equalizer,
      2 => VisualizerType.pulse,
      3 => VisualizerType.vinyl,
      4 => VisualizerType.minimal,
      5 => VisualizerType.none,
      _ => VisualizerType.vinyl,
    };
  }

  int get legacyIndex => switch (this) {
        VisualizerType.waves => 0,
        VisualizerType.equalizer => 1,
        VisualizerType.pulse => 2,
        VisualizerType.vinyl => 3,
        VisualizerType.minimal => 4,
        VisualizerType.none => 5,
        VisualizerType.spectrum => 2, // closest legacy: pulse
      };
}
