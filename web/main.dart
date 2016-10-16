import 'package:canvas_ui/canvas_ui.dart' as canvas_ui;
import 'dart:html';

void main() {
  CanvasElement stage = document.querySelector('#stage');

  canvas_ui.setupCanvasUI(stage);

  window.console.log(window.navigator.language);
  window.console.log(window.navigator.languages);
}
