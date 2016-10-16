// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/painting.dart';

import 'package:test/test.dart';

void main() {
  test("RRect.contains()", () {
    RRect rrect = new RRect.fromRectAndCorners(
      new Rect.fromLTRB(1.0, 1.0, 2.0, 2.0),
      topLeft: const Radius.circular(0.5),
      topRight: const Radius.circular(0.25),
      bottomRight: const Radius.elliptical(0.25, 0.75),
      bottomLeft: Radius.zero
    );

    expect(rrect.contains(const Point(1.0, 1.0)), isFalse);
    expect(rrect.contains(const Point(1.1, 1.1)), isFalse);
    expect(rrect.contains(const Point(1.15, 1.15)), isTrue);
    expect(rrect.contains(const Point(2.0, 1.0)), isFalse);
    expect(rrect.contains(const Point(1.93, 1.07)), isFalse);
    expect(rrect.contains(const Point(1.97, 1.7)), isFalse);
    expect(rrect.contains(const Point(1.7, 1.97)), isTrue);
    expect(rrect.contains(const Point(1.0, 1.99)), isTrue);
  });

  test("RRect.contains() large radii", () {
    RRect rrect = new RRect.fromRectAndCorners(
      new Rect.fromLTRB(1.0, 1.0, 2.0, 2.0),
      topLeft: const Radius.circular(5000.0),
      topRight: const Radius.circular(2500.0),
      bottomRight: const Radius.elliptical(2500.0, 7500.0),
      bottomLeft: Radius.zero
    );

    expect(rrect.contains(const Point(1.0, 1.0)), isFalse);
    expect(rrect.contains(const Point(1.1, 1.1)), isFalse);
    expect(rrect.contains(const Point(1.15, 1.15)), isTrue);
    expect(rrect.contains(const Point(2.0, 1.0)), isFalse);
    expect(rrect.contains(const Point(1.93, 1.07)), isFalse);
    expect(rrect.contains(const Point(1.97, 1.7)), isFalse);
    expect(rrect.contains(const Point(1.7, 1.97)), isTrue);
    expect(rrect.contains(const Point(1.0, 1.99)), isTrue);
  });
}
