part of canvas_ui;

_WebHooks _webHooks;

void setupCanvasUI(html.CanvasElement stage) {
  _webHooks = new _WebHooks(stage);
}

void disposeCanvasUI() {
  _webHooks.dispose();
}

class _WebHooks {
  final html.CanvasElement stage;
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

  _WebHooks(html.CanvasElement stage) : this.stage = stage {
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

    // routes
    pushRoute();

    window.scheduleFrame = onScheduleFrame;

    visibilitySubscription =
        html.document.onVisibilityChange.listen((html.Event event) {
      updateAppLifecycleState(!html.document.hidden);
    });

    pointerCancelSubscription =
        stage.on['pointercancel'].listen(onPointerCancel);
    pointerEnterSubscription = stage.on['pointerenter'].listen(onPointerEnter);
    pointerLeaveSubscription = stage.on['pointerleave'].listen(onPointerLeave);
    pointerDownSubscription = stage.on['pointerdown'].listen(onPointerDown);
    pointerMoveSubscription = stage.on['pointermove'].listen(onPointerMove);
    pointerUpSubscription = stage.on['pointerup'].listen(onPointerUp);
  }

  void onPointerCancel(html.Event event) {
    html.window.console.log(event);
  }

  void onPointerEnter(html.Event event) {
    html.window.console.log(event);
  }

  void onPointerLeave(html.Event event) {
    html.window.console.log(event);
  }

  void onPointerDown(html.Event event) {
    html.window.console.log(event);
  }

  void onPointerMove(html.Event event) {
    html.window.console.log(event);
  }

  void onPointerUp(html.Event event) {
    html.window.console.log(event);
  }

  void dispose() {
    resizeSubscription.cancel();
    visibilitySubscription.cancel();
  }

  // hooks

  void updateWindowMetrics() {
    window
      .._devicePixelRatio = html.window.devicePixelRatio.toDouble()
      .._physicalSize =
          new Size(stage.clientWidth.toDouble(), stage.clientHeight.toDouble())
      .._padding =
          new WindowPadding._(top: 0.0, right: 0.0, bottom: 0.0, left: 0.0);
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

  void pushRoute() {
//    html.window.console.log(html.window.location);
  }

  void updateAppLifecycleState(bool visible) {
    int value = visible ? 1 : 0;

    _onAppLifecycleStateChanged(value);
  }

  void onScheduleFrame() {
    html.window.requestAnimationFrame((num highResTime) {
      _beginFrame(highResTime.toInt());
    });
  }
}
