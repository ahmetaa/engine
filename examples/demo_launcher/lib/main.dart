// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:sky/material.dart';
import 'package:sky/painting.dart';
import 'package:sky/services.dart';
import 'package:sky/widgets.dart';

AssetBundle _initBundle() {
  if (rootBundle != null)
    return rootBundle;
  const String _kAssetBase = '..';
  return new NetworkAssetBundle(Uri.base.resolve(_kAssetBase));
}

final AssetBundle _bundle = _initBundle();

void launch(String relativeUrl, String bundle) {
  // TODO(eseidel): This is a hack to keep non-skyx examples working for now:
  Uri productionBase = Uri.parse(
    'https://domokit.github.io/example/demo_launcher/lib/main.dart');
  Uri base = rootBundle == null ? Uri.base : productionBase;
  Uri url = base.resolve(relativeUrl);

  ComponentName component = new ComponentName()
    ..packageName = 'org.domokit.sky.demo'
    ..className = 'org.domokit.sky.demo.SkyDemoActivity';
  Intent intent = new Intent()
    ..action = 'android.intent.action.VIEW'
    ..component = component
    ..flags = MULTIPLE_TASK | NEW_DOCUMENT
    ..url = url.toString();

  if (bundle != null) {
    StringExtra extra = new StringExtra()
      ..name = 'bundleName'
      ..value = bundle;
    intent.stringExtras = [extra];
  }

  activity.startActivity(intent);
}

class FlutterDemo {
  FlutterDemo({
    name,
    this.href,
    this.bundle,
    this.description,
    this.textTheme,
    this.decoration
  }) : name = name, key = new Key(name);
  final String name;
  final Key key;
  final String href;
  final String bundle;
  final String description;
  final TextTheme textTheme;
  final BoxDecoration decoration;
}

List<FlutterDemo> demos = [
  new FlutterDemo(
    name: 'Stocks',
    href: '../../stocks/lib/main.dart',
    bundle: 'stocks.skyx',
    description: 'Multi-screen app with scrolling list',
    textTheme: Typography.black,
    decoration: new BoxDecoration(
      backgroundImage: new BackgroundImage(
        image: _bundle.loadImage('assets/stocks_thumbnail.png'),
        fit: ImageFit.cover
      )
    )
  ),
  new FlutterDemo(
    name: 'Asteroids',
    href: '../../game/lib/main.dart',
    bundle: 'game.skyx',
    description: '2D game using sprite sheets',
    textTheme: Typography.white,
    decoration: new BoxDecoration(
      backgroundImage: new BackgroundImage(
        image: _bundle.loadImage('assets/game_thumbnail.png'),
        fit: ImageFit.cover
      )
    )
  ),
  new FlutterDemo(
    name: 'Fitness',
    href: '../../fitness/lib/main.dart',
    bundle: 'fitness.skyx',
    description: 'Track progress towards healthy goals',
    textTheme: Typography.white,
    decoration: new BoxDecoration(
      backgroundColor: Colors.indigo[500]
    )
  ),
  new FlutterDemo(
    name: 'Swipe Away',
    href: '../../widgets/card_collection.dart',
    bundle: 'cards.skyx',
    description: 'Infinite list of swipeable cards',
    textTheme: Typography.white,
    decoration: new BoxDecoration(
      backgroundColor: Colors.redAccent[200]
    )
  ),
  new FlutterDemo(
    name: 'Interactive Text',
    href: '../../rendering/interactive_flex.dart',
    bundle: 'interactive_flex.skyx',
    description: 'Swipe to reflow the app',
    textTheme: Typography.white,
    decoration: new BoxDecoration(
      backgroundColor: const Color(0xFF0081C6)
    )
  ),
  // new SkyDemo(

  //   'Touch Demo', '../../rendering/touch_demo.dart', 'Simple example showing handling of touch events at a low level'),
  new FlutterDemo(
    name: 'Minedigger Game',
    href: '../../mine_digger/lib/main.dart',
    bundle: 'mine_digger.skyx',
    description: 'Clone of the classic Minesweeper game',
    textTheme: Typography.white,
    decoration: new BoxDecoration(
      backgroundColor: Colors.black
    )
  ),

  // TODO(jackson): This doesn't seem to be working
  // new SkyDemo('Licenses', 'LICENSES.sky'),
];

const double kCardHeight = 120.0;
const EdgeDims kListPadding = const EdgeDims.all(4.0);

class DemoCard extends StatelessComponent {
  DemoCard({ Key key, this.demo }) : super(key: key);

  final FlutterDemo demo;

  Widget build(BuildContext context) {
    return new Container(
      height: kCardHeight,
      child: new Card(
        child: new Container(
          decoration: demo.decoration,
          child: new InkWell(
            onTap: () => launch(demo.href, demo.bundle),
            child: new Container(
              margin: const EdgeDims.only(top: 24.0, left: 24.0),
              child: new Column([
                  new Text(demo.name, style: demo.textTheme.title),
                  new Flexible(
                    child: new Text(demo.description, style: demo.textTheme.subhead)
                  )
                ],
                alignItems: FlexAlignItems.start
              )
            )
          )
        )
      )
    );
  }
}

class DemoList extends StatelessComponent {
  Widget _buildDemoCard(BuildContext context, FlutterDemo demo) {
    return new DemoCard(key: demo.key, demo: demo);
  }

  Widget build(BuildContext context) {
    return new ScrollableList<FlutterDemo>(
      items: demos,
      itemExtent: kCardHeight,
      itemBuilder: _buildDemoCard,
      padding: kListPadding
    );
  }
}

final ThemeData _theme = new ThemeData(
  brightness: ThemeBrightness.light,
  primarySwatch: Colors.teal
);

class DemoHome extends StatelessComponent {
  Widget build(BuildContext context) {
    return new Scaffold(
      toolbar: new ToolBar(center: new Text('Sky Demos')),
      body: new Material(
        type: MaterialType.canvas,
        child: new DemoList()
      )
    );
  }
}

void main() {
  runApp(new App(
    title: 'Flutter Demos',
    theme: _theme,
    routes: {
      '/': (NavigatorState navigator, Route route) => new DemoHome()
    }
  ));
}
