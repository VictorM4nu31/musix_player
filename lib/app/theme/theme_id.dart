enum ThemeId {
  system,
  light,
  dark,
  pixelArt,
  amoled,
  cyberpunk,
  minimal;

  String get storageId => name;

  String get displayName => switch (this) {
        ThemeId.system => 'Sistema',
        ThemeId.light => 'Claro',
        ThemeId.dark => 'Oscuro',
        ThemeId.pixelArt => 'Pixel Art',
        ThemeId.amoled => 'AMOLED',
        ThemeId.cyberpunk => 'Cyberpunk',
        ThemeId.minimal => 'Minimalista',
      };

  bool get followsSystem => this == ThemeId.system;

  bool get isCustomStyle =>
      this == ThemeId.pixelArt ||
      this == ThemeId.amoled ||
      this == ThemeId.cyberpunk ||
      this == ThemeId.minimal;

  static ThemeId? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final id in ThemeId.values) {
      if (id.storageId == value || id.name == value) return id;
    }
    return null;
  }

  /// Legacy [ThemePreference] indices before string persistence.
  static ThemeId fromLegacyIndex(int index) {
    return switch (index) {
      0 => ThemeId.system,
      1 => ThemeId.light,
      2 => ThemeId.dark,
      3 => ThemeId.pixelArt,
      _ => ThemeId.system,
    };
  }
}

/// Backward-compatible alias used across the app.
typedef ThemePreference = ThemeId;
