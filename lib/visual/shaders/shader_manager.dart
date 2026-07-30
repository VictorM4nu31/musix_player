import 'shader_type.dart';

/// Coordinates shader effect lifecycle.
/// GLSL .frag assets are declared for future hardware-accelerated rendering;
/// the primary implementation uses Canvas-based shader simulations (see [ShaderPainter]).
class ShaderManager {
  ShaderManager({required this.effectType});

  final ShaderEffectType effectType;

  bool get isLoaded => false;

  Future<void> ensureLoaded() async {}

  void dispose() {}
}
