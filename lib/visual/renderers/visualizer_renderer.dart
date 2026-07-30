import 'package:flutter/material.dart';
import '../models/visual_quality.dart';
import '../models/visualizer_frame.dart';
import '../models/visualizer_type.dart';

abstract class VisualizerRenderer {
  const VisualizerRenderer();

  VisualizerType get type;

  Set<VisualQuality> get supportedQualities => VisualQuality.values.toSet();

  Widget build(BuildContext context, VisualizerFrame frame);
}
