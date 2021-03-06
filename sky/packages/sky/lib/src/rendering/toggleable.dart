// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:sky' as sky;

import 'package:sky/animation.dart';
import 'package:sky/gestures.dart';
import 'package:sky/src/rendering/binding.dart';
import 'package:sky/src/rendering/box.dart';
import 'package:sky/src/rendering/object.dart';
import 'package:sky/src/rendering/proxy_box.dart';

typedef void ValueChanged(bool value);

const Duration _kToggleDuration = const Duration(milliseconds: 200);

// RenderToggleable is a base class for material style toggleable controls with
// toggle animations. It handles storing the current value, dispatching
// ValueChanged on a tap gesture and driving a changed animation. Subclasses are
// responsible for painting.
abstract class RenderToggleable extends RenderConstrainedBox {
  RenderToggleable({bool value, Size size, ValueChanged onChanged})
      : _value = value,
        _onChanged = onChanged,
        super(additionalConstraints: new BoxConstraints.tight(size)) {
    _performance = new ValueAnimation<double>(
      variable: new AnimatedValue<double>(0.0, end: 1.0, curve: easeIn, reverseCurve: easeOut),
      duration: _kToggleDuration,
      progress: _value ? 1.0 : 0.0
    )..addListener(markNeedsPaint);
  }

  ValueAnimation<double> get performance => _performance;
  ValueAnimation<double> _performance;

  double get position => _performance.value;

  void handleEvent(sky.Event event, BoxHitTestEntry entry) {
    if (event.type == 'pointerdown')
      _tap.addPointer(event);
  }

  TapGestureRecognizer _tap;

  void attach() {
    super.attach();
    _tap = new TapGestureRecognizer(
      router: FlutterBinding.instance.pointerRouter,
      onTap: _handleTap
    );
  }

  void detach() {
    _tap.dispose();
    _tap = null;
    super.detach();
  }

  void _handleTap() {
    if (_onChanged != null)
      _onChanged(!_value);
  }

  bool get value => _value;
  bool _value;
  void set value(bool value) {
    if (value == _value)
      return;
    _value = value;
    performance.play(value ? Direction.forward : Direction.reverse);
  }

  ValueChanged get onChanged => _onChanged;
  ValueChanged _onChanged;
  void set onChanged(ValueChanged onChanged) {
    _onChanged = onChanged;
  }
}
