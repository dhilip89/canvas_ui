part of canvas_ui;

class _PaintData {
  bool isAntiAlias = true;
  Color color = new Color.fromARGB(255, 0, 0, 0);
  TransferMode transferMode = TransferMode.srcOver;
  PaintingStyle paintingStyle = PaintingStyle.fill;
  double strokeWidth = 0.0;
  StrokeCap strokeCap = StrokeCap.butt;
  FilterQuality filterQuality = FilterQuality.none;
  ColorFilter colorFilter = null;
  MaskFilter maskFilter = null;
  Shader shader = null;
}
