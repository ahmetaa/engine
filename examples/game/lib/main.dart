// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:sky/material.dart';
import 'package:sky/painting.dart';
import 'package:sky/rendering.dart';
import 'package:sky/services.dart';
import 'package:sky/widgets.dart';
import 'package:skysprites/skysprites.dart';

import 'game_demo.dart';

AssetBundle _initBundle() {
  if (rootBundle != null)
    return rootBundle;
  return new NetworkAssetBundle(new Uri.directory(Uri.base.origin));
}

final AssetBundle _bundle = _initBundle();

ImageMap _imageMap;
SpriteSheet _spriteSheet;
SpriteSheet _spriteSheetUI;
Map<String,SoundEffect> _sounds = {};

main() async {
  _imageMap = new ImageMap(_bundle);

  // Use a list to wait on all loads in parallel just before starting the app.
  List loads = [];

  loads.add(_imageMap.load([
    'assets/nebula.png',
    'assets/sprites.png',
    'assets/starfield.png',
    'assets/game_ui.png',
  ]));

  // TODO(eseidel): SoundEffect doesn't really do anything except hold a future.
  _sounds['explosion'] = new SoundEffect(_bundle.load('assets/explosion.wav'));
  _sounds['laser'] = new SoundEffect(_bundle.load('assets/laser.wav'));

  loads.addAll([
    _sounds['explosion'].load(),
    _sounds['laser'].load(),
  ]);

  await Future.wait(loads);

  // TODO(eseidel): These load in serial which is bad for startup!
  String json = await _bundle.loadString('assets/sprites.json');
  _spriteSheet = new SpriteSheet(_imageMap['assets/sprites.png'], json);

  json = await _bundle.loadString('assets/game_ui.json');
  _spriteSheetUI = new SpriteSheet(_imageMap['assets/game_ui.png'], json);

  assert(_spriteSheet.image != null);

  SoundTrackPlayer stPlayer = SoundTrackPlayer.sharedInstance();
  SoundTrack music = await stPlayer.load(_bundle.load('assets/temp_music.aac'));
  stPlayer.play(music);

  runApp(new GameDemo());
}

// TODO(viktork): The task bar purple is the wrong purple, we may need
// a custom theme swatch to match the purples in the sprites.
final ThemeData _theme = new ThemeData(
  brightness: ThemeBrightness.light,
  primarySwatch: Colors.purple
);

class GameDemo extends StatefulComponent {
  GameDemoState createState() => new GameDemoState();
}

class GameDemoState extends State<GameDemo> {
  NodeWithSize _game;
  int _lastScore = 0;

  Widget build(BuildContext context) {
    return new App(
      title: 'Asteroids',
      theme: _theme,
      routes: {
        '/': _buildMainScene,
        '/game': _buildGameScene
      }
    );
  }

  Widget _buildGameScene(NavigatorState navigator, Route route) {
    return new SpriteWidget(_game, SpriteBoxTransformMode.fixedWidth);
  }

  Widget _buildMainScene(navigator, route) {
    return new Stack([
      new SpriteWidget(new MainScreenBackground(), SpriteBoxTransformMode.fixedWidth),
      new Column([
          new TextureButton(
            onPressed: () {
              _game = new GameDemoNode(
                _imageMap,
                _spriteSheet,
                _spriteSheetUI,
                _sounds,
                (lastScore) {
                  setState(() {_lastScore = lastScore;});
                  navigator.pop();
                }
              );
              navigator.pushNamed('/game');
            },
            texture: _spriteSheetUI['btn_play_up.png'],
            textureDown: _spriteSheetUI['btn_play_down.png'],
            width: 128.0,
            height: 128.0
          ),
          new Text(
            "Last Score: $_lastScore",
            style: new TextStyle(fontSize:20.0)
          )
        ],
        justifyContent: FlexJustifyContent.center
      )
    ]);
  }
}

class TextureButton extends StatefulComponent {
  TextureButton({
    Key key,
    this.onPressed,
    this.texture,
    this.textureDown,
    this.width: 128.0,
    this.height: 128.0
  }) : super(key: key);

  final Function onPressed;
  final Texture texture;
  final Texture textureDown;
  final double width;
  final double height;

  TextureButtonState createState() => new TextureButtonState();
}

class TextureButtonState extends ButtonState<TextureButton> {
  Widget buildContent(BuildContext context) {
    return new Listener(
      child: new Container(
        width: config.width,
        height: config.height,
        child: new CustomPaint(
          callback: paintCallback,
          token: new _TextureButtonToken(
            highlight,
            config.texture,
            config.textureDown,
            config.width,
            config.height
          )
        )
      ),
      onPointerUp: (_) {
        if (config.onPressed != null)
          config.onPressed();
      }
    );
  }

  void paintCallback(PaintingCanvas canvas, Size size) {
    if (config.texture == null)
      return;

    canvas.save();
    if (highlight && config.textureDown != null) {
      // Draw down state
      canvas.scale(size.width / config.textureDown.size.width, size.height / config.textureDown.size.height);
      config.textureDown.drawTexture(canvas, Point.origin, new Paint());
    } else {
      // Draw up state
      canvas.scale(size.width / config.texture.size.width, size.height / config.texture.size.height);
      config.texture.drawTexture(canvas, Point.origin, new Paint());
    }
    canvas.restore();
  }
}

class _TextureButtonToken {
  _TextureButtonToken(
    this._highlight,
    this._texture,
    this._textureDown,
    this._width,
    this._height
  );

  final bool _highlight;
  final Texture _texture;
  final Texture _textureDown;
  final double _width;
  final double _height;

  bool operator== (other) {
    return
      other is _TextureButtonToken &&
      _highlight == other._highlight &&
      _texture == other._texture &&
      _textureDown == other._textureDown &&
      _width == other._width &&
      _height == other._height;
  }

  int get hashCode {
    int value = 373;
    value = 37 * value * _highlight.hashCode;
    value = 37 * value * _texture.hashCode;
    value = 37 * value * _textureDown.hashCode;
    value = 37 * value * _width.hashCode;
    value = 37 * value * _height.hashCode;
    return value;
  }
}

class MainScreenBackground extends NodeWithSize {
  MainScreenBackground() : super(new Size(320.0, 320.0)) {
    assert(_spriteSheet.image != null);

    StarField starField = new StarField(_spriteSheet, 200, true);
    addChild(starField);
  }

  void paint(PaintingCanvas canvas) {
    canvas.drawRect(new Rect.fromLTWH(0.0, 0.0, 320.0, 320.0), new Paint()..color=new Color(0xff000000));
    super.paint(canvas);
  }
}
