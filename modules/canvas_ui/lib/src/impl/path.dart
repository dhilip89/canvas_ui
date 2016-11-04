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
  double _controlX;
  double _controlY;

  double _x;
  double _y;

  _QuadraticBezierToCommand(this._controlX, this._controlY, this._x, this._y);
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
    _posX += dx;
    _posY += dy;

    _commands.add(new _MoveToCommand(_posX, _posY));
  }

  void lineTo(double x, double y) {
    _posX = x;
    _posY = y;

    _commands.add(new _LineToCommand(_posX, _posY));
  }

  void relativeLineTo(double dx, double dy) {
    _posX += dx;
    _posY += dy;

    _commands.add(new _LineToCommand(_posX, _posY));
  }

  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    _posX = x2;
    _posY = y2;

    _commands.add(new _QuadraticBezierToCommand(x1, y1, _posX, _posY));
  }

  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) {
    double controlX = _posX + x1;
    double controlY = _posY + y1;

    _posX += x2;
    _posY += y2;

    _commands
        .add(new _QuadraticBezierToCommand(controlX, controlY, _posX, _posY));
  }
}
