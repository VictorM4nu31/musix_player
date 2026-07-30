import 'package:flutter/services.dart' show rootBundle;

enum ShaderEffectType {
  aurora,
  ripple,
  neon;

  String get assetPath => 'shaders/$name.frag';

  String get displayName => switch (this) {
        ShaderEffectType.aurora => 'Aurora',
        ShaderEffectType.ripple => 'Ondas',
        ShaderEffectType.neon => 'Neón',
      };

  static ShaderEffectType tryParse(String? value) {
    if (value == null || value.isEmpty) return ShaderEffectType.aurora;
    for (final t in ShaderEffectType.values) {
      if (t.name == value) return t;
    }
    return ShaderEffectType.aurora;
  }

  Future<bool> checkAssetExists() async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }
}
