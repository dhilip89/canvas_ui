// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the CHROMIUM_LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'colors.dart';
import 'debug.dart';
import 'icon.dart';
import 'icon_theme.dart';
import 'icon_theme_data.dart';
import 'material.dart';
import 'text_selection.dart';
import 'theme.dart';

export 'package:flutter/services.dart' show TextInputType;

/// A material design text input field.
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// If the [Input] has a [Form] ancestor, the [formField] property must
/// be specified. In this case, the [Input] keeps track of the value of
/// the [Input] field automatically, and the initial value can be specified
/// using the [value] property.
///
/// If the [Input] does not have a [Form] ancestor, then the [value]
/// must be updated each time the [onChanged] callback is invoked.
///
/// See also:
///
///  * <https://material.google.com/components/text-fields.html>
///
/// For a detailed guide on using the input widget, see:
///
/// * <https://flutter.io/text-input/>
class Input extends StatefulWidget {
  /// Creates a text input field.
  ///
  /// By default, the input uses a keyboard appropriate for text entry.
  ///
  /// The [formField] argument is required if the [Input] has an ancestor [Form].
  Input({
    Key key,
    this.value,
    this.keyboardType: TextInputType.text,
    this.icon,
    this.labelText,
    this.hintText,
    this.errorText,
    this.style,
    this.hideText: false,
    this.isDense: false,
    this.autofocus: false,
    this.maxLines: 1,
    this.formField,
    this.onChanged,
    this.onSubmitted,
  }) : super(key: key);

  /// The text of the input field.
  ///
  /// If the [Input] is in a [Form], this is the initial value only.
  ///
  /// Otherwise, this is the current value, and must be updated every
  /// time [onChanged] is called.
  final InputValue value;

  /// The type of keyboard to use for editing the text.
  final TextInputType keyboardType;

  /// An icon to show adjacent to the input field.
  ///
  /// The size and color of the icon is configured automatically using an
  /// [IconTheme] and therefore does not need to be explicitly given in the
  /// icon widget.
  ///
  /// See [Icon], [ImageIcon].
  final Widget icon;

  /// Text to show above the input field.
  final String labelText;

  /// Text to show inline in the input field when it would otherwise be empty.
  final String hintText;

  /// Text to show when the input text is invalid.
  ///
  /// If this is set, then the [formField]'s [FormField.validator], if any, is
  /// ignored.
  final String errorText;

  /// The style to use for the text being edited.
  final TextStyle style;

  /// Whether to hide the text being edited (e.g., for passwords).
  ///
  /// When this is set to true, all the characters in the input are replaced by
  /// U+2022 BULLET characters (•).
  final bool hideText;

  /// Whether the input field is part of a dense form (i.e., uses less vertical space).
  final bool isDense;

  /// Whether this input field should focus itself if nothing else is already focused.
  final bool autofocus;

  /// The maximum number of lines for the text to span, wrapping if necessary.
  /// If this is 1 (the default), the text will not wrap, but will scroll
  /// horizontally instead.
  final int maxLines;

  /// The [Form] entry for this input control. Required if the input is in a [Form].
  /// Ignored otherwise.
  ///
  /// Putting an Input in a [Form] means the Input will keep track of its own value,
  /// using the [value] property only as the field's initial value. It also means
  /// that when any field in the [Form] changes, all the widgets in the form will be
  /// rebuilt, so that each field's [FormField.validator] callback can be reevaluated.
  final FormField<String> formField;

  /// Called when the text being edited changes.
  ///
  /// If the [Input] is not in a [Form], the [value] must be updated each time [onChanged]
  /// is invoked. (If there is a [Form], then the value is tracked in the [formField], and
  /// this callback is purely advisory.)
  ///
  /// If the [Input] is in a [Form], this is called after the [formField] is updated.
  final ValueChanged<InputValue> onChanged;

  /// Called when the user indicates that they are done editing the text in the field.
  ///
  /// If the [Input] is in a [Form], this is called after the [formField] is notified.
  final ValueChanged<InputValue> onSubmitted;

  @override
  _InputState createState() => new _InputState();
}

const Duration _kTransitionDuration = const Duration(milliseconds: 200);
const Curve _kTransitionCurve = Curves.fastOutSlowIn;

class _InputState extends State<Input> {
  GlobalKey<RawInputState> _rawInputKey = new GlobalKey<RawInputState>();

  GlobalKey get focusKey => config.key is GlobalKey ? config.key : _rawInputKey;

  // Optional state to retain if we are inside a Form widget.
  _FormFieldData _formData;

  @override
  void dispose() {
    _formData?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    ThemeData themeData = Theme.of(context);
    BuildContext focusContext = focusKey.currentContext;
    bool focused = focusContext != null && Focus.at(focusContext, autofocus: config.autofocus);
    if (_formData == null) {
      _formData = _FormFieldData.maybeCreate(context, this);
    } else {
      _formData = _formData.maybeDispose(context);
    }
    InputValue value =  _formData?.value ?? config.value ?? InputValue.empty;
    ValueChanged<InputValue> onChanged = _formData?.onChanged ?? config.onChanged;
    ValueChanged<InputValue> onSubmitted = _formData?.onSubmitted ?? config.onSubmitted;
    String errorText = config.errorText;

    if (errorText == null && config.formField != null && config.formField.validator != null)
      errorText = config.formField.validator(value.text);

    TextStyle textStyle = config.style ?? themeData.textTheme.subhead;
    Color activeColor = themeData.hintColor;
    if (focused) {
      switch (themeData.brightness) {
        case Brightness.dark:
          activeColor = themeData.accentColor;
          break;
        case Brightness.light:
          activeColor = themeData.primaryColor;
          break;
      }
    }
    double topPadding = config.isDense ? 12.0 : 16.0;

    List<Widget> stackChildren = <Widget>[];

    bool hasInlineLabel = config.labelText != null && !focused && !value.text.isNotEmpty;

    if (config.labelText != null) {
      TextStyle labelStyle = hasInlineLabel ?
        themeData.textTheme.subhead.copyWith(color: themeData.hintColor) :
        themeData.textTheme.caption.copyWith(color: activeColor);

      double topPaddingIncrement = themeData.textTheme.caption.fontSize + (config.isDense ? 4.0 : 8.0);
      double top = topPadding;
      if (hasInlineLabel)
        top += topPaddingIncrement + textStyle.fontSize - labelStyle.fontSize;

      stackChildren.add(new AnimatedPositioned(
        left: 0.0,
        top: top,
        duration: _kTransitionDuration,
        curve: _kTransitionCurve,
        child: new Text(config.labelText, style: labelStyle)
      ));

      topPadding += topPaddingIncrement;
    }

    if (config.hintText != null && value.text.isEmpty && !hasInlineLabel) {
      TextStyle hintStyle = themeData.textTheme.subhead.copyWith(color: themeData.hintColor);
      stackChildren.add(new Positioned(
        left: 0.0,
        top: topPadding + textStyle.fontSize - hintStyle.fontSize,
        child: new Text(config.hintText, style: hintStyle)
      ));
    }

    Color borderColor = activeColor;
    double bottomPadding = 8.0;
    double bottomBorder = focused ? 2.0 : 1.0;
    double bottomHeight = config.isDense ? 14.0 : 18.0;

    if (errorText != null) {
      borderColor = themeData.errorColor;
      bottomBorder = 2.0;
      if (!config.isDense)
        bottomPadding = 1.0;
    }

    EdgeInsets padding = new EdgeInsets.only(top: topPadding, bottom: bottomPadding);
    Border border = new Border(
      bottom: new BorderSide(
        color: borderColor,
        width: bottomBorder,
      )
    );
    EdgeInsets margin = new EdgeInsets.only(bottom: bottomHeight - (bottomPadding + bottomBorder));

    stackChildren.add(new AnimatedContainer(
      margin: margin,
      padding: padding,
      duration: _kTransitionDuration,
      curve: _kTransitionCurve,
      decoration: new BoxDecoration(
        border: border,
      ),
      child: new RawInput(
        key: _rawInputKey,
        value: value,
        focusKey: focusKey,
        style: textStyle,
        hideText: config.hideText,
        maxLines: config.maxLines,
        cursorColor: themeData.textSelectionColor,
        selectionColor: themeData.textSelectionColor,
        selectionControls: materialTextSelectionControls,
        platform: Theme.of(context).platform,
        keyboardType: config.keyboardType,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      )
    ));

    if (errorText != null && !config.isDense) {
      TextStyle errorStyle = themeData.textTheme.caption.copyWith(color: themeData.errorColor);
      stackChildren.add(new Positioned(
        left: 0.0,
        bottom: 0.0,
        child: new Text(errorText, style: errorStyle)
      ));
    }

    Widget child = new Stack(children: stackChildren);

    if (config.icon != null) {
      double iconSize = config.isDense ? 18.0 : 24.0;
      double iconTop = topPadding + (textStyle.fontSize - iconSize) / 2.0;
      child = new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: new EdgeInsets.only(right: 16.0, top: iconTop),
            width: config.isDense ? 40.0 : 48.0,
            child: new IconTheme.merge(
              context: context,
              data: new IconThemeData(
                color: focused ? activeColor : Colors.black45,
                size: config.isDense ? 18.0 : 24.0
              ),
              child: config.icon
            )
          ),
          new Flexible(child: child)
        ]
      );
    }

    return new RepaintBoundary(
      child: new GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _rawInputKey.currentState?.requestKeyboard(),
        child: child
      )
    );
  }
}

// _FormFieldData is a helper class for _InputState for when the Input
// is in a Form.
//
// An instance is created when the Input is put in a Form, and lives
// until the Input is taken placed somewhere without a Form. (If the
// Input is moved from one Form to another, the same _FormFieldData is
// used for both forms).
//
// The _FormFieldData stores the value of the Input. Without a Form,
// the Input is essentially stateless.

class _FormFieldData {
  _FormFieldData(this.inputState) {
    assert(field != null);
    value = inputState.config.value ?? new InputValue();
  }

  final _InputState inputState;
  InputValue value;

  FormField<String> get field => inputState.config.formField;

  static _FormFieldData maybeCreate(BuildContext context, _InputState inputState) {
    // Only create a _FormFieldData if this Input is a descendent of a Form.
    if (FormScope.of(context) != null)
      return new _FormFieldData(inputState);
    return null;
  }

  _FormFieldData maybeDispose(BuildContext context) {
    if (FormScope.of(context) != null)
      return this;
    dispose();
    return null;
  }

  void dispose() {
    value = null;
  }

  void onChanged(InputValue value) {
    assert(value != null);
    assert(field != null);
    FormScope scope = FormScope.of(inputState.context);
    assert(scope != null);
    this.value = value;
    if (field.setter != null)
      field.setter(value.text);
    if (inputState.config.onChanged != null)
      inputState.config.onChanged(value);
    scope.onFieldChanged();
  }

  void onSubmitted(InputValue value) {
    assert(value != null);
    assert(field != null);
    FormScope scope = FormScope.of(inputState.context);
    assert(scope != null);
    if (scope.form.onSubmitted != null)
      scope.form.onSubmitted();
    if (inputState.config.onSubmitted != null)
      inputState.config.onSubmitted(value);
    scope.onFieldChanged();
  }
}
