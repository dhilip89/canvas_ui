// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the CHROMIUM_LICENSE file.

part of canvas_ui;

/// An opaque object representing a composited scene.
///
/// To create a Scene object, use a [SceneBuilder].
///
/// Scene objects can be displayed on the screen using the
/// [Window.render] method.
class Scene {
  /// Creates an uninitialized Scene object.
  ///
  /// Calling the Scene constructor directly will not create a useable
  /// object. To create a Scene object, use a [SceneBuilder].
  Scene(); // (this constructor is here just so we can document it)

  /// Releases the resources used by this scene.
  ///
  /// After calling this function, the scene is cannot be used further.
  void dispose() => throw new UnimplementedError();
}

/// Builds a [Scene] containing the given visuals.
///
/// A [Scene] can then be rendered using [Window.render].
///
/// To draw graphical operations onto a [Scene], first create a
/// [Picture] using a [PictureRecorder] and a [Canvas], and then add
/// it to the scene using [addPicture].
class SceneBuilder {
  /// Creates an empty [SceneBuilder] object.
  SceneBuilder() {
    throw new UnimplementedError();
  }

  /// Pushes a transform operation onto the operation stack.
  ///
  /// The objects are transformed by the given matrix before rasterization.
  ///
  /// See [pop] for details about the operation stack.
  void pushTransform(Float64List matrix4) {
    if (matrix4 == null)
      throw new ArgumentError("[matrix4] argument cannot be null");
    if (matrix4.length != 16)
      throw new ArgumentError("[matrix4] must have 16 entries.");

    throw new UnimplementedError();
  }

  /// Pushes a rectangular clip operation onto the operation stack.
  ///
  /// Rasterization outside the given rectangle is discarded.
  ///
  /// See [pop] for details about the operation stack.
  void pushClipRect(Rect rect) => throw new UnimplementedError();

  /// Pushes a rounded-rectangular clip operation onto the operation stack.
  ///
  /// Rasterization outside the given rounded rectangle is discarded.
  ///
  /// See [pop] for details about the operation stack.
  void pushClipRRect(RRect rrect) => throw new UnimplementedError();

  /// Pushes a path clip operation onto the operation stack.
  ///
  /// Rasterization outside the given path is discarded.
  ///
  /// See [pop] for details about the operation stack.
  void pushClipPath(Path path) => throw new UnimplementedError();

  /// Pushes an opacity operation onto the operation stack.
  ///
  /// The given alpha value is blended into the alpha value of the objects'
  /// rasterization. An alpha value of 0 makes the objects entirely invisible.
  /// An alpha value of 255 has no effect (i.e., the objects retain the current
  /// opacity).
  ///
  /// See [pop] for details about the operation stack.
  void pushOpacity(int alpha) => throw new UnimplementedError();

  /// Pushes a color filter operation onto the operation stack.
  ///
  /// The given color is applied to the objects' rasterization using the given
  /// transfer mode.
  ///
  /// See [pop] for details about the operation stack.
  void pushColorFilter(Color color, TransferMode transferMode) =>
      throw new UnimplementedError();

  /// Pushes a backdrop filter operation onto the operation stack.
  ///
  /// The given filter is applied to the current contents of the scene prior to
  /// rasterizing the given objects.
  ///
  /// See [pop] for details about the operation stack.
  void pushBackdropFilter(ImageFilter filter) => throw new UnimplementedError();

  /// Pushes a shader mask operation onto the operation stack.
  ///
  /// The given shader is applied to the object's rasterization in the given
  /// rectangle using the given transfer mode.
  ///
  /// See [pop] for details about the operation stack.
  void pushShaderMask(
          Shader shader, Rect maskRect, TransferMode transferMode) =>
      throw new UnimplementedError();

  /// Ends the effect of the most recently pushed operation.
  ///
  /// Internally the scene builder maintains a stack of operations. Each of the
  /// operations in the stack applies to each of the objects added to the scene.
  /// Calling this function removes the most recently added operation from the
  /// stack.
  void pop() => throw new UnimplementedError();

  /// Adds an object to the scene that displays performance statistics.
  ///
  /// Useful during development to assess the performance of the application.
  /// The enabledOptions controls which statistics are displayed. The bounds
  /// controls where the statistics are displayed.
  ///
  /// enabledOptions is a bit field with the following bits defined:
  ///  - 0x01: displayRasterizerStatistics - show GPU thread frame time
  ///  - 0x02: visualizeRasterizerStatistics - graph GPU thread frame times
  ///  - 0x04: displayEngineStatistics - show UI thread frame time
  ///  - 0x08: visualizeEngineStatistics - graph UI thread frame times
  /// Set enabledOptions to 0x0F to enable all the currently defined features.
  ///
  /// The "UI thread" is the thread that includes all the execution of
  /// the main Dart isolate (the isolate that can call
  /// [Window.render]). The UI thread frame time is the total time
  /// spent executing the [Window.onBeginFrame] callback. The "GPU
  /// thread" is the thread (running on the CPU) that subsequently
  /// processes the [Scene] provided by the Dart code to turn it into
  /// GPU commands and send it to the GPU.
  ///
  /// See also the [PerformanceOverlayOption] enum in the rendering library.
  /// for more details.
  void addPerformanceOverlay(int enabledOptions, Rect bounds) =>
      throw new UnimplementedError();

  /// Adds a [Picture] to the scene.
  ///
  /// The picture is rasterized at the given offset.
  void addPicture(Offset offset, Picture picture,
      {bool isComplexHint: false, bool willChangeHint: false}) {
    int hints = 0;
    if (isComplexHint) hints |= 1;
    if (willChangeHint) hints |= 2;
    throw new UnimplementedError();
  }

  /// (Fuchsia-only) Adds a scene rendered by another application to the scene
  /// for this application.
  ///
  /// Applications typically obtain scene tokens when embedding other views via
  /// the Fuchsia view manager, but this function is agnostic as to the source
  /// of scene token.
  void addChildScene(Offset offset, double devicePixelRatio, int physicalWidth,
          int physicalHeight, int sceneToken) =>
      throw new UnimplementedError();

  /// Sets a threshold after which additional debugging information should be recorded.
  ///
  /// Currently this interface is difficult to use by end-developers. If you're
  /// interested in using this feature, please contact [flutter-dev](https://groups.google.com/forum/#!forum/flutter-dev).
  /// We'll hopefully be able to figure out how to make this feature more useful
  /// to you.
  void setRasterizerTracingThreshold(int frameInterval) =>
      throw new UnimplementedError();

  /// Sets whether the raster cache should checkerboard cached entries. This is
  /// only useful for debugging purposes.
  ///
  /// The compositor can sometimes decide to cache certain portions of the
  /// widget hierarchy. Such portions typically don't change often from frame to
  /// frame and are expensive to render. This can speed up overall rendering. However,
  /// there is certain upfront cost to constructing these cache entries. And, if
  /// the cache entries are not used very often, this cost may not be worth the
  /// speedup in rendering of subsequent frames. If the developer wants to be certain
  /// that populating the raster cache is not causing stutters, this option can be
  /// set. Depending on the observations made, hints can be provided to the compositor
  /// that aid it in making better decisions about caching.
  ///
  /// Currently this interface is difficult to use by end-developers. If you're
  /// interested in using this feature, please contact [flutter-dev](https://groups.google.com/forum/#!forum/flutter-dev).
  void setCheckerboardRasterCacheImages(bool checkerboard) =>
      throw new UnimplementedError();

  /// Finishes building the scene.
  ///
  /// Returns a [Scene] containing the objects that have been added to
  /// this scene builder. The [Scene] can then be displayed on the
  /// screen with [Window.render].
  ///
  /// After calling this function, the scene builder object is invalid and
  /// cannot be used further.
  Scene build() => throw new UnimplementedError();
}
