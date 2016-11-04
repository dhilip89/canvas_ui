part of canvas_ui;

abstract class _PathCommand {}

class _MoveToCommand extends _PathCommand {
  double _x;
  double _y;

  _MoveToCommand(this._x, this._y);
}

class _LineToCommand extends _PathCommand {
  double _x;
  double _y;

  _LineToCommand(this._x, this._y);
}

class _QuadraticBezierToCommand extends _PathCommand {
  double _cX;
  double _cY;

  double _x;
  double _y;

  _QuadraticBezierToCommand(this._cX, this._cY, this._x, this._y);
}

class _CubicBezierToCommand extends _PathCommand {
  double _c1X;
  double _c1Y;

  double _c2X;
  double _c2Y;

  double _x;
  double _y;

  _CubicBezierToCommand(
      this._c1X, this._c1Y, this._c2X, this._c2Y, this._x, this._y);
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

    _commands.add(new _CubicBezierToCommand(c1X, c1Y, c2X, c2Y, _posX, _posY));
  }
}
