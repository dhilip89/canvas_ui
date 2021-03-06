// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the CHROMIUM_LICENSE file.

part of canvas_ui;

/// The possible actions that can be conveyed from the operating system
/// accessibility APIs to a semantics node.
class SemanticsAction {
  static const int _kTapIndex = 1 << 0;
  static const int _kLongPressIndex = 1 << 1;
  static const int _kScrollLeftIndex = 1 << 2;
  static const int _kScrollRightIndex = 1 << 3;
  static const int _kScrollUpIndex = 1 << 4;
  static const int _kScrollDownIndex = 1 << 5;
  static const int _kIncreaseIndex = 1 << 6;
  static const int _kDecreaseIndex = 1 << 7;

  const SemanticsAction._(this.index);

  /// The numerical value for this action.
  ///
  /// Each action has one bit set in this bit field.
  final int index;

  /// The equivalent of a user briefly tapping the screen with the finger
  /// without moving it.
  static const SemanticsAction tap = const SemanticsAction._(_kTapIndex);

  /// The equivalent of a user pressing and holding the screen with the finger
  /// for a few seconds without moving it.
  static const SemanticsAction longPress =
      const SemanticsAction._(_kLongPressIndex);

  /// The equivalent of a user moving their finger across the screen from right
  /// to left.
  ///
  /// This action should be recognized by controls that are horizontally
  /// scrollable.
  static const SemanticsAction scrollLeft =
      const SemanticsAction._(_kScrollLeftIndex);

  /// The equivalent of a user moving their finger across the screen from left
  /// to right.
  ///
  /// This action should be recognized by controls that are horizontally
  /// scrollable.
  static const SemanticsAction scrollRight =
      const SemanticsAction._(_kScrollRightIndex);

  /// The equivalent of a user moving their finger across the screen from
  /// bottom to top.
  ///
  /// This action should be recognized by controls that are vertically
  /// scrollable.
  static const SemanticsAction scrollUp =
      const SemanticsAction._(_kScrollUpIndex);

  /// The equivalent of a user moving their finger across the screen from top
  /// to bottom.
  ///
  /// This action should be recognized by controls that are vertically
  /// scrollable.
  static const SemanticsAction scrollDown =
      const SemanticsAction._(_kScrollDownIndex);

  /// A request to increase the value represented by the semantics node.
  ///
  /// For example, this action might be recognized by a slider control.
  static const SemanticsAction increase =
      const SemanticsAction._(_kIncreaseIndex);

  /// A request to decrease the value represented by the semantics node.
  ///
  /// For example, this action might be recognized by a slider control.
  static const SemanticsAction decrease =
      const SemanticsAction._(_kDecreaseIndex);

  /// The possible semantics actions.
  ///
  /// The map's key is the [index] of the action and the value is the action
  /// itself.
  static final Map<int, SemanticsAction> values = const <int, SemanticsAction>{
    _kTapIndex: tap,
    _kLongPressIndex: longPress,
    _kScrollLeftIndex: scrollLeft,
    _kScrollRightIndex: scrollRight,
    _kScrollUpIndex: scrollUp,
    _kScrollDownIndex: scrollDown,
    _kIncreaseIndex: increase,
    _kDecreaseIndex: decrease,
  };

  @override
  String toString() {
    switch (index) {
      case _kTapIndex:
        return 'SemanticsAction.tap';
      case _kLongPressIndex:
        return 'SemanticsAction.longPress';
      case _kScrollLeftIndex:
        return 'SemanticsAction.scrollLeft';
      case _kScrollRightIndex:
        return 'SemanticsAction.scrollRight';
      case _kScrollUpIndex:
        return 'SemanticsAction.scrollUp';
      case _kScrollDownIndex:
        return 'SemanticsAction.scrollDown';
      case _kIncreaseIndex:
        return 'SemanticsAction.increase';
      case _kDecreaseIndex:
        return 'SemanticsAction.decrease';
    }
    return null;
  }
}

/// A Boolean value that can be associated with a semantics node.
class SemanticsFlags {
  static const int _kHasCheckedStateIndex = 1 << 0;
  static const int _kIsCheckedIndex = 1 << 1;

  const SemanticsFlags._(this.index);

  /// The numerical value for this flag.
  ///
  /// Each flag has one bit set in this bit field.
  final int index;

  /// The semantics node has the quality of either being "checked" or "unchecked".
  ///
  /// For example, a checkbox or a radio button widget has checked state.
  static const SemanticsFlags hasCheckedState =
      const SemanticsFlags._(_kHasCheckedStateIndex);

  /// Whether a semantics node that [hasCheckedState] is checked.
  ///
  /// If true, the semantics node is "checked". If false, the semantics node is
  /// "unchecked".
  ///
  /// For example, if a checkbox has a visible checkmark, [isChecked] is true.
  static const SemanticsFlags isChecked =
      const SemanticsFlags._(_kIsCheckedIndex);

  /// The possible semantics flags.
  ///
  /// The map's key is the [index] of the flag and the value is the flag itself.
  static final Map<int, SemanticsFlags> values = const <int, SemanticsFlags>{
    _kHasCheckedStateIndex: hasCheckedState,
    _kIsCheckedIndex: isChecked,
  };

  @override
  String toString() {
    switch (index) {
      case _kHasCheckedStateIndex:
        return 'SemanticsFlags.hasCheckedState';
      case _kIsCheckedIndex:
        return 'SemanticsFlags.isChecked';
    }
    return null;
  }
}

/// An object that creates [SemanticsUpdate] objects.
///
/// Once created, the [SemanticsUpdate] objects can be passed to
/// [Window.updateSemantics] to update the semantics conveyed to the user.
class SemanticsUpdateBuilder {
  /// Creates an empty [SemanticsUpdateBuilder] object.
  SemanticsUpdateBuilder() {
    throw new UnimplementedError();
  }

  /// Update the information associated with the node with the given `id`.
  ///
  /// The semantics nodes form a tree, with the root of the tree always having
  /// an id of zero. The `children` are the ids of the nodes that are immediate
  /// children of this node. The system retains the nodes that are currently
  /// reachable from the root. A given update need not contain information for
  /// nodes that do not change in the update. If a node is not reachable from
  /// the root after an update, the node will be discarded from the tree.
  ///
  /// The `flags` are a bit field of [SemanticsFlags] that apply to this node.
  ///
  /// The `actions` are a bit field of [SemanticsActions] that can be undertaken
  /// by this node. If the user wishes to undertake one of these actions on this
  /// node, the [Window.onSemanticsAction] will be called with `id` and one of
  /// the possible [SemanticsActions]. Because the semantics tree is maintained
  /// asynchronously, the [Window.onSemanticsAction] callback might be called
  /// with an action that is no longer possible.
  ///
  /// The `label` is a string that describes this node.
  ///
  /// The `rect` is the region occupied by this node in its own coordinate
  /// system.
  ///
  /// The `transform` is a matrix that maps this node's coodinate system into
  /// its parent's coordate system.
  void updateNode(
      {int id,
      int flags,
      int actions,
      Rect rect,
      String label,
      Float64List transform,
      Int32List children}) {
    if (transform.length != 16)
      throw new ArgumentError("[transform] must have 16 entries.");
    throw new UnimplementedError();
  }

  /// Creates a [SemanticsUpdate] object that encapsulates the updates recorded
  /// by this object.
  ///
  /// The returned object can be passed to [Window.updateSemantics] to actually
  /// update the semantics retained by the system.
  SemanticsUpdate build() => throw new UnimplementedError();
}

/// An opaque object representing a batch of semantics updates.
///
/// To create a SemanticsUpdate object, use a [SemanticsUpdateBuilder].
///
/// Semantics updates can be applied to the system's retained semantics tree
/// using the [Window.updateSemantics] method.
class SemanticsUpdate {
  /// Creates an uninitialized SemanticsUpdate object.
  ///
  /// Calling the SemanticsUpdate constructor directly will not create a useable
  /// object. To create a SemanticsUpdate object, use a [SemanticsUpdateBuilder].
  SemanticsUpdate(); // (this constructor is here just so we can document it)

  /// Releases the resources used by this semantics update.
  ///
  /// After calling this function, the semantics update is cannot be used
  /// further.
  void dispose() => throw new UnimplementedError();
}
