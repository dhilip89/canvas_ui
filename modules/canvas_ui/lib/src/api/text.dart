// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the CHROMIUM_LICENSE file.

part of canvas_ui;

/// Whether to slant the glyphs in the font
enum FontStyle {
  /// Use the upright glyphs
  normal,

  /// Use glyphs designed for slanting
  italic,
}

/// The thickness of the glyphs used to draw the text
class FontWeight {
  const FontWeight._(this.index);

  /// The encoded integer value of this font weight.
  final int index;

  /// Thin, the least thick
  static const FontWeight w100 = const FontWeight._(0);

  /// Extra-light
  static const FontWeight w200 = const FontWeight._(1);

  /// Light
  static const FontWeight w300 = const FontWeight._(2);

  /// Normal / regular / plain
  static const FontWeight w400 = const FontWeight._(3);

  /// Medium
  static const FontWeight w500 = const FontWeight._(4);

  /// Semi-bold
  static const FontWeight w600 = const FontWeight._(5);

  /// Bold
  static const FontWeight w700 = const FontWeight._(6);

  /// Extra-bold
  static const FontWeight w800 = const FontWeight._(7);

  /// Black, the most thick
  static const FontWeight w900 = const FontWeight._(8);

  /// The default font weight.
  static const FontWeight normal = w400;

  /// A commonly used font weight that is heavier than normal.
  static const FontWeight bold = w700;

  /// A list of all the font weights.
  static const List<FontWeight> values = const [
    w100,
    w200,
    w300,
    w400,
    w500,
    w600,
    w700,
    w800,
    w900
  ];

  /// Linearly interpolates between two font weights.
  ///
  /// Rather than using fractional weights, the interpolation rounds to the
  /// nearest weight.
  static FontWeight lerp(FontWeight begin, FontWeight end, double t) {
    return values[lerpDouble(begin?.index ?? normal.index,
            end?.index ?? normal.index, t.clamp(0.0, 1.0))
        .round()];
  }

  String toString() {
    return const <int, String>{
      0: 'FontWeight.w100',
      1: 'FontWeight.w200',
      2: 'FontWeight.w300',
      3: 'FontWeight.w400',
      4: 'FontWeight.w500',
      5: 'FontWeight.w600',
      6: 'FontWeight.w700',
      7: 'FontWeight.w800',
      8: 'FontWeight.w900',
    }[index];
  }
}

/// Whether to align text horizontally
enum TextAlign {
  /// Align the text on the left edge of the container
  left,

  /// Align the text on the right edge of the container
  right,

  /// Align the text in the center of the container
  center
}

/// A horizontal line used for aligning text
enum TextBaseline {
  // The horizontal line used to align the bottom of glyphs for alphabetic characters
  alphabetic,

  // The horizontal line used to align ideographic characters
  ideographic
}

/// A linear decoration to draw near the text
class TextDecoration {
  const TextDecoration._(this._mask);

  /// Creates a decoration that paints the union of all the given decorations.
  factory TextDecoration.combine(List<TextDecoration> decorations) {
    int mask = 0;
    for (TextDecoration decoration in decorations) mask |= decoration._mask;
    return new TextDecoration._(mask);
  }

  final int _mask;

  /// Whether this decoration will paint at least as much decoration as the given decoration.
  bool contains(TextDecoration other) {
    return (_mask | other._mask) == _mask;
  }

  /// Do not draw a decoration
  static const TextDecoration none = const TextDecoration._(0x0);

  /// Draw a line underneath each line of text
  static const TextDecoration underline = const TextDecoration._(0x1);

  /// Draw a line above each line of text
  static const TextDecoration overline = const TextDecoration._(0x2);

  /// Draw a line through each line of text
  static const TextDecoration lineThrough = const TextDecoration._(0x4);

  bool operator ==(dynamic other) {
    if (other is! TextDecoration) return false;
    final TextDecoration typedOther = other;
    return _mask == typedOther._mask;
  }

  int get hashCode => _mask.hashCode;

  String toString() {
    if (_mask == 0) return 'TextDecoration.none';
    List<String> values = <String>[];
    if (_mask & underline._mask != 0) values.add('underline');
    if (_mask & overline._mask != 0) values.add('overline');
    if (_mask & lineThrough._mask != 0) values.add('lineThrough');
    if (values.length == 1) return 'TextDecoration.${values[0]}';
    return 'TextDecoration.combine([${values.join(", ")}])';
  }
}

/// The style in which to draw a text decoration
enum TextDecorationStyle {
  /// Draw a solid line
  solid,

  /// Draw two lines
  double,

  /// Draw a dotted line
  dotted,

  /// Draw a dashed line
  dashed,

  /// Draw a sinusoidal line
  wavy
}

// This encoding must match the C++ version of ParagraphBuilder::pushStyle.
//
// The encoded array buffer has 8 elements.
//
//  - Element 0: A bit field where the ith bit indicates wheter the ith element
//    has a non-null value. Bits 8 to 12 indicate whether |fontFamily|,
//    |fontSize|, |letterSpacing|, |wordSpacing|, and |height| are non-null,
//    respectively. Bit 0 is unused.
//
//  - Element 1: The |color| in ARGB with 8 bits per channel.
//
//  - Element 2: A bit field indicating which text decorations are present in
//    the |textDecoration| list. The ith bit is set if there's a TextDecoration
//    with enum index i in the list.
//
//  - Element 3: The |decorationColor| in ARGB with 8 bits per channel.
//
//  - Element 4: The bit field of the |decorationStyle|.
//
//  - Element 5: The index of the |fontWeight|.
//
//  - Element 6: The enum index of the |fontStyle|.
//
//  - Element 7: The enum index of the |textBaseline|.
//
Int32List _encodeTextStyle(
    Color color,
    TextDecoration decoration,
    Color decorationColor,
    TextDecorationStyle decorationStyle,
    FontWeight fontWeight,
    FontStyle fontStyle,
    TextBaseline textBaseline,
    String fontFamily,
    double fontSize,
    double letterSpacing,
    double wordSpacing,
    double height) {
  Int32List result = new Int32List(8);
  if (color != null) {
    result[0] |= 1 << 1;
    result[1] = color.value;
  }
  if (decoration != null) {
    result[0] |= 1 << 2;
    result[2] = decoration._mask;
  }
  if (decorationColor != null) {
    result[0] |= 1 << 3;
    result[3] = decorationColor.value;
  }
  if (decorationStyle != null) {
    result[0] |= 1 << 4;
    result[4] = decorationStyle.index;
  }
  if (fontWeight != null) {
    result[0] |= 1 << 5;
    result[5] = fontWeight.index;
  }
  if (fontStyle != null) {
    result[0] |= 1 << 6;
    result[6] = fontStyle.index;
  }
  if (textBaseline != null) {
    result[0] |= 1 << 7;
    result[7] = textBaseline.index;
  }
  if (fontFamily != null) {
    result[0] |= 1 << 8;
    // Passed separately to native.
  }
  if (fontSize != null) {
    result[0] |= 1 << 9;
    // Passed separately to native.
  }
  if (letterSpacing != null) {
    result[0] |= 1 << 10;
    // Passed separately to native.
  }
  if (wordSpacing != null) {
    result[0] |= 1 << 11;
    // Passed separately to native.
  }
  if (height != null) {
    result[0] |= 1 << 12;
    // Passed separately to native.
  }
  return result;
}

/// An opaque object that determines the size, position, and rendering of text.
class TextStyle {
  /// Creates a new TextStyle object.
  ///
  /// * `color`: The color to use when painting the text.
  /// * `decoration`: The decorations to paint near the text (e.g., an underline).
  /// * `decorationColor`: The color in which to paint the text decorations.
  /// * `decorationStyle`: The style in which to paint the text decorations (e.g., dashed).
  /// * `fontWeight`: The typeface thickness to use when painting the text (e.g., bold).
  /// * `fontStyle`: The typeface variant to use when drawing the letters (e.g., italics).
  /// * `fontFamily`: The name of the font to use when painting the text (e.g., Roboto).
  /// * `fontSize`: The size of glyphs (in logical pixels) to use when painting the text.
  /// * `letterSpacing`: The amount of space (in logical pixels) to add between each letter.
  /// * `wordSpacing`: The amount of space (in logical pixels) to add at each sequence of white-space (i.e. between each word).
  /// * `textBaseline`: The common baseline that should be aligned between this text span and its parent text span, or, for the root text spans, with the line box.
  /// * `height`: The height of this text span, as a multiple of the font size.
  TextStyle(
      {Color color,
      TextDecoration decoration,
      Color decorationColor,
      TextDecorationStyle decorationStyle,
      FontWeight fontWeight,
      FontStyle fontStyle,
      TextBaseline textBaseline,
      String fontFamily,
      double fontSize,
      double letterSpacing,
      double wordSpacing,
      double height})
      : _encoded = _encodeTextStyle(
            color,
            decoration,
            decorationColor,
            decorationStyle,
            fontWeight,
            fontStyle,
            textBaseline,
            fontFamily,
            fontSize,
            letterSpacing,
            wordSpacing,
            height),
        _fontFamily = fontFamily ?? '',
        _fontSize = fontSize,
        _letterSpacing = letterSpacing,
        _wordSpacing = wordSpacing,
        _height = height;

  final Int32List _encoded;
  final String _fontFamily;
  final double _fontSize;
  final double _letterSpacing;
  final double _wordSpacing;
  final double _height;

  bool operator ==(dynamic other) {
    if (other is! TextStyle) return false;
    final TextStyle typedOther = other;
    if (_fontFamily != typedOther._fontFamily ||
        _fontSize != typedOther._fontSize ||
        _letterSpacing != typedOther._letterSpacing ||
        _wordSpacing != typedOther._wordSpacing ||
        _height != typedOther._height) return false;
    for (int index = 0; index < _encoded.length; index += 1) {
      if (_encoded[index] != typedOther._encoded[index]) return false;
    }
    return true;
  }

  int get hashCode => hashValues(hashList(_encoded), _fontFamily, _fontSize,
      _letterSpacing, _wordSpacing, _height);

  String toString() {
    return 'TextStyle('
        'color: ${          _encoded[0] & 0x0002 == 0x0002 ? new Color(_encoded[1])                  : "unspecified"}, '
        'decoration: ${     _encoded[0] & 0x0004 == 0x0004 ? new TextDecoration._(_encoded[2])       : "unspecified"}, '
        'decorationColor: ${_encoded[0] & 0x0008 == 0x0008 ? new Color(_encoded[3])                  : "unspecified"}, '
        'decorationStyle: ${_encoded[0] & 0x0010 == 0x0010 ? TextDecorationStyle.values[_encoded[4]] : "unspecified"}, '
        'fontWeight: ${     _encoded[0] & 0x0020 == 0x0020 ? FontWeight.values[_encoded[5]]          : "unspecified"}, '
        'fontStyle: ${      _encoded[0] & 0x0040 == 0x0040 ? FontStyle.values[_encoded[6]]           : "unspecified"}, '
        'textBaseline: ${   _encoded[0] & 0x0080 == 0x0080 ? TextBaseline.values[_encoded[7]]        : "unspecified"}, '
        'fontFamily: ${     _encoded[0] & 0x0100 == 0x0100 ? _fontFamily                             : "unspecified"}, '
        'fontSize: ${       _encoded[0] & 0x0200 == 0x0200 ? _fontSize                               : "unspecified"}, '
        'letterSpacing: ${  _encoded[0] & 0x0400 == 0x0400 ? "${_letterSpacing}x"                    : "unspecified"}, '
        'wordSpacing: ${    _encoded[0] & 0x0800 == 0x0800 ? "${_wordSpacing}x"                      : "unspecified"}, '
        'height: ${         _encoded[0] & 0x1000 == 0x1000 ? "${_height}x"                           : "unspecified"}'
        ')';
  }
}

// This encoding must match the C++ version ParagraphBuilder::build.
//
// The encoded array buffer has 5 elements.
//
//  - Element 0: A bit mask indicating which fields are non-null.
//    Bit 0 is unused. Bits 1-n are set if the corresponding index in the
//    encoded array is non-null.  The remaining bits represent fields that
//    are passed separately from the array.
//
//  - Element 1: The enum index of the |textAlign|.
//
//  - Element 2: The index of the |fontWeight|.
//
//  - Element 3: The enum index of the |fontStyle|.
//
//  - Element 4: The value of |lineCount|.
//
Int32List _encodeParagraphStyle(
    TextAlign textAlign,
    FontWeight fontWeight,
    FontStyle fontStyle,
    int lineCount,
    String fontFamily,
    double fontSize,
    double lineHeight,
    String ellipsis) {
  Int32List result = new Int32List(5);
  if (textAlign != null) {
    result[0] |= 1 << 1;
    result[1] = textAlign.index;
  }
  if (fontWeight != null) {
    result[0] |= 1 << 2;
    result[2] = fontWeight.index;
  }
  if (fontStyle != null) {
    result[0] |= 1 << 3;
    result[3] = fontStyle.index;
  }
  if (lineCount != null) {
    result[0] |= 1 << 4;
    result[4] = lineCount;
  }
  if (fontFamily != null) {
    result[0] |= 1 << 5;
    // Passed separately to native.
  }
  if (fontSize != null) {
    result[0] |= 1 << 6;
    // Passed separately to native.
  }
  if (lineHeight != null) {
    result[0] |= 1 << 7;
    // Passed separately to native.
  }
  if (ellipsis != null) {
    result[0] |= 1 << 8;
    // Passed separately to native.
  }
  return result;
}

/// An opaque object that determines the position of lines within a paragraph of text.
class ParagraphStyle {
  /// Creates a new ParagraphStyle object.
  ///
  /// * `textAlign`: The alignment of the text within the lines of the paragraph.
  /// * `fontWeight`: The typeface thickness to use when painting the text (e.g., bold).
  /// * `fontStyle`: The typeface variant to use when drawing the letters (e.g., italics).
  /// * `lineCount`: Currently not implemented.
  /// * `fontFamily`: The name of the font to use when painting the text (e.g., Roboto).
  /// * `fontSize`: The size of glyphs (in logical pixels) to use when painting the text.
  /// * `lineHeight`: The minimum height of the line boxes, as a multiple of the font size.
  /// * `ellipsis`: String used to ellipsize overflowing text.
  ParagraphStyle(
      {TextAlign textAlign,
      FontWeight fontWeight,
      FontStyle fontStyle,
      int lineCount,
      String fontFamily,
      double fontSize,
      double lineHeight,
      String ellipsis})
      : _encoded = _encodeParagraphStyle(textAlign, fontWeight, fontStyle,
            lineCount, fontFamily, fontSize, lineHeight, ellipsis),
        _fontFamily = fontFamily,
        _fontSize = fontSize,
        _lineHeight = lineHeight,
        _ellipsis = ellipsis {
    assert(lineCount == null);
  }

  final Int32List _encoded;
  final String _fontFamily;
  final double _fontSize;
  final double _lineHeight;
  final String _ellipsis;

  bool operator ==(dynamic other) {
    if (other is! ParagraphStyle) return false;
    final ParagraphStyle typedOther = other;
    if (_fontFamily != typedOther._fontFamily ||
        _fontSize != typedOther._fontSize ||
        _lineHeight != typedOther._lineHeight ||
        _ellipsis != typedOther._ellipsis) return false;
    for (int index = 0; index < _encoded.length; index += 1) {
      if (_encoded[index] != typedOther._encoded[index]) return false;
    }
    return true;
  }

  int get hashCode => hashValues(hashList(_encoded), _lineHeight);

  String toString() {
    return 'ParagraphStyle('
        'textAlign: ${   _encoded[0] & 0x02 == 0x02 ? TextAlign.values[_encoded[1]]    : "unspecified"}, '
        'fontWeight: ${  _encoded[0] & 0x04 == 0x04 ? FontWeight.values[_encoded[2]]   : "unspecified"}, '
        'fontStyle: ${   _encoded[0] & 0x08 == 0x08 ? FontStyle.values[_encoded[3]]    : "unspecified"}, '
        'lineCount: ${   _encoded[0] & 0x10 == 0x10 ? _encoded[4]                      : "unspecified"}, '
        'fontFamily: ${  _encoded[0] & 0x20 == 0x20 ? _fontFamily                      : "unspecified"}, '
        'fontSize: ${    _encoded[0] & 0x40 == 0x40 ? _fontSize                        : "unspecified"}, '
        'lineHeight: ${  _encoded[0] & 0x80 == 0x80 ? "${_lineHeight}x"                : "unspecified"}, '
        'ellipsis: ${    _encoded[0] & 0x100 == 0x100 ? "\"$_ellipsis\""                : "unspecified"}'
        ')';
  }
}

/// A direction in which text flows.
enum TextDirection {
  /// The text flows from right to left (e.g. Arabic, Hebrew).
  rtl,

  /// The text flows from left to right (e.g., English, French).
  ltr
}

/// A rectangle enclosing a run of text.
class TextBox {
  const TextBox.fromLTRBD(
      this.left, this.top, this.right, this.bottom, this.direction);

  TextBox._(this.left, this.top, this.right, this.bottom, int directionIndex)
      : direction = TextDirection.values[directionIndex];

  /// The left edge of the text box, irrespective of direction.
  final double left;

  /// The top edge of the text box.
  final double top;

  /// The right edge of the text box, irrespective of direction.
  final double right;

  /// The bottom edge of the text box.
  final double bottom;

  /// The direction in which text inside this box flows.
  final TextDirection direction;

  /// Returns a rect of the same size as this box.
  Rect toRect() => new Rect.fromLTRB(left, top, right, bottom);

  /// The left edge of the box for ltr text; the right edge of the box for rtl text.
  double get start {
    return (direction == TextDirection.ltr) ? left : right;
  }

  /// The right edge of the box for ltr text; the left edge of the box for rtl text.
  double get end {
    return (direction == TextDirection.ltr) ? right : left;
  }

  bool operator ==(dynamic other) {
    if (other is! TextBox) return false;
    final TextBox typedOther = other;
    return typedOther.left == left &&
        typedOther.top == top &&
        typedOther.right == right &&
        typedOther.bottom == bottom &&
        typedOther.direction == direction;
  }

  int get hashCode => hashValues(left, top, right, bottom, direction);

  String toString() =>
      'TextBox.fromLTRBD(${left.toStringAsFixed(1)}, ${top.toStringAsFixed(1)}, ${right.toStringAsFixed(1)}, ${bottom.toStringAsFixed(1)}, $direction)';
}

/// Whether a [TextPosition] is visually upstream or downstream of its offset.
///
/// For example, when a text position exists at a line break, a single offset has
/// two visual positions, one prior to the line break (at the end of the first
/// line) and one after the line break (at the start of the second line). A text
/// affinity disambiguates between those cases. (Something similar happens with
/// between runs of bidirectional text.)
enum TextAffinity {
  /// The position has affinity for the upstream side of the text position.
  ///
  /// For example, if the offset of the text position is a line break, the
  /// position represents the end of the first line.
  upstream,

  /// The position has affinity for the downstream side of the text position.
  ///
  /// For example, if the offset of the text position is a line break, the
  /// position represents the start of the second line.
  downstream
}

/// A visual position in a string of text.
class TextPosition {
  const TextPosition({this.offset, this.affinity: TextAffinity.downstream});

  /// The index of the character just prior to the position.
  final int offset;

  /// If the offset has more than one visual location (e.g., occurs at a line
  /// break), which of the two locations is represented by this position.
  final TextAffinity affinity;

  String toString() {
    return '$runtimeType(offset: $offset, affinity: $affinity)';
  }
}

/// Layout constraints for [Paragraph] objects.
///
/// Instances of this class are typically used with [Paragraph.layout].
class ParagraphConstraints {
  /// Creates constraints for laying out a pargraph.
  ///
  /// The [width] argument must not be null.
  ParagraphConstraints({this.width}) {
    assert(width != null);
  }

  /// The width the paragraph should use whey computing the positions of glyphs.
  ///
  /// If possible, the paragraph will select a soft line break prior to reaching
  /// this width. If no soft line break is available, the paragraph will select
  /// a hard line break prior to reaching this width.
  ///
  /// This width will also be used for positioning glyphs with [TextAlign].
  final double width;

  bool operator ==(dynamic other) {
    if (other is! ParagraphConstraints) return false;
    final ParagraphConstraints typedOther = other;
    return typedOther.width == width;
  }

  int get hashCode => width.hashCode;

  String toString() => 'ParagraphConstraints(width: $width)';
}

/// A paragraph of text.
///
/// A paragraph retains the size and position of each glyph in the text and can
/// be efficiently resized and painted.
///
/// To create a Paragraph object, use a [ParagraphBuilder].
///
/// Paragraph objects can be displayed on a [Canvas] using the
/// [Canvas.drawParagraph] method.
abstract class Paragraph {
  /// Creates an uninitialized Paragraph object.
  ///
  /// Calling the Paragraph constructor directly will not create a useable
  /// object. To create a Paragraph object, use a [ParagraphBuilder].
  Paragraph(); // (this constructor is here just so we can document it)

  /// The amount of horizontal space this paragraph occupies.
  ///
  /// Valid only after [layout] has been called.
  double get width => throw new UnimplementedError();

  /// The amount of vertical space this paragraph occupies.
  ///
  /// Valid only after [layout] has been called.
  double get height => throw new UnimplementedError();

  /// The minimum width that this paragraph could be without failing to paint
  /// its contents within itself.
  ///
  /// Valid only after [layout] has been called.
  double get minIntrinsicWidth => throw new UnimplementedError();

  /// Returns the smallest width beyond which increasing the width never
  /// decreases the height.
  ///
  /// Valid only after [layout] has been called.
  double get maxIntrinsicWidth => throw new UnimplementedError();

  /// The distance from the top of the paragraph to the alphabetic
  /// baseline of the first line, in logical pixels.
  double get alphabeticBaseline => throw new UnimplementedError();

  /// The distance from the top of the paragraph to the ideographic
  /// baseline of the first line, in logical pixels.
  double get ideographicBaseline => throw new UnimplementedError();

  /// Computes the size and position of each glyph in the paragraph.
  void layout(ParagraphConstraints constraints) => _layout(constraints.width);
  void _layout(double width) => throw new UnimplementedError();

  /// Returns a list of text boxes that enclose the given text range.
  List<TextBox> getBoxesForRange(int start, int end) =>
      throw new UnimplementedError();

  /// Returns the text position closest to the given offset.
  TextPosition getPositionForOffset(Offset offset) {
    List<int> encoded = _getPositionForOffset(offset.dx, offset.dy);
    return new TextPosition(
        offset: encoded[0], affinity: TextAffinity.values[encoded[1]]);
  }

  List<int> _getPositionForOffset(double dx, double dy) =>
      throw new UnimplementedError();

  /// Returns the [start, end] of the word at the given offset. Characters not
  /// part of a word, such as spaces, symbols, and punctuation, have word breaks
  /// on both sides. In such cases, this method will return [offset, offset+1].
  /// Word boundaries are defined more precisely in Unicode Standard Annex #29
  /// http://www.unicode.org/reports/tr29/#Word_Boundaries
  List<int> getWordBoundary(int offset) => throw new UnimplementedError();
}

/// Builds a [Paragraph] containing text with the given styling information.
class ParagraphBuilder {
  /// Creates a [ParagraphBuilder] object, which is used to create a
  /// [Paragraph].
  ParagraphBuilder(ParagraphStyle style) {
    _constructor(style._encoded, style._fontFamily, style._fontSize,
        style._lineHeight, style._ellipsis);
  }
  void _constructor(Int32List encoded, String fontFamily, double fontSize,
          double lineHeight, String ellipsis) =>
      throw new UnimplementedError();

  /// Applies the given style to the added text until [pop] is called.
  ///
  /// See [pop] for details.
  void pushStyle(TextStyle style) => _pushStyle(
      style._encoded,
      style._fontFamily,
      style._fontSize,
      style._letterSpacing,
      style._wordSpacing,
      style._height);
  void _pushStyle(Int32List encoded, String fontFamily, double fontSize,
          double letterSpacing, double wordSpacing, double height) =>
      throw new UnimplementedError();

  /// Ends the effect of the most recent call to [pushStyle].
  ///
  /// Internally, the paragraph builder maintains a stack of text styles. Text
  /// added to the paragraph is affected by all the styles in the stack. Calling
  /// [pop] removes the topmost style in the stack, leaving the remaining styles
  /// in effect.
  void pop() => throw new UnimplementedError();

  /// Adds the given text to the paragraph.
  ///
  /// The text will be styled according to the current stack of text styles.
  void addText(String text) => throw new UnimplementedError();

  /// Applies the given paragraph style and returns a Paragraph containing the added text and associated styling.
  ///
  /// After calling this function, the paragraph builder object is invalid and
  /// cannot be used further.
  Paragraph build() => throw new UnimplementedError();
}
