import 'package:canvas_ui/canvas_ui.dart' as canvas_ui;
import 'package:flutter/widgets.dart';

import 'dart:html' as html;

void main() {
  html.CanvasElement stage = html.document.querySelector('#stage');

  canvas_ui.CanvasUI canvasUI = new canvas_ui.CanvasUI(stage);

  runApp(new Center(child: new Text('Hello, world!')));
}
