import 'package:flutter/material.dart';
import '../models/visualizer_frame.dart';
import '../models/visualizer_type.dart';
import 'visualizer_renderer.dart';

class NoneRenderer extends VisualizerRenderer {
  const NoneRenderer();

  @override
  VisualizerType get type => VisualizerType.none;

  @override
  Widget build(BuildContext context, VisualizerFrame frame) => frame.artwork;
}
