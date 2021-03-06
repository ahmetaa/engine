// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:sky/animation.dart';
import 'package:sky/src/widgets/basic.dart';
import 'package:sky/src/widgets/framework.dart';

import 'package:vector_math/vector_math_64.dart';

class AnimatedBoxConstraintsValue extends AnimatedValue<BoxConstraints> {
  AnimatedBoxConstraintsValue(BoxConstraints begin, { BoxConstraints end, Curve curve: linear })
    : super(begin, end: end, curve: curve);

  BoxConstraints lerp(double t) => BoxConstraints.lerp(begin, end, t);
}

class AnimatedBoxDecorationValue extends AnimatedValue<BoxDecoration> {
  AnimatedBoxDecorationValue(BoxDecoration begin, { BoxDecoration end, Curve curve: linear })
    : super(begin, end: end, curve: curve);

  BoxDecoration lerp(double t) => BoxDecoration.lerp(begin, end, t);
}

class AnimatedEdgeDimsValue extends AnimatedValue<EdgeDims> {
  AnimatedEdgeDimsValue(EdgeDims begin, { EdgeDims end, Curve curve: linear })
    : super(begin, end: end, curve: curve);

  EdgeDims lerp(double t) => EdgeDims.lerp(begin, end, t);
}

class AnimatedMatrix4Value extends AnimatedValue<Matrix4> {
  AnimatedMatrix4Value(Matrix4 begin, { Matrix4 end, Curve curve: linear })
    : super(begin, end: end, curve: curve);

  Matrix4 lerp(double t) {
    // TODO(mpcomplete): Animate the full matrix. Will animating the cells
    // separately work?
    Vector3 beginT = begin.getTranslation();
    Vector3 endT = end.getTranslation();
    Vector3 lerpT = beginT*(1.0-t) + endT*t;
    return new Matrix4.identity()..translate(lerpT);
  }
}

class AnimatedContainer extends StatefulComponent {
  AnimatedContainer({
    Key key,
    this.child,
    this.constraints,
    this.decoration,
    this.foregroundDecoration,
    this.margin,
    this.padding,
    this.transform,
    this.width,
    this.height,
    this.curve: linear,
    this.duration
  }) : super(key: key) {
    assert(margin == null || margin.isNonNegative);
    assert(padding == null || padding.isNonNegative);
    assert(curve != null);
    assert(duration != null);
  }

  final Widget child;
  final BoxConstraints constraints;
  final BoxDecoration decoration;
  final BoxDecoration foregroundDecoration;
  final EdgeDims margin;
  final EdgeDims padding;
  final Matrix4 transform;
  final double width;
  final double height;

  final Curve curve;
  final Duration duration;

  AnimatedContainerState createState() => new AnimatedContainerState();
}

class AnimatedContainerState extends State<AnimatedContainer> {
  AnimatedBoxConstraintsValue _constraints;
  AnimatedBoxDecorationValue _decoration;
  AnimatedBoxDecorationValue _foregroundDecoration;
  AnimatedEdgeDimsValue _margin;
  AnimatedEdgeDimsValue _padding;
  AnimatedMatrix4Value _transform;
  AnimatedValue<double> _width;
  AnimatedValue<double> _height;

  AnimationPerformance _performance;

  void initState() {
    super.initState();
    _performance = new AnimationPerformance(duration: config.duration)
      ..timing = new AnimationTiming(curve: config.curve)
      ..addListener(_updateAllVariables);
    _configAllVariables();
  }

  void didUpdateConfig(AnimatedContainer oldConfig) {
    _performance
      ..duration = config.duration
      ..timing.curve = config.curve;
    if (_configAllVariables()) {
      _performance.progress = 0.0;
      _performance.play();
    }
  }

  void dispose() {
    _performance.stop();
    super.dispose();
  }

  void _updateVariable(AnimatedVariable variable) {
    if (variable != null)
      _performance.updateVariable(variable);
  }

  void _updateAllVariables() {
    setState(() {
      _updateVariable(_constraints);
      _updateVariable(_constraints);
      _updateVariable(_decoration);
      _updateVariable(_foregroundDecoration);
      _updateVariable(_margin);
      _updateVariable(_padding);
      _updateVariable(_transform);
      _updateVariable(_width);
      _updateVariable(_height);
    });
  }

  bool _configVariable(AnimatedValue variable, dynamic targetValue) {
    dynamic currentValue = variable.value;
    variable.end = targetValue;
    variable.begin = currentValue;
    return currentValue != targetValue;
  }

  bool _configAllVariables() {
    bool needsAnimation = false;
    if (config.constraints != null) {
      _constraints ??= new AnimatedBoxConstraintsValue(config.constraints);
      if (_configVariable(_constraints, config.constraints))
        needsAnimation = true;
    } else {
      _constraints = null;
    }

    if (config.decoration != null) {
      _decoration ??= new AnimatedBoxDecorationValue(config.decoration);
      if (_configVariable(_decoration, config.decoration))
        needsAnimation = true;
    } else {
      _decoration = null;
    }

    if (config.foregroundDecoration != null) {
      _foregroundDecoration ??= new AnimatedBoxDecorationValue(config.foregroundDecoration);
      if (_configVariable(_foregroundDecoration, config.foregroundDecoration))
        needsAnimation = true;
    } else {
      _foregroundDecoration = null;
    }

    if (config.margin != null) {
      _margin ??= new AnimatedEdgeDimsValue(config.margin);
      if (_configVariable(_margin, config.margin))
        needsAnimation = true;
    } else {
      _margin = null;
    }

    if (config.padding != null) {
      _padding ??= new AnimatedEdgeDimsValue(config.padding);
      if (_configVariable(_padding, config.padding))
        needsAnimation = true;
    } else {
      _padding = null;
    }

    if (config.transform != null) {
      _transform ??= new AnimatedMatrix4Value(config.transform);
      if (_configVariable(_transform, config.transform))
        needsAnimation = true;
    } else {
      _transform = null;
    }

    if (config.width != null) {
      _width ??= new AnimatedValue<double>(config.width);
      if (_configVariable(_width, config.width))
        needsAnimation = true;
    } else {
      _width = null;
    }

    if (config.height != null) {
      _height ??= new AnimatedValue<double>(config.height);
      if (_configVariable(_height, config.height))
        needsAnimation = true;
    } else {
      _height = null;
    }

    return needsAnimation;
  }

  Widget build(BuildContext context) {
    return new Container(
      child: config.child,
      constraints: _constraints?.value,
      decoration: _decoration?.value,
      foregroundDecoration: _foregroundDecoration?.value,
      margin: _margin?.value,
      padding: _padding?.value,
      transform: _transform?.value,
      width: _width?.value,
      height: _height?.value
    );
  }
}
