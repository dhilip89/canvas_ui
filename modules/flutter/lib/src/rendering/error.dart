// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the CHROMIUM_LICENSE file.

import 'package:canvas_ui/canvas_ui.dart' as ui show Paragraph, ParagraphBuilder, ParagraphConstraints, ParagraphStyle, TextStyle;

import 'box.dart';
import 'object.dart';

const double _kMaxWidth = 100000.0;
const double _kMaxHeight = 100000.0;

/// A render object used as a placeholder when an error occurs.
///
/// The box will be painted in the color given by the
/// [RenderErrorBox.backgroundColor] static property.
///
/// A message can be provided. To simplify the class and thus help reduce the
/// likelihood of this class itself being the source of errors, the message
/// cannot be changed once the object has been created. If provided, the text
/// will be painted on top of the background, using the styles given by the
/// [RenderErrorBox.textStyle] and [RenderErrorBox.paragraphStyle] static
/// properties.
///
/// Again to help simplify the class, this box tries to be 100000.0 pixels wide
/// and high, to approximate being infinitely high but without using infinities.
class RenderErrorBox extends RenderBox {
  /// Creates a RenderErrorBox render object.
  ///
  /// A message can optionally be provided. If a message is provided, an attempt
  /// will be made to render the message when the box paints.
  RenderErrorBox([ this.message = '' ]) {
    try {
      if (message != '') {
        // This class is intentionally doing things using the low-level
        // primitives to avoid depending on any subsystems that may have ended
        // up in an unstable state -- after all, this class is mainly used when
        // things have gone wrong.
        //
        // Generally, the much better way to draw text in a RenderObject is to
        // use the TextPainter class. If you're looking for code to crib from,
        // see the paragraph.dart file and the RenderParagraph class.
        ui.ParagraphBuilder builder = new ui.ParagraphBuilder();
        builder.pushStyle(textStyle);
        builder.addText(message);
        _paragraph = builder.build(paragraphStyle);
      }
    } catch (e) { }
  }

  /// The message to attempt to display at paint time.
  final String message;

  ui.Paragraph _paragraph;

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _kMaxWidth;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _kMaxHeight;
  }

  @override
  bool get sizedByParent => true;

  @override
  bool hitTestSelf(Point position) => true;

  @override
  void performResize() {
    size = constraints.constrain(const Size(_kMaxWidth, _kMaxHeight));
  }

  /// The color to use when painting the background of [RenderErrorBox] objects.
  static Color backgroundColor = const Color(0xF0900000);

  /// The text style to use when painting [RenderErrorBox] objects.
  static ui.TextStyle textStyle = new ui.TextStyle(
    color: const Color(0xFFFFFF00),
    fontFamily: 'monospace',
    fontSize: 7.0
  );

  /// The paragraph style to use when painting [RenderErrorBox] objects.
  static ui.ParagraphStyle paragraphStyle = new ui.ParagraphStyle(
    lineHeight: 0.25 // TODO(ianh): https://github.com/flutter/flutter/issues/2460 will affect this
  );

  @override
  void paint(PaintingContext context, Offset offset) {
    try {
      context.canvas.drawRect(offset & size, new Paint() .. color = backgroundColor);
      double width;
      if (_paragraph != null) {
        // See the comment in the RenderErrorBox constructor. This is not the
        // code you want to be copying and pasting. :-)
        if (parent is RenderBox) {
          RenderBox parentBox = parent;
          width = parentBox.size.width;
        } else {
          width = size.width;
        }
        _paragraph.layout(new ui.ParagraphConstraints(width: width));
        context.canvas.drawParagraph(_paragraph, offset);
      }
    } catch (e) { }
  }
}
