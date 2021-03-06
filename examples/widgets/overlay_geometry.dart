// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:sky' as sky;

import 'package:sky/material.dart';
import 'package:sky/rendering.dart';
import 'package:sky/widgets.dart';

class CardModel {
  CardModel(this.value, this.height, this.color);
  int value;
  double height;
  Color color;
  String get label => "Card $value";
  Key get key => new ObjectKey(this);
  GlobalKey get targetKey => new GlobalObjectKey(this);
}

enum MarkerType { topLeft, bottomRight, touch }

class Marker extends StatelessComponent {
  Marker({
    this.type: MarkerType.touch,
    this.position,
    this.size: 40.0,
    Key key
  }) : super(key: key);

  final Point position;
  final double size;
  final MarkerType type;

  void paintMarker(sky.Canvas canvas, _) {
    Paint paint = new Paint()..color = const Color(0x8000FF00);
    paint.setStyle(sky.PaintingStyle.fill);
    double r = size / 2.0;
    canvas.drawCircle(new Point(r, r), r, paint);

    paint.color = const Color(0xFFFFFFFF);
    paint.setStyle(sky.PaintingStyle.stroke);
    paint.strokeWidth = 1.0;
    if (type == MarkerType.topLeft) {
      canvas.drawLine(new Point(r, r), new Point(r + r - 1.0, r), paint);
      canvas.drawLine(new Point(r, r), new Point(r, r + r - 1.0), paint);
    }
    if (type == MarkerType.bottomRight) {
      canvas.drawLine(new Point(r, r), new Point(1.0, r), paint);
      canvas.drawLine(new Point(r, r), new Point(r, 1.0), paint);
    }
  }

  Widget build(BuildContext context) {
    return new Positioned(
      left: position.x - size / 2.0,
      top: position.y - size / 2.0,
      child: new IgnorePointer(
        child: new Container(
          width: size,
          height: size,
          child: new CustomPaint(callback: paintMarker)
        )
      )
    );
  }
}

class OverlayGeometryApp extends StatefulComponent {
  OverlayGeometryAppState createState() => new OverlayGeometryAppState();
}

class OverlayGeometryAppState extends State<OverlayGeometryApp> {

  static const TextStyle cardLabelStyle =
    const TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: bold);

  List<CardModel> cardModels;
  Map<MarkerType, Point> markers = new Map<MarkerType, Point>();
  double markersScrollOffset;
  ScrollListener scrollListener;

  void initState() {
    super.initState();
    List<double> cardHeights = <double>[
      48.0, 63.0, 82.0, 146.0, 60.0, 55.0, 84.0, 96.0, 50.0,
      48.0, 63.0, 82.0, 146.0, 60.0, 55.0, 84.0, 96.0, 50.0,
      48.0, 63.0, 82.0, 146.0, 60.0, 55.0, 84.0, 96.0, 50.0
    ];
    cardModels = new List.generate(cardHeights.length, (i) {
      Color color = Color.lerp(Colors.red[300], Colors.blue[900], i / cardHeights.length);
      return new CardModel(i, cardHeights[i], color);
    });
  }

  void handleScroll(double offset) {
    setState(() {
      double dy = markersScrollOffset - offset;
      markersScrollOffset = offset;
      for (MarkerType type in markers.keys) {
        Point oldPosition = markers[type];
        markers[type] = new Point(oldPosition.x, oldPosition.y + dy);
      }
    });
  }

  void handlePointerDown(GlobalKey target, sky.PointerEvent event) {
    setState(() {
      markers[MarkerType.touch] = new Point(event.x, event.y);
      final RenderBox box = target.currentContext.findRenderObject();
      markers[MarkerType.topLeft] = box.localToGlobal(new Point(0.0, 0.0));
      final Size size = box.size;
      markers[MarkerType.bottomRight] = box.localToGlobal(new Point(size.width, size.height));
      final ScrollableState scrollable = findScrollableAncestor(target.currentContext);
      markersScrollOffset = scrollable.scrollOffset;
    });
  }

  Widget builder(BuildContext context, int index) {
    if (index >= cardModels.length)
      return null;
    CardModel cardModel = cardModels[index];
    return new Listener(
      key: cardModel.key,
      onPointerDown: (e) { return handlePointerDown(cardModel.targetKey, e); },
      child: new Card(
        key: cardModel.targetKey,
        color: cardModel.color,
        child: new Container(
          height: cardModel.height,
          padding: const EdgeDims.all(8.0),
          child: new Center(child: new Text(cardModel.label, style: cardLabelStyle))
        )
      )
    );
  }

  Widget build(BuildContext context) {
    List<Widget> layers = <Widget>[
      new Scaffold(
        toolbar: new ToolBar(center: new Text('Tap a Card')),
        body: new Container(
          padding: const EdgeDims.symmetric(vertical: 12.0, horizontal: 8.0),
          decoration: new BoxDecoration(backgroundColor: Theme.of(context).primarySwatch[50]),
          child: new ScrollableMixedWidgetList(
            builder: builder,
            token: cardModels.length,
            onScroll: handleScroll
          )
        )
      )
    ];
    for (MarkerType type in markers.keys)
      layers.add(new Marker(type: type, position: markers[type]));
    return new Stack(layers);
  }
}

void main() {
  runApp(new App(
    theme: new ThemeData(
      brightness: ThemeBrightness.light,
      primarySwatch: Colors.blue,
      accentColor: Colors.redAccent[200]
    ),
    title: 'Cards',
    routes: {
      '/': (navigator, route) => new OverlayGeometryApp()
    }
  ));
}
