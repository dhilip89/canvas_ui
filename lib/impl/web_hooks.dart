part of canvas_ui;

_WebHooks _webHooks;

void setupWebHooks(html.CanvasElement stage) {
  _webHooks = new _WebHooks(stage);
}

class _WebHooks {
  final html.CanvasElement stage;
  int handle;
  StreamSubscription resizeSubscription;
  StreamSubscription visibilitySubscription;

  _WebHooks(html.CanvasElement stage) : this.stage = stage {
    _updateSemanticsEnabled(false);

    onResize(null);
    resizeSubscription = html.window.onResize.listen(onResize);

    window.scheduleFrame = scheduleFrame;

    visibilitySubscription =
        html.document.onVisibilityChange.listen((html.Event event) {
      int value;

      if (html.document.hidden)
        value = 0;
      else
        value = 1;

      _onAppLifecycleStateChanged(value);
    });
  }

  void dispose() {
    resizeSubscription.cancel();
    visibilitySubscription.cancel();
  }

  void scheduleFrame() {
    html.window.requestAnimationFrame((num highResTime) {
      _beginFrame(highResTime.toInt());
    });
  }

  void onResize(html.Event event) {
    _updateWindowMetrics(devicePixelRatio, width, height, 0.0, 0.0, 0.0, 0.0);
  }

  double get devicePixelRatio => html.window.devicePixelRatio.toDouble();

  double get width => stage.clientWidth.toDouble();

  double get height => stage.clientHeight.toDouble();
}
