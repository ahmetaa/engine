// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:sky';

import 'package:sky/rendering.dart';
import 'package:sky/material.dart';

void main() {
  var coloredBox = new RenderDecoratedBox(
    decoration: new BoxDecoration(
      gradient: new RadialGradient(
        center: Point.origin, radius: 500.0,
        colors: [Colors.yellow[500], Colors.blue[500]]),
      boxShadow: shadows[3])
  );
  var paddedBox = new RenderPadding(
    padding: const EdgeDims.all(50.0),
    child: coloredBox);
  new FlutterBinding(root: new RenderDecoratedBox(
    decoration: const BoxDecoration(
      backgroundColor: const Color(0xFFFFFFFF)
    ),
    child: paddedBox
  ));
}
