// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:sky/material.dart';
import 'package:sky/rendering.dart';
import 'package:sky/widgets.dart';

class ScaleApp extends StatefulComponent {
  ScaleAppState createState() => new ScaleAppState();
}

class ScaleAppState extends State<ScaleApp> {
  void initState() {
    super.initState();
    _offset = Offset.zero;
    _zoom = 1.0;
  }

  Point _startingFocalPoint;

  Offset _previousOffset;
  Offset _offset;

  double _previousZoom;
  double _zoom;

  void _handleScaleStart(Point focalPoint) {
    setState(() {
      _startingFocalPoint = focalPoint;
      _previousOffset = _offset;
      _previousZoom = _zoom;
    });
  }

  void _handleScaleUpdate(double scale, Point focalPoint) {
    setState(() {
      _zoom = (_previousZoom * scale);

      // Ensure that item under the focal point stays in the same place despite zooming
      Offset normalizedOffset = (_startingFocalPoint.toOffset() - _previousOffset) / _previousZoom;
      _offset = focalPoint.toOffset() - normalizedOffset * _zoom;
    });
  }

  void paint(PaintingCanvas canvas, Size size) {
    Point center = (size.center(Point.origin).toOffset() * _zoom + _offset).toPoint();
    double radius = size.width / 2.0 * _zoom;
    Gradient gradient = new RadialGradient(
      center: center, radius: radius,
      colors: [Colors.blue[200], Colors.blue[800]]
    );
    Paint paint = new Paint()
      ..shader = gradient.createShader();
    canvas.drawCircle(center, radius, paint);
  }

  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData.dark(),
      child: new Scaffold(
        toolbar: new ToolBar(
            center: new Text('Scale Demo')),
        body: new Material(
          type: MaterialType.canvas,
          child: new GestureDetector(
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            child: new CustomPaint(callback: paint, token: "$_zoom $_offset")
          )
        )
      )
    );
  }
}

void main() => runApp(new ScaleApp());
