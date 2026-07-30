import 'package:flutter/material.dart';
import '../models/visualizer_frame.dart';
import '../models/visualizer_type.dart';
import '../renderers/visualizer_renderer.dart';
import 'cover_flow_widget.dart';

class CoverFlowRenderer extends VisualizerRenderer {
  const CoverFlowRenderer();

  @override
  VisualizerType get type => VisualizerType.coverFlow;

  @override
  Widget build(BuildContext context, VisualizerFrame frame) {
    return CoverFlowWidget(frame: frame);
  }
}
