// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';

import '../rendering/rendering_tester.dart';
import '../../../../examples/layers/rendering/custom_coordinate_systems.dart';

void main() {
  test('Sector layout can paint', () {
    layout(buildSectorExample(), phase: EnginePhase.composite);
  });
}
