import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:html';
import 'package:canvas_ui/canvas_ui.dart' as canvas_ui;

void beginFrame(Duration timeStamp) {
  final double devicePixelRatio = canvas_ui.window.devicePixelRatio;

  // PAINT
  final canvas_ui.Size logicalSize =
      canvas_ui.window.physicalSize / devicePixelRatio;
  final canvas_ui.Rect paintBounds = canvas_ui.Point.origin & logicalSize;
  final canvas_ui.PictureRecorder recorder = new canvas_ui.PictureRecorder();
  final canvas_ui.Canvas canvas = new canvas_ui.Canvas(recorder, paintBounds);
  canvas.translate(paintBounds.width / 2.0, paintBounds.height / 2.0);

  // Here we determine the rotation according to the timeStamp given to us by
  // the engine.
  final double t =
      timeStamp.inMicroseconds / Duration.MICROSECONDS_PER_MILLISECOND / 1800.0;
  canvas.rotate(math.PI * (t % 1.0));

  canvas.drawRect(
      new canvas_ui.Rect.fromLTRB(-100.0, -100.0, 100.0, 100.0),
      new canvas_ui.Paint()
        ..color = const canvas_ui.Color.fromARGB(255, 0, 255, 0));
  final canvas_ui.Picture picture = recorder.endRecording();

  // COMPOSITE

  final Float64List deviceTransform = new Float64List(16)
    ..[0] = devicePixelRatio
    ..[5] = devicePixelRatio
    ..[10] = 1.0
    ..[15] = 1.0;
  final canvas_ui.SceneBuilder sceneBuilder = new canvas_ui.SceneBuilder()
    ..pushTransform(deviceTransform)
    ..addPicture(canvas_ui.Offset.zero, picture)
    ..pop();
  canvas_ui.window.render(sceneBuilder.build());

  // After rendering the current frame of the animation, we ask the engine to
  // schedule another frame. The engine will call beginFrame again when its time
  // to produce the next frame.
  canvas_ui.window.scheduleFrame();
}

void main() {
  CanvasElement stage = document.querySelector('#stage');
  canvas_ui.initCanvasUI(stage);

  canvas_ui.window.onBeginFrame = beginFrame;
  canvas_ui.window.scheduleFrame();
}
