// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the CHROMIUM_LICENSE file.

part of canvas_ui;

/// Mojo handles provided to the application at startup.
///
/// The application can take ownership of these handles by calling the static
/// "take" functions on this object. Once taken, the application is responsible
/// for managing the handles.
class MojoServices {
  MojoServices._();

  static int takeRootBundle() => throw new UnimplementedError();
  static int takeIncomingServices() => throw new UnimplementedError();
  static int takeOutgoingServices() => throw new UnimplementedError();
  static int takeShell() => throw new UnimplementedError();
  static int takeViewServices() => throw new UnimplementedError();
}
