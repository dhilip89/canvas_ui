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
}
