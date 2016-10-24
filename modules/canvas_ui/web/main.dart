import 'package:canvas_ui/canvas_ui.dart' as canvas_ui;
import 'dart:html';

void main() {
  CanvasElement stage = document.querySelector('#stage');

  canvas_ui.CanvasUI canvasUI = new canvas_ui.CanvasUI(stage);
}
