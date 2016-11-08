part of canvas_ui;

String _decodeUTF8(ByteData message) {
  return message != null
      ? UTF8.decoder.convert(message.buffer.asUint8List())
      : null;
}

dynamic _decodeJSON(String message) {
  return message != null ? JSON.decode(message) : null;
}

_CanvasUI _canvasUI = null;

void initCanvasUI(html.CanvasElement stage) {
  _canvasUI = new _CanvasUI(stage);
}

void disposeCanvasUI() {
  _canvasUI.dispose();
  _canvasUI = null;
}

class _CanvasUI {
  _WebHooks _hooks;

  _CanvasUI(html.CanvasElement stage) : _hooks = new _WebHooks(stage);

  void dispose() {
    _hooks.dispose();
    _hooks = null;
  }
}

class _WebHooks {
  html.CanvasElement stage;
  html.CanvasRenderingContext2D context2d;
  int handle;

  StreamSubscription resizeSubscription;
  StreamSubscription localeSubscription;
  StreamSubscription visibilitySubscription;

  StreamSubscription pointerCancelSubscription;
  StreamSubscription pointerEnterSubscription;
  StreamSubscription pointerLeaveSubscription;
  StreamSubscription pointerDownSubscription;
  StreamSubscription pointerMoveSubscription;
  StreamSubscription pointerUpSubscription;

  _WebHooks(html.CanvasElement stage) {
    this.stage = stage;
    context2d = this.stage.getContext('2d', {'alpha': false});

    addHooks();
  }

  void addHooks() {
    // register callbacks for window;
    _scheduleFrameHook = onScheduleFrame;
    _sendPlatformMessageHook = onSendPlatformMessage;
    _updateSemanticsHook = onUpdateSemantics;
    _renderHook = onRender;

    // window metrics
    updateWindowMetrics();
    resizeSubscription = html.window.onResize.listen((html.Event event) {
      updateWindowMetrics();
    });

    // locale
    updateLocale();
    localeSubscription =
        html.window.on['languagechange'].listen((html.Event event) {
      updateLocale();
    });

    // semantics
    updateSemanticsEnabled(false);

    // app visibility
    visibilitySubscription =
        html.document.onVisibilityChange.listen((html.Event e) {});

    // pointer events
    pointerCancelSubscription =
        stage.on['pointercancel'].listen(onPointerUpdate);
    pointerEnterSubscription = stage.on['pointerenter'].listen(onPointerUpdate);
    pointerLeaveSubscription = stage.on['pointerleave'].listen(onPointerUpdate);
    pointerDownSubscription = stage.on['pointerdown'].listen(onPointerUpdate);
    pointerMoveSubscription = stage.on['pointermove'].listen(onPointerUpdate);
    pointerUpSubscription = stage.on['pointerup'].listen(onPointerUpdate);
  }

  void dispose() {
    resizeSubscription.cancel();
    localeSubscription.cancel();
    visibilitySubscription.cancel();

    pointerCancelSubscription.cancel();
    pointerEnterSubscription.cancel();
    pointerLeaveSubscription.cancel();
    pointerDownSubscription.cancel();
    pointerMoveSubscription.cancel();
    pointerUpSubscription.cancel();

    _scheduleFrameHook = null;
    _sendPlatformMessageHook = null;
    _updateSemanticsHook = null;
    _renderHook = null;
  }

  void onPointerUpdate(html.Event event) {
    html.window.console.log(event);
    html.window.console.log(event.type);
  }

  // hooks

  void updateWindowMetrics() {
    window
      .._devicePixelRatio = html.window.devicePixelRatio.toDouble()
      .._physicalSize =
          new Size(stage.clientWidth.toDouble(), stage.clientHeight.toDouble())
      .._padding = WindowPadding.zero;
    if (window.onMetricsChanged != null) window.onMetricsChanged();
  }

  void updateLocale() {
    String language = '';
    String country = '';

    if (html.window.navigator.language is String &&
        html.window.navigator.language.contains('-')) {
      List<String> parts = html.window.navigator.language.split('-');
      language = parts[0];
      country = parts[1];
    } else if (html.window.navigator.languages[0] is String &&
        html.window.navigator.languages[0].contains('-')) {
      List<String> parts = html.window.navigator.languages[0].split('-');
      language = parts[0];
      country = parts[1];
    } else {
      language = html.window.navigator.language;
      country = language.toUpperCase();
    }

    window._locale = new Locale(language, country);
    if (window.onLocaleChanged != null) window.onLocaleChanged();
  }

  void updateSemanticsEnabled(bool enabled) {
    window._semanticsEnabled = enabled;
    if (window.onSemanticsEnabledChanged != null)
      window.onSemanticsEnabledChanged();
  }

  void _handleNavigationMessage(ByteData data) {
    if (window._defaultRouteName != null) return;
    try {
      final dynamic message = _decodeJSON(_decodeUTF8(data));
      final dynamic method = message['method'];
      if (method != 'pushRoute') return;
      final dynamic args = message['args'];
      window._defaultRouteName = args[0];
    } catch (e) {
      // We ignore any exception and just let the message be dispatched as usual.
    }
  }

  void dispatchPlatformMessage(String name, ByteData data, int responseId) {
    if (name == 'flutter/navigation') _handleNavigationMessage(data);

    if (window.onPlatformMessage != null) {
      window.onPlatformMessage(name, data, (ByteData responseData) {
        respondToPlatformMessage(responseId, responseData);
      });
    } else {
      respondToPlatformMessage(responseId, null);
    }
  }

  void respondToPlatformMessage(int responseId, ByteData data) {
    throw new UnimplementedError();
  }

  void dispatchPointerDataPacket(PointerDataPacket packet) {
    if (window.onPointerDataPacket != null) window.onPointerDataPacket(packet);
  }

  void dispatchSemanticsAction(int id, int action) {
    if (window.onSemanticsAction != null)
      window.onSemanticsAction(id, SemanticsAction.values[action]);
  }

  void onScheduleFrame() {
    html.window.requestAnimationFrame((num highResTime) {
      if (window.onBeginFrame != null)
        window.onBeginFrame(new Duration(microseconds: highResTime.toInt()));
    });
  }

  void onSendPlatformMessage(
      String name, PlatformMessageResponseCallback callback, ByteData data) {
    throw new UnimplementedError();
  }

  void onUpdateSemantics(SemanticsUpdate update) {
    throw new UnimplementedError();
  }

  void onRender(Scene scene) {
    throw new UnimplementedError();
  }
}
