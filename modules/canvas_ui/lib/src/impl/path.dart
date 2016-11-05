part of canvas_ui;

abstract class _PathCommand {}

// https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/moveTo
class _MoveToCommand extends _PathCommand {
  double _x;
  double _y;

  _MoveToCommand(this._x, this._y);
}

// https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/lineTo
class _LineToCommand extends _PathCommand {
  double _x;
  double _y;

  _LineToCommand(this._x, this._y);
}

// https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/quadraticCurveTo
class _QuadraticBezierToCommand extends _PathCommand {
  double _cpx;
  double _cpy;

  double _x;
  double _y;

  _QuadraticBezierToCommand(this._cpx, this._cpy, this._x, this._y);
}

// https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/bezierCurveTo
class _CubicBezierToCommand extends _PathCommand {
  double _cp1x;
  double _cp1y;

  double _cp2x;
  double _cp2y;

  double _x;
  double _y;

  _CubicBezierToCommand(
      this._cp1x, this._cp1y, this._cp2x, this._cp2y, this._x, this._y);
}

// https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/rect
class _RectCommand extends _PathCommand {
  double _x;
  double _y;

  double _width;
  double _height;

  _RectCommand(this._x, this._y, this._width, this._height);
}

class _Path implements Path {
  PathFillType _fillType = PathFillType.winding;

  double _posX = 0.0;
  double _posY = 0.0;

  List<_PathCommand> _commands = <_PathCommand>[];

  _Path() {}

  PathFillType get fillType => _fillType;

  set fillType(PathFillType value) => _fillType = value;

  void moveTo(double x, double y) {
    _posX = x;
    _posY = y;

    _commands.add(new _MoveToCommand(_posX, _posY));
  }

  void relativeMoveTo(double dx, double dy) {
    moveTo(_posX + dx, _posY + dy);
  }

  void lineTo(double x, double y) {
    _posX = x;
    _posY = y;

    _commands.add(new _LineToCommand(_posX, _posY));
  }

  void relativeLineTo(double dx, double dy) {
    lineTo(_posX + dx, _posY + dy);
  }

  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    _posX = x2;
    _posY = y2;

    _commands.add(new _QuadraticBezierToCommand(x1, y1, _posX, _posY));
  }

  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) {
    quadraticBezierTo(_posX + x1, _posY + y1, _posX + x2, _posY + y2);
  }

  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    _posX = x3;
    _posY = y3;

    _commands.add(new _CubicBezierToCommand(x1, y1, x2, y2, _posX, _posY));
  }

  void relativeCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    cubicTo(
        _posX + x1, _posY + y1, _posX + x2, _posY + y2, _posX + x3, _posY + y3);
  }

  void conicTo(double x1, double y1, double x2, double y2, double w) {
    //TODO: https://github.com/google/skia/blob/bdabcc4cb873dc4de39263c995900a05e6a32cf4/src/core/SkPath.cpp#L791
    throw new UnimplementedError();
  }

  void relativeConicTo(double x1, double y1, double x2, double y2, double w) {
    conicTo(_posX + x1, _posY + y1, _posX + x2, _posY + y2, w);
  }

  void arcTo(
      Rect rect, double startAngle, double sweepAngle, bool forceMoveTo) {
    throw new UnimplementedError();
  }

  void addRect(Rect rect) {
    _posX = rect.left;
    _posY = rect.top;

    _commands
        .add(new _RectCommand(rect.left, rect.top, rect.width, rect.height));
  }
}
