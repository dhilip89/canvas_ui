// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the CHROMIUM_LICENSE file.

part of canvas_ui;

Color _scaleAlpha(Color a, double factor) {
  return a.withAlpha((a.alpha * factor).round());
}

/// An immutable 32 bit color value in ARGB
class Color {
  /// Construct a color from the lower 32 bits of an int.
  ///
  /// Bits 24-31 are the alpha value.
  /// Bits 16-23 are the red value.
  /// Bits 8-15 are the green value.
  /// Bits 0-7 are the blue value.
  const Color(int value) : value = value & 0xFFFFFFFF;

  /// Construct a color from the lower 8 bits of four integers.
  ///
  /// * `a` is the alpha value, with 0 being transparent and 255 being fully
  ///   opaque.
  /// * `r` is [red], from 0 to 255.
  /// * `g` is [red], from 0 to 255.
  /// * `b` is [red], from 0 to 255.
  ///
  /// Out of range values are brought into range using modulo 255.
  ///
  /// See also [fromARGB], which takes the alpha value as a floating point
  /// value.
  const Color.fromARGB(int a, int r, int g, int b)
      : value = ((((a & 0xff) << 24) |
                ((r & 0xff) << 16) |
                ((g & 0xff) << 8) |
                ((b & 0xff) << 0)) &
            0xFFFFFFFF);

  /// Create a color from red, green, blue, and opacity, similar to `rgba()` in CSS.
  ///
  /// * `r` is [red], from 0 to 255.
  /// * `g` is [red], from 0 to 255.
  /// * `b` is [red], from 0 to 255.
  /// * `opacity` is alpha channel of this color as a double, with 0.0 being
  ///   transparent and 1.0 being fully opaque.
  ///
  /// Out of range values are brought into range using modulo 255.
  ///
  /// See also [fromARGB], which takes the opacity as an integer value.
  const Color.fromRGBO(int r, int g, int b, double opacity)
      : value = (((((opacity * 0xff ~/ 1) & 0xff) << 24) |
                ((r & 0xff) << 16) |
                ((g & 0xff) << 8) |
                ((b & 0xff) << 0)) &
            0xFFFFFFFF);

  /// A 32 bit value representing this color.
  ///
  /// Bits 24-31 are the alpha value.
  /// Bits 16-23 are the red value.
  /// Bits 8-15 are the green value.
  /// Bits 0-7 are the blue value.
  final int value;

  /// The alpha channel of this color in an 8 bit value.
  ///
  /// A value of 0 means this color is fully transparent. A value of 255 means
  /// this color is fully opaque.
  int get alpha => (0xff000000 & value) >> 24;

  /// The alpha channel of this color as a double.
  ///
  /// A value of 0.0 means this color is fully transparent. A value of 1.0 means
  /// this color is fully opaque.
  double get opacity => alpha / 0xFF;

  /// The red channel of this color in an 8 bit value.
  int get red => (0x00ff0000 & value) >> 16;

  /// The green channel of this color in an 8 bit value.
  int get green => (0x0000ff00 & value) >> 8;

  /// The blue channel of this color in an 8 bit value.
  int get blue => (0x000000ff & value) >> 0;

  /// Returns a new color that matches this color with the alpha channel
  /// replaced with a (which ranges from 0 to 255).
  Color withAlpha(int a) {
    return new Color.fromARGB(a, red, green, blue);
  }

  /// Returns a new color that matches this color with the alpha channel
  /// replaced with the given opacity (which ranges from 0.0 to 1.0).
  Color withOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return withAlpha((255.0 * opacity).round());
  }

  /// Returns a new color that matches this color with the red channel replaced
  /// with r.
  Color withRed(int r) {
    return new Color.fromARGB(alpha, r, green, blue);
  }

  /// Returns a new color that matches this color with the green channel
  /// replaced with g.
  Color withGreen(int g) {
    return new Color.fromARGB(alpha, red, g, blue);
  }

  /// Returns a new color that matches this color with the blue channel replaced
  /// with b.
  Color withBlue(int b) {
    return new Color.fromARGB(alpha, red, green, b);
  }

  /// Linearly interpolate between two colors
  ///
  /// If either color is null, this function linearly interpolates from a
  /// transparent instance of the other color.
  static Color lerp(Color a, Color b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return _scaleAlpha(b, t);
    if (b == null) return _scaleAlpha(a, 1.0 - t);
    return new Color.fromARGB(
        lerpDouble(a.alpha, b.alpha, t).toInt(),
        lerpDouble(a.red, b.red, t).toInt(),
        lerpDouble(a.green, b.green, t).toInt(),
        lerpDouble(a.blue, b.blue, t).toInt());
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! Color) return false;
    final Color typedOther = other;
    return value == typedOther.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => "Color(0x${value.toRadixString(16).padLeft(8, '0')})";
}

/// Algorithms to use when painting on the canvas.
///
/// When drawing a shape or image onto a canvas, different algorithms
/// can be used to blend the pixels. The image below shows the effects
/// of these modes.
///
/// [![Open Skia fiddle to view image.](https://flutter.io/images/transfer_mode.png)](https://fiddle.skia.org/c/864acd0659c7a866ea7296a3184b8bdd)
///
/// See [Paint.transferMode].
enum TransferMode {
  // This list comes from Skia's SkXfermode.h and the values (order) should be
  // kept in sync.
  // See: https://skia.org/user/api/skpaint#SkXfermode

  clear,
  src,
  dst,
  srcOver,
  dstOver,
  srcIn,
  dstIn,
  srcOut,
  dstOut,
  srcATop,
  dstATop,
  xor,
  plus,
  modulate,

  // Following blend modes are defined in the CSS Compositing standard.

  screen, // The last coeff mode.

  overlay,
  darken,
  lighten,
  colorDodge,
  colorBurn,
  hardLight,
  softLight,
  difference,
  exclusion,
  multiply, // The last separable mode.

  hue,
  saturation,
  color,
  luminosity,
}

/// Quality levels for image filters.
///
/// See [Paint.filterQuality].
enum FilterQuality {
  // This list comes from Skia's SkFilterQuality.h and the values (order) should
  // be kept in sync.

  /// Fastest possible filtering, albeit also the lowest quality.
  ///
  /// Typically this implies nearest-neighbour filtering.
  none,

  /// Better quality than [none], faster than [medium].
  ///
  /// Typically this implies bilinear interpolation.
  low,

  /// Better quality than [low], faster than [high].
  ///
  /// Typically this implies a combination of bilinear interpolation and
  /// pyramidal parametric prefiltering (mipmaps).
  medium,

  /// Best possible quality filtering, albeit also the slowest.
  ///
  /// Typically this implies bicubic interpolation or better.
  high,
}

/// Styles to use for line endings.
///
/// See [Paint.strokeCap].
enum StrokeCap {
  /// Begin and end contours with a flat edge and no extension.
  butt,

  /// Begin and end contours with a semi-circle extension.
  round,

  /// Begin and end contours with a half square extension. This is
  /// similar to extending each contour by half the stroke width (as
  /// given by [Paint.strokeWidth]).
  square,
}

/// Strategies for painting shapes and paths on a canvas.
///
/// See [Paint.style].
enum PaintingStyle {
  // This list comes from Skia's SkPaint.h and the values (order) should be kept
  // in sync.

  /// Apply the [Paint] to the inside of the shape. For example, when
  /// applied to the [Paint.drawCircle] call, this results in a disc
  /// of the given size being painted.
  fill,

  /// Apply the [Paint] to the edge of the shape. For example, when
  /// applied to the [Paint.drawCircle] call, this results is a hoop
  /// of the given size being painted. The line drawn on the edge will
  /// be the width given by the [Paint.strokeWidth] property.
  stroke,
}

/// A description of the style to use when drawing on a [Canvas].
///
/// Most APIs on [Canvas] take a [Paint] object to describe the style
/// to use for that operation.
class Paint {
  bool _isAntiAlias = true;
  Color _color = new Color.fromARGB(255, 0, 0, 0);
  TransferMode _transferMode = TransferMode.srcOver;
  PaintingStyle _paintingStyle = PaintingStyle.fill;
  double _strokeWidth = 0.0;
  StrokeCap _strokeCap = StrokeCap.butt;
  FilterQuality _filterQuality = FilterQuality.none;
  ColorFilter _colorFilter = null;
  MaskFilter _maskFilter = null;
  Shader _shader = null;

  /// Whether to apply anti-aliasing to lines and images drawn on the
  /// canvas.
  ///
  /// Defaults to true.
  bool get isAntiAlias => _isAntiAlias;

  set isAntiAlias(bool value) {
    _isAntiAlias = value;
  }

  /// The color to use when stroking or filling a shape.
  ///
  /// Defaults to opaque black.
  ///
  /// See also:
  ///
  ///  * [style], which controls whether to stroke or fill (or both).
  ///  * [colorFilter], which overrides [color].
  ///  * [shader], which overrides [color] with more elaborate effects.
  ///
  /// This color is not used when compositing. To colorize a layer, use
  /// [colorFilter].
  Color get color => _color;

  set color(Color value) {
    assert(value != null);
    _color = value;
  }

  /// A transfer mode to apply when a shape is drawn or a layer is composited.
  ///
  /// The source colors are from the shape being drawn (e.g. from
  /// [Canvas.drawPath]) or layer being composited (the graphics that were drawn
  /// between the [Canvas.saveLayer] and [Canvas.restore] calls), after applying
  /// the [colorFilter], if any.
  ///
  /// The destination colors are from the background onto which the shape or
  /// layer is being composited.
  ///
  /// Defaults to [TransferMode.srcOver].
  TransferMode get transferMode => _transferMode;

  set transferMode(TransferMode value) {
    assert(value != null);
    _transferMode = value;
  }

  /// Whether to paint inside shapes, the edges of shapes, or both.
  ///
  /// Defaults to [PaintingStyle.fill].
  PaintingStyle get style => _paintingStyle;

  set style(PaintingStyle value) {
    assert(value != null);
    _paintingStyle = value;
  }

  /// How wide to make edges drawn when [style] is set to
  /// [PaintingStyle.stroke]. The width is given in logical pixels measured in
  /// the direction orthogonal to the direction of the path.
  ///
  /// Defaults to 0.0, which correspond to a hairline width.
  double get strokeWidth => _strokeWidth;

  set strokeWidth(double value) {
    assert(value != null);
    _strokeWidth = value;
  }

  /// The kind of finish to place on the end of lines drawn when
  /// [style] is set to [PaintingStyle.stroke].
  ///
  /// Defaults to [StrokeCap.butt], i.e. no caps.
  StrokeCap get strokeCap => _strokeCap;

  set strokeCap(StrokeCap value) {
    assert(value != null);
    _strokeCap = value;
  }

  /// A mask filter (for example, a blur) to apply to a shape after it has been
  /// drawn but before it has been composited into the image.
  ///
  /// See [MaskFilter] for details.
  MaskFilter get maskFilter => _maskFilter;

  set maskFilter(MaskFilter value) {
    _maskFilter = value;
  }

  /// Controls the performance vs quality trade-off to use when applying
  /// filters, such as [maskFilter], or when drawing images, as with
  /// [Canvas.drawImageRect] or [Canvas.drawImageNine].
  ///
  /// Defaults to [FilterQuality.none].
  // TODO(ianh): verify that the image drawing methods actually respect this
  FilterQuality get filterQuality => _filterQuality;

  set filterQuality(FilterQuality value) {
    assert(value != null);
    _filterQuality = value;
  }

  /// The shader to use when stroking or filling a shape.
  ///
  /// When this is null, the [color] is used instead.
  ///
  /// See also:
  ///
  ///  * [Gradient], a shader that paints a color gradient.
  ///  * [ImageShader], a shader that tiles an [Image].
  ///  * [colorFilter], which overrides [shader].
  ///  * [color], which is used if [shader] and [colorFilter] are null.
  Shader get shader => _shader;

  set shader(Shader value) {
    _shader = value;
  }

  /// A color filter to apply when a shape is drawn or when a layer is
  /// composited.
  ///
  /// See [ColorFilter] for details.
  ///
  /// When a shape is being drawn, [colorFilter] overrides [color] and [shader].
  ColorFilter get colorFilter => _colorFilter;

  set colorFilter(ColorFilter value) {
    if (value != null) {
      assert(value._color != null);
      assert(value._transferMode != null);
    }
    _colorFilter = value;
  }

  @override
  String toString() {
    StringBuffer result = new StringBuffer();
    String semicolon = '';
    result.write('Paint(');
    if (style == PaintingStyle.stroke) {
      result.write('$style');
      if (strokeWidth != 0.0)
        result.write(' $strokeWidth');
      else
        result.write(' hairline');
      if (strokeCap != StrokeCap.butt) result.write(' $strokeCap');
      semicolon = '; ';
    }
    if (isAntiAlias != true) {
      result.write('${semicolon}antialias off');
      semicolon = '; ';
    }
    if (color != const Color(0xFF000000)) {
      if (color != null)
        result.write('$semicolon$color');
      else
        result.write('${semicolon}no color');
      semicolon = '; ';
    }
    if (transferMode != TransferMode.srcOver) {
      result.write('$semicolon$transferMode');
      semicolon = '; ';
    }
    if (colorFilter != null) {
      result.write('${semicolon}colorFilter: $colorFilter');
      semicolon = '; ';
    }
    if (maskFilter != null) {
      result.write('${semicolon}maskFilter: $maskFilter');
      semicolon = '; ';
    }
    if (filterQuality != FilterQuality.none) {
      result.write('${semicolon}filterQuality: $filterQuality');
      semicolon = '; ';
    }
    if (shader != null) result.write('${semicolon}shader: $shader');
    result.write(')');
    return result.toString();
  }
}

/// Opaque handle to raw decoded image data (pixels).
///
/// To obtain an Image object, use [decodeImageFromList].
///
/// To draw an Image, use one of the methods on the [Canvas] class, such as
/// [drawImage].
abstract class Image {
  /// The number of image pixels along the image's horizontal axis.
  int get width => throw new UnimplementedError();

  /// The number of image pixels along the image's vertical axis.
  int get height => throw new UnimplementedError();

  /// Release the resources used by this object. The object is no longer usable
  /// after this method is called.
  void dispose() => throw new UnimplementedError();

  @override
  String toString() => '[$width\u00D7$height]';
}

/// Callback signature for [decodeImageFromList].
typedef void ImageDecoderCallback(Image result);

/// Convert an image file from a byte array into an [Image] object.
void decodeImageFromList(Uint8List list, ImageDecoderCallback callback) =>
    throw new UnimplementedError();

/// Determines how the interior of a [Path] is calculated.
enum PathFillType {
  /// The interior is defined by a non-zero sum of signed edge crossings.
  winding,

  /// The interior is defined by an odd number of edge crossings.
  evenOdd,
}

/// A complex, one-dimensional subset of a plane.
///
/// A path consists of a number of subpaths, and a _current point_.
///
/// Subpaths consist of segments of various types, such as lines,
/// arcs, or beziers. Subpaths can be open or closed, and can
/// self-intersect.
///
/// Closed subpaths enclose a (possibly discontiguous) region of the
/// plane based on whether a line from a given point on the plane to a
/// point at infinity intersects the path an even (non-enclosed) or an
/// odd (enclosed) number of times.
///
/// The _current point_ is initially at the origin. After each
/// operation adding a segment to a subpath, the current point is
/// updated to the end of that segment.
///
/// Paths can be drawn on canvases using [Canvas.drawPath], and can
/// used to create clip regions using [Canvas.clipPath].
abstract class Path {
  /// Create a new empty [Path] object.
  factory Path() => new _Path();

  /// Determines how the interior of this path is calculated.
  PathFillType get fillType;
  set fillType(PathFillType value);

  /// Starts a new subpath at the given coordinate.
  void moveTo(double x, double y);

  /// Starts a new subpath at the given offset from the current point.
  void relativeMoveTo(double dx, double dy);

  /// Adds a straight line segment from the current point to the given
  /// point.
  void lineTo(double x, double y);

  /// Adds a straight line segment from the current point to the point
  /// at the given offset from the current point.
  void relativeLineTo(double dx, double dy);

  /// Adds a quadratic bezier segment that curves from the current
  /// point to the given point (x2,y2), using the control point
  /// (x1,y1).
  void quadraticBezierTo(double x1, double y1, double x2, double y2);

  /// Adds a quadratic bezier segment that curves from the current
  /// point to the point at the offset (x2,y2) from the current point,
  /// using the control point at the offset (x1,y1) from the current
  /// point.
  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2);

  /// Adds a cubic bezier segment that curves from the current point
  /// to the given point (x3,y3), using the control points (x1,y1) and
  /// (x2,y2).
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3);

  /// Adds a cubcic bezier segment that curves from the current point
  /// to the point at the offset (x3,y3) from the current point, using
  /// the control points at the offsets (x1,y1) and (x2,y2) from the
  /// current point.
  void relativeCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3);

  /// Adds a bezier segment that curves from the current point to the
  /// given point (x2,y2), using the control points (x1,y1) and the
  /// weight w. If the weight is greater than 1, then the curve is a
  /// hyperbola; if the weight equals 1, it's a parabola; and if it is
  /// less than 1, it is an ellipse.
  void conicTo(double x1, double y1, double x2, double y2, double w);

  /// Adds a bezier segment that curves from the current point to the
  /// point at the offset (x2,y2) from the current point, using the
  /// control point at the offset (x1,y1) from the current point and
  /// the weight w. If the weight is greater than 1, then the curve is
  /// a hyperbola; if the weight equals 1, it's a parabola; and if it
  /// is less than 1, it is an ellipse.
  void relativeConicTo(double x1, double y1, double x2, double y2, double w);

  /// If the [forceMoveTo] argument is false, adds a straight line
  /// segment and an arc segment.
  ///
  /// If the [forceMoveTo] argument is true, starts a new subpath
  /// consisting of an arc segment.
  ///
  /// In either case, the arc segment consists of the arc that follows
  /// the edge of the oval bounded by the given rectangle, from
  /// startAngle radians around the oval up to startAngle + sweepAngle
  /// radians around the oval, with zero radians being the point on
  /// the right hand side of the oval that crosses the horizontal line
  /// that intersects the center of the rectangle and with positive
  /// angles going clockwise around the oval.
  ///
  /// The line segment added if [forceMoveTo] is false starts at the
  /// current point and ends at the start of the arc.
  void arcTo(Rect rect, double startAngle, double sweepAngle, bool forceMoveTo);

  /// Adds a new subpath that consists of four lines that outline the
  /// given rectangle.
  void addRect(Rect rect);

  /// Adds a new subpath that consists of a curve that forms the
  /// ellipse that fills the given rectangle.
  void addOval(Rect oval) => throw new UnimplementedError();

  /// Adds a new subpath with one arc segment that consists of the arc
  /// that follows the edge of the oval bounded by the given
  /// rectangle, from startAngle radians around the oval up to
  /// startAngle + sweepAngle radians around the oval, with zero
  /// radians being the point on the right hand side of the oval that
  /// crosses the horizontal line that intersects the center of the
  /// rectangle and with positive angles going clockwise around the
  /// oval.
  void addArc(Rect oval, double startAngle, double sweepAngle) =>
      throw new UnimplementedError();

  /// Adds a new subpath with a sequence of line segments that connect the given
  /// points. If `close` is true, a final line segment will be added that
  /// connects the last point to the first point.
  void addPolygon(List<Point> points, bool close) =>
      throw new UnimplementedError();

  /// Adds a new subpath that consists of the straight lines and
  /// curves needed to form the rounded rectangle described by the
  /// argument.
  void addRRect(RRect rrect) => throw new UnimplementedError();

  /// Adds a new subpath that consists of the given path offset by the given
  /// offset.
  void addPath(Path path, Offset offset) => throw new UnimplementedError();

  /// Adds the given path to this path by extending the current segment of this
  /// path with the the first segment of the given path.
  void extendWithPath(Path path, Offset offset) =>
      throw new UnimplementedError();

  /// Closes the last subpath, as if a straight line had been drawn
  /// from the current point to the first point of the subpath.
  void close() => throw new UnimplementedError();

  /// Clears the [Path] object of all subpaths, returning it to the
  /// same state it had when it was created. The _current point_ is
  /// reset to the origin.
  void reset() => throw new UnimplementedError();

  /// Tests to see if the point is within the path. (That is, whether
  /// the point would be in the visible portion of the path if the
  /// path was used with [Canvas.clipPath].)
  ///
  /// Returns true if the point is in the path, and false otherwise.
  bool contains(Point position) => throw new UnimplementedError();

  /// Returns a copy of the path with all the segments of every
  /// subpath translated by the given offset.
  Path shift(Offset offset) => throw new UnimplementedError();

  /// Returns a copy of the path with all the segments of every
  /// subpath transformed by the given matrix.
  Path transform(Float64List matrix4) {
    if (matrix4.length != 16)
      throw new ArgumentError("[matrix4] must have 16 entries.");
    throw new UnimplementedError();
  }
}

/// Styles to use for blurs in [MaskFilter] objects.
enum BlurStyle {
  // These mirror SkBlurStyle and must be kept in sync.

  /// Fuzzy inside and outside. This is useful for painting shadows that are
  /// offset from the shape that ostensibly is casting the shadow.
  normal,

  /// Solid inside, fuzzy outside. This corresponds to drawing the shape, and
  /// additionally drawing the blur. This can make objects appear brighter,
  /// maybe even as if they were fluorescent.
  solid,

  /// Nothing inside, fuzzy outside. This is useful for painting shadows for
  /// partially transparent shapes, when they are painted separately but without
  /// an offset, so that the shadow doesn't paint below the shape.
  outer,

  /// Fuzzy inside, nothing outside. This can make shapes appear to be lit from
  /// within.
  inner,
}

/// A mask filter to apply to shapes as they are painted. A mask filter is a
/// function that takes a bitmap of color pixels, and returns another bitmap of
/// color pixels.
///
/// Instances of this class are used with [Paint.maskFilter] on [Paint] objects.
class MaskFilter {
  /// Creates a mask filter that takes the shape being drawn and blurs it.
  ///
  /// This is commonly used to approximate shadows.
  ///
  /// The `style` argument controls the kind of effect to draw; see [BlurStyle].
  ///
  /// The `sigma` argument controls the size of the effect. It is the standard
  /// deviation of the Gaussian blur to apply. The value must be greater than
  /// zero. The sigma corresponds to very roughly half the radius of the effect
  /// in pixels.
  ///
  /// If the `ignoreTransform` argument is set, then the current transform is
  /// ignored when computing the blur. This makes the operation cheaper, but
  /// lowers the quality of the effect. In particular, it means that the sigma
  /// will be relative to the device pixel coordinate space, rather than the
  /// logical pixel coordinate space, which means the blur will look different
  /// on different devices.
  ///
  /// If the `highQuality` argument is set, then the quality of the blur may be
  /// slightly improved, at the cost of making the operation even more
  /// expensive.
  ///
  /// Even in the best conditions and with the lowest quality settings, a blur
  /// is an expensive operation and blurs should therefore be used sparingly.
  MaskFilter.blur(BlurStyle style, double sigma,
      {bool ignoreTransform: false, bool highQuality: false}) {
    throw new UnimplementedError();
  }
}

/// A description of a color filter to apply when drawing a shape or compositing
/// a layer with a particular [Paint]. A color filter is a function that takes
/// two colors, and outputs one color. When applied during compositing, it is
/// independently applied to each pixel of the layer being drawn before the
/// entire layer is merged with the destination.
///
/// Instances of this class are used with [Paint.colorFilter] on [Paint]
/// objects.
class ColorFilter {
  /// Creates a color filter that applies the transfer mode given as the second
  /// argument. The source color is the one given as the first argument, and the
  /// destination color is the one from the layer being composited.
  ///
  /// The output of this filter is then composited into the background according
  /// to the [Paint.transferMode], using the output of this filter as the source
  /// and the background as the destination.
  ColorFilter.mode(Color color, TransferMode transferMode)
      : _color = color,
        _transferMode = transferMode;

  final Color _color;
  final TransferMode _transferMode;

  @override
  bool operator ==(dynamic other) {
    if (other is! ColorFilter) return false;
    final ColorFilter typedOther = other;
    return _color == typedOther._color &&
        _transferMode == typedOther._transferMode;
  }

  @override
  int get hashCode => hashValues(_color, _transferMode);

  @override
  String toString() => "ColorFilter($_color, $TransferMode)";
}

/// A filter operation to apply to a raster image.
///
/// See [SceneBuilder.pushBackdropFilter].
class ImageFilter {
  /// A source filter containing an image.
  // ImageFilter.image({ Image image }) {
  //   _constructor();
  //   _initImage(image);
  // }
  // void _initImage(Image image) => throw new UnimplementedError();

  /// A source filter containing a picture.
  // ImageFilter.picture({ Picture picture }) {
  //   _constructor();
  //   _initPicture(picture);
  // }
  // void _initPicture(Picture picture) => throw new UnimplementedError();

  /// Creates an image filter that applies a Gaussian blur.
  ImageFilter.blur({double sigmaX: 0.0, double sigmaY: 0.0}) {
    throw new UnimplementedError();
  }
}

/// Base class for objects such as [Gradient] and [ImageShader] which
/// correspond to shaders as used by [Paint.shader].
abstract class Shader {}

/// Defines what happens at the edge of the gradient.
enum TileMode {
  /// Edge is clamped to the final color.
  clamp,

  /// Edge is repeated from first color to last.
  repeated,

  /// Edge is mirrored from last color to first.
  mirror,
}

/// A shader (as used by [Paint.shader]) that renders a color gradient.
///
/// There are two useful types of gradients, created by [new Gradient.linear]
/// and [new Griadent.radial].
class Gradient extends Shader {
  /// Creates a Gradient object that is not initialized.
  ///
  /// Use the [Gradient.linear] or [Gradient.radial] constructors to
  /// obtain a usable [Gradient] object.
  Gradient() {
    throw new UnimplementedError();
  }

  /// Creates a linear gradient from `endPoint[0]` to `endPoint[1]`. If
  /// `colorStops` is provided, `colorStops[i]` is a number from 0 to 1 that
  /// specifies where `color[i]` begins in the gradient. If `colorStops` is not
  /// provided, then two stops at 0.0 and 1.0 are implied. The behavior before
  /// and after the radius is described by the `tileMode` argument.
  // TODO(mpcomplete): Consider passing a list of (color, colorStop) pairs
  // instead.
  Gradient.linear(List<Point> endPoints, List<Color> colors,
      [List<double> colorStops = null, TileMode tileMode = TileMode.clamp]) {
    if (endPoints == null || endPoints.length != 2)
      throw new ArgumentError("Expected exactly 2 [endPoints].");
    _validateColorStops(colors, colorStops);
    throw new UnimplementedError();
  }

  /// Creates a radial gradient centered at `center` that ends at `radius`
  /// distance from the center. If `colorStops` is provided, `colorStops[i]` is
  /// a number from 0 to 1 that specifies where `color[i]` begins in the
  /// gradient. If `colorStops` is not provided, then two stops at 0.0 and 1.0
  /// are implied. The behavior before and after the radius is described by the
  /// `tileMode` argument.
  Gradient.radial(Point center, double radius, List<Color> colors,
      [List<double> colorStops = null, TileMode tileMode = TileMode.clamp]) {
    _validateColorStops(colors, colorStops);
    throw new UnimplementedError();
  }

  static void _validateColorStops(List<Color> colors, List<double> colorStops) {
    if (colorStops != null && colors.length != colorStops.length)
      throw new ArgumentError(
          "[colors] and [colorStops] parameters must be equal length.");
  }
}

/// A shader (as used by [Paint.shader]) that tiles an image.
class ImageShader extends Shader {
  /// Creates an image-tiling shader. The first argument specifies the image to
  /// tile. The second and third arguments specify the [TileMode] for the x
  /// direction and y direction respectively. The fourth argument gives the
  /// matrix to apply to the effect. All the arguments are required and must not
  /// be null.
  ImageShader(Image image, TileMode tmx, TileMode tmy, Float64List matrix4) {
    if (image == null)
      throw new ArgumentError("[image] argument cannot be null");
    if (tmx == null) throw new ArgumentError("[tmx] argument cannot be null");
    if (tmy == null) throw new ArgumentError("[tmy] argument cannot be null");
    if (matrix4 == null)
      throw new ArgumentError("[matrix4] argument cannot be null");
    if (matrix4.length != 16)
      throw new ArgumentError("[matrix4] must have 16 entries.");
    throw new UnimplementedError();
  }
}

/// Defines how a list of points is interpreted when drawing a set of triangles.
///
/// Used by [Canvas.drawVertices].
enum VertexMode {
  /// Draw each sequence of three points as the vertices of a triangle.
  triangles,

  /// Draw each sliding window of three points as the vertices of a triangle.
  triangleStrip,

  /// Draw the first point and each sliding window of two points as the vertices of a triangle.
  triangleFan,
}

/// Defines how a list of points is interpreted when drawing a set of points.
///
/// Used by [Canvas.drawPoints].
enum PointMode {
  /// Draw each point separately.
  ///
  /// If the [Paint.strokeCap] is [StrokeCat.round], then each point is drawn
  /// as a circle with the diameter of the [Paint.strokeWidth], filled as
  /// described by the [Paint] (ignoring [Paint.style]).
  ///
  /// Otherwise, each point is drawn as an axis-aligned square with sides of
  /// length [Paint.strokeWidth], filled as described by the [Paint] (ignoring
  /// [Paint.style]).
  points,

  /// Draw each sequence of two points as a line segment.
  ///
  /// If the number of points is odd, then the last point is ignored.
  ///
  /// The lines are stroked as described by the [Paint] (ignoring
  /// [Paint.style]).
  lines,

  /// Draw the entire sequence of point as one line.
  ///
  /// The lines are stroked as described by the [Paint] (ignoring
  /// [Paint.style]).
  polygon,
}

/// An interface for recording graphical operations.
///
/// [Canvas] objects are used in creating [Picture] objects, which can
/// themselves be used with a [SceneBuilder] to build a [Scene]. In
/// normal usage, however, this is all handled by the framework.
///
/// A canvas has a current transformation matrix which is applied to all
/// operations. Initially, the transformation matrix is the identity transform.
/// It can be modified using the [translate], [scale], [rotate], [skew],
/// [transform], and [setMatrix] methods.
///
/// A canvas also has a current clip region which is applied to all operations.
/// Initially, the clip region is infinite. It can be modified using the
/// [clipRect], [clipRRect], and [clipPath] methods.
///
/// The current transform and clip can be saved and restored using the stack
/// managed by the [save], [saveLayer], and [restore] methods.
class Canvas {
  /// Creates a canvas for recording graphical operations into the
  /// given picture recorder.
  ///
  /// Graphical operations that affect pixels entirely outside the given
  /// cullRect might be discarded by the implementation. However, the
  /// implementation might draw outside these bounds if, for example, a command
  /// draws partially inside and outside the cullRect. To ensure that pixels
  /// outside a given region are discarded, consider using a [clipRect].
  ///
  /// To end the recording, call [PictureRecorder.endRecording] on the
  /// given recorder.
  Canvas(PictureRecorder recorder, Rect cullRect) {
    if (recorder == null)
      throw new ArgumentError('The given PictureRecorder was null.');
    if (recorder.isRecording)
      throw new ArgumentError(
          'The given PictureRecorder is already associated with another Canvas.');
    // TODO(ianh): throw if recorder is defunct (https://github.com/flutter/flutter/issues/2531)
    throw new UnimplementedError();
  }

  /// Saves a copy of the current transform and clip on the save stack.
  ///
  /// Call [restore] to pop the save stack.
  void save() => throw new UnimplementedError();

  /// Saves a copy of the current transform and clip on the save stack, and then
  /// creates a new group which subsequent calls will become a part of. When the
  /// save stack is later popped, the group will be flattened into a layer and
  /// have the given `paint`'s [Paint.colorFilter] and [Paint.transferMode]
  /// applied.
  ///
  /// This lets you create composite effects, for example making a group of
  /// drawing commands semi-transparent. Without using [saveLayer], each part of
  /// the group would be painted individually, so where they overlap would be
  /// darker than where they do not. By using [saveLayer] to group them
  /// together, they can be drawn with an opaque color at first, and then the
  /// entire group can be made transparent using the [saveLayer]'s paint.
  ///
  /// Call [restore] to pop the save stack and apply the paint to the group.
  void saveLayer(Rect bounds, Paint paint) {
    if (bounds == null) {
      throw new UnimplementedError();
    } else {
      throw new UnimplementedError();
    }
  }

  /// Pops the current save stack, if there is anything to pop.
  /// Otherwise, does nothing.
  ///
  /// Use [save] and [saveLayer] to push state onto the stack.
  ///
  /// If the state was pushed with with [saveLayer], then this call will also
  /// cause the new layer to be composited into the previous layer.
  void restore() => throw new UnimplementedError();

  /// Returns the number of items on the save stack, including the
  /// initial state. This means it returns 1 for a clean canvas, and
  /// that each call to [save] and [saveLayer] increments it, and that
  /// each matching call to [restore] decrements it.
  ///
  /// This number cannot go below 1.
  int getSaveCount() => throw new UnimplementedError();

  /// Add a translation to the current transform, shifting the coordinate space
  /// horizontally by the first argument and vertically by the second argument.
  void translate(double dx, double dy) => throw new UnimplementedError();

  /// Add an axis-aligned scale to the current transform, scaling by the first
  /// argument in the horizontal direction and the second in the vertical
  /// direction.
  void scale(double sx, double sy) => throw new UnimplementedError();

  /// Add a rotation to the current transform. The argument is in radians clockwise.
  void rotate(double radians) => throw new UnimplementedError();

  /// Add an axis-aligned skew to the current transform, with the first argument
  /// being the horizontal skew in radians clockwise around the origin, and the
  /// second argument being the vertical skew in radians clockwise around the
  /// origin.
  void skew(double sx, double sy) => throw new UnimplementedError();

  /// Multiply the current transform by the specified 4⨉4 transformation matrix
  /// specified as a list of values in column-major order.
  void transform(Float64List matrix4) {
    if (matrix4.length != 16)
      throw new ArgumentError("[matrix4] must have 16 entries.");
    throw new UnimplementedError();
  }

  /// Replaces the current transform with the specified 4⨉4 transformation
  /// matrix specified as a list of values in column-major order.
  void setMatrix(Float64List matrix4) {
    if (matrix4.length != 16)
      throw new ArgumentError("[matrix4] must have 16 entries.");
    throw new UnimplementedError();
  }

  /// Reduces the clip region to the intersection of the current clip and the
  /// given rectangle.
  void clipRect(Rect rect) => throw new UnimplementedError();

  /// Reduces the clip region to the intersection of the current clip and the
  /// given rounded rectangle.
  void clipRRect(RRect rrect) => throw new UnimplementedError();

  /// Reduces the clip region to the intersection of the current clip and the
  /// given [Path].
  void clipPath(Path path) => throw new UnimplementedError();

  /// Paints the given [Color] onto the canvas, applying the given
  /// [TransferMode], with the given color being the source and the background
  /// being the destination.
  void drawColor(Color color, TransferMode transferMode) =>
      throw new UnimplementedError();

  /// Draws a line between the given [Point]s using the given paint. The line is
  /// stroked, the value of the [Paint.style] is ignored for this call.
  void drawLine(Point p1, Point p2, Paint paint) =>
      throw new UnimplementedError();

  /// Fills the canvas with the given [Paint].
  ///
  /// To fill the canvas with a solid color and transfer mode, consider
  /// [drawColor] instead.
  void drawPaint(Paint paint) => throw new UnimplementedError();

  /// Draws a rectangle with the given [Paint]. Whether the rectangle is filled
  /// or stroked (or both) is controlled by [Paint.style].
  void drawRect(Rect rect, Paint paint) => throw new UnimplementedError();

  /// Draws a rounded rectangle with the given [Paint]. Whether the rectangle is
  /// filled or stroked (or both) is controlled by [Paint.style].
  void drawRRect(RRect rrect, Paint paint) => throw new UnimplementedError();

  /// Draws a shape consisting of the difference between two rounded rectangles
  /// with the given [Paint]. Whether this shape is filled or stroked (or both)
  /// is controlled by [Paint.style].
  ///
  /// This shape is almost but not quite entirely unlike an annulus.
  void drawDRRect(RRect outer, RRect inner, Paint paint) =>
      throw new UnimplementedError();

  /// Draws an axis-aligned oval that fills the given axis-aligned rectangle
  /// with the given [Paint]. Whether the oval is filled or stroked (or both) is
  /// controlled by [Paint.style].
  void drawOval(Rect rect, Paint paint) => throw new UnimplementedError();

  /// Draws a circle centered at the point given by the first two arguments and
  /// that has the radius given by the third argument, with the [Paint] given in
  /// the fourth argument. Whether the circle is filled or stroked (or both) is
  /// controlled by [Paint.style].
  void drawCircle(Point c, double radius, Paint paint) =>
      throw new UnimplementedError();

  /// Draw an arc scaled to fit inside the given rectangle. It starts from
  /// startAngle radians around the oval up to startAngle + sweepAngle
  /// radians around the oval, with zero radians being the point on
  /// the right hand side of the oval that crosses the horizontal line
  /// that intersects the center of the rectangle and with positive
  /// angles going clockwise around the oval. If useCenter is true, the arc is
  /// closed back to the center, forming a circle sector. Otherwise, the arc is
  /// not closed, forming a circle segment.
  ///
  /// This method is optimized for drawing arcs and should be faster than [Path.arcTo].
  void drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter,
          Paint paint) =>
      throw new UnimplementedError();

  /// Draws the given [Path] with the given [Paint]. Whether this shape is
  /// filled or stroked (or both) is controlled by [Paint.style]. If the path is
  /// filled, then subpaths within it are implicitly closed (see [Path.close]).
  void drawPath(Path path, Paint paint) => throw new UnimplementedError();

  /// Draws the given [Image] into the canvas with its top-left corner at the
  /// given [Point]. The image is composited into the canvas using the given [Paint].
  void drawImage(Image image, Point p, Paint paint) =>
      throw new UnimplementedError();

  /// Draws the subset of the given image described by the `src` argument into
  /// the canvas in the axis-aligned rectangle given by the `dst` argument.
  ///
  /// This might sample from outside the `src` rect by up to half the width of
  /// an applied filter.
  void drawImageRect(Image image, Rect src, Rect dst, Paint paint) =>
      throw new UnimplementedError();

  /// Draws the given [Image] into the canvas using the given [Paint].
  ///
  /// The image is drawn in nine portions described by splitting the image by
  /// drawing two horizontal lines and two vertical lines, where the `center`
  /// argument describes the rectangle formed by the four points where these
  /// four lines intersect each other. (This forms a 3-by-3 grid of regions,
  /// the center region being described by the `center` argument.)
  ///
  /// The four regions in the corners are drawn, without scaling, in the four
  /// corners of the destination rectangle described by `dst`. The remaining
  /// five regions are drawn by stretching them to fit such that they exactly
  /// cover the destination rectangle while maintaining their relative
  /// positions.
  void drawImageNine(Image image, Rect center, Rect dst, Paint paint) =>
      throw new UnimplementedError();

  /// Draw the given picture onto the canvas. To create a picture, see
  /// [PictureRecorder].
  void drawPicture(Picture picture) => throw new UnimplementedError();

  /// Draws the text in the given paragraph into this canvas at the given offset.
  ///
  /// Valid only after [Paragraph.layout] has been called on the paragraph.
  void drawParagraph(Paragraph paragraph, Offset offset) =>
      throw new UnimplementedError();

  /// Draws a sequence of points according to the given [PointMode].
  void drawPoints(PointMode pointMode, List<Point> points, Paint paint) =>
      throw new UnimplementedError();

  void drawVertices(
      VertexMode vertexMode,
      List<Point> vertices,
      List<Point> textureCoordinates,
      List<Color> colors,
      TransferMode transferMode,
      List<int> indicies,
      Paint paint) {
    final int vertexCount = vertices.length;

    if (textureCoordinates.isNotEmpty &&
        textureCoordinates.length != vertexCount)
      throw new ArgumentError(
          "[vertices] and [textureCoordinates] lengths must match");
    if (colors.isNotEmpty && colors.length != vertexCount)
      throw new ArgumentError("[vertices] and [colors] lengths must match");

    throw new UnimplementedError();
  }

  // TODO(eseidel): Paint should be optional, but optional doesn't work.
  void drawAtlas(
      Image atlas,
      List<RSTransform> transforms,
      List<Rect> rects,
      List<Color> colors,
      TransferMode transferMode,
      Rect cullRect,
      Paint paint) {
    final int rectCount = rects.length;

    if (transforms.length != rectCount)
      throw new ArgumentError("[transforms] and [rects] lengths must match");
    if (colors.isNotEmpty && colors.length != rectCount)
      throw new ArgumentError(
          "if supplied, [colors] length must match that of [transforms] and [rects]");

    throw new UnimplementedError();
  }
}

/// An object representing a sequence of recorded graphical operations.
///
/// To create a [Picture], use a [PictureRecorder].
///
/// A [Picture] can be placed in a [Scene] using a [SceneBuilder], via
/// the [SceneBuilder.addPicture] method. A [Picture] can also be
/// drawn into a [Canvas], using the [Canvas.drawPicture] method.
abstract class Picture {
  /// Creates an uninitialized Picture object.
  ///
  /// Calling the Picture constructor directly will not create a useable
  /// object. To create a Picture object, use a [PictureRecorder].
  Picture(); // (this constructor is here just so we can document it)

  /// Release the resources used by this object. The object is no longer usable
  /// after this method is called.
  void dispose() => throw new UnimplementedError();
}

/// Records a [Picture] containing a sequence of graphical operations.
///
/// To begin recording, construct a [Canvas] to record the commands.
/// To end recording, use the [PictureRecorder.endRecording] method.
class PictureRecorder {
  /// Creates a new idle PictureRecorder. To associate it with a
  /// [Canvas] and begin recording, pass this [PictureRecorder] to the
  /// [Canvas] constructor.
  PictureRecorder() {
    throw new UnimplementedError();
  }

  /// Whether this object is currently recording commands.
  ///
  /// Specifically, this returns true if a [Canvas] object has been
  /// created to record commands and recording has not yet ended via a
  /// call to [endRecording], and false if either this
  /// [PictureRecorder] has not yet been associated with a [Canvas],
  /// or the [endRecording] method has already been called.
  bool get isRecording => throw new UnimplementedError();

  /// Finishes recording graphical operations.
  ///
  /// Returns a picture containing the graphical operations that have been
  /// recorded thus far. After calling this function, both the picture recorder
  /// and the canvas objects are invalid and cannot be used further.
  ///
  /// Returns null if the PictureRecorder is not associated with a canvas.
  Picture endRecording() => throw new UnimplementedError();
}
