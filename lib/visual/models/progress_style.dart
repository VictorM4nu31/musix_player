enum ProgressStyle {
  slider,
  waveform,
  auto;

  String get storageId => name;

  String get displayName => switch (this) {
        ProgressStyle.slider => 'Barra clásica',
        ProgressStyle.waveform => 'Waveform',
        ProgressStyle.auto => 'Automático',
      };

  static ProgressStyle? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final s in ProgressStyle.values) {
      if (s.storageId == value || s.name == value) return s;
    }
    return null;
  }
}
