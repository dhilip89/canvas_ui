// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the CHROMIUM_LICENSE file.

import 'package:flutter/widgets.dart';

import 'debug.dart';
import 'theme.dart';

const double _kDrawerHeaderHeight = 160.0 + 1.0; // bottom edge

/// The top-most region of a material design drawer. The header's [child]
/// widget, if any, is placed inside a [Container] whose [decoration] can be
/// passed as an argument, inset by the given [padding].
///
/// Part of the material design [Drawer].
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// See also:
///
///  * [Drawer]
///  * [UserAccountsDrawerHeader], a variant of [DrawerHeader] that is
///    specialized for showing user accounts.
///  * [DrawerItem]
///  * <https://material.google.com/patterns/navigation-drawer.html>
class DrawerHeader extends StatelessWidget {
  /// Creates a material design drawer header.
  ///
  /// Requires one of its ancestors to be a [Material] widget.
  const DrawerHeader({
    Key key,
    this.decoration,
    this.padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
    this.duration: const Duration(milliseconds: 250),
    this.curve: Curves.fastOutSlowIn,
    this.child
  }) : super(key: key);

  /// Decoration for the main drawer header [Container]; useful for applying
  /// backgrounds.
  ///
  /// This decoration will extend under the system status bar.
  ///
  /// If this is changed, it will be animated according to [duration] and [curve].
  final Decoration decoration;

  /// The padding by which to inset [child].
  ///
  /// The [DrawerHeader] additionally offsets the child by the height of the
  /// system status bar.
  ///
  /// If the child is null, the padding has no effect.
  final EdgeInsets padding;

  /// The duration for animations of the [decoration].
  final Duration duration;

  /// The curve for animations of the [decoration].
  final Curve curve;

  /// A widget to be placed inside the drawer header, inset by the [padding].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final ThemeData theme = Theme.of(context);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return new Container(
      height: statusBarHeight + _kDrawerHeaderHeight,
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: new BoxDecoration(
        border: new Border(
          bottom: new BorderSide(
            color: theme.dividerColor,
            width: 1.0
          )
        )
      ),
      child: new AnimatedContainer(
        padding: padding + new EdgeInsets.only(top: statusBarHeight),
        decoration: decoration,
        duration: duration,
        curve: curve,
        child: child == null ? null : new DefaultTextStyle(
          style: theme.textTheme.body2,
          child: child
        )
      )
    );
  }
}
