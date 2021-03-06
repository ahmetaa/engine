// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:sky' as sky;

import 'package:sky/gestures.dart';
import 'package:sky/material.dart';
import 'package:sky/painting.dart';
import 'package:sky/src/widgets/basic.dart';
import 'package:sky/src/widgets/button_state.dart';
import 'package:sky/src/widgets/framework.dart';
import 'package:sky/src/widgets/icon.dart';
import 'package:sky/src/widgets/ink_well.dart';
import 'package:sky/src/widgets/theme.dart';

class DrawerItem extends StatefulComponent {
  const DrawerItem({ Key key, this.icon, this.child, this.onPressed, this.selected: false })
    : super(key: key);

  final String icon;
  final Widget child;
  final GestureTapCallback onPressed;
  final bool selected;

  DrawerItemState createState() => new DrawerItemState();
}

class DrawerItemState extends ButtonState<DrawerItem> {
  TextStyle _getTextStyle(ThemeData themeData) {
    TextStyle result = themeData.text.body2;
    if (config.selected)
      result = result.copyWith(color: themeData.primaryColor);
    return result;
  }

  Color _getBackgroundColor(ThemeData themeData) {
    if (highlight)
      return themeData.highlightColor;
    if (config.selected)
      return themeData.selectedColor;
    return Colors.transparent;
  }

  sky.ColorFilter _getColorFilter(ThemeData themeData) {
    if (config.selected)
      return new sky.ColorFilter.mode(themeData.primaryColor, sky.TransferMode.srcATop);
    return new sky.ColorFilter.mode(const Color(0x73000000), sky.TransferMode.dstIn);
  }

  Widget buildContent(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    List<Widget> flexChildren = new List<Widget>();
    if (config.icon != null) {
      flexChildren.add(
        new Padding(
          padding: const EdgeDims.symmetric(horizontal: 16.0),
          child: new Icon(
            type: config.icon,
            size: 24,
            colorFilter: _getColorFilter(themeData))
        )
      );
    }
    flexChildren.add(
      new Flexible(
        child: new Padding(
          padding: const EdgeDims.symmetric(horizontal: 16.0),
          child: new DefaultTextStyle(
            style: _getTextStyle(themeData),
            child: config.child
          )
        )
      )
    );

    return new Container(
      height: 48.0,
      decoration: new BoxDecoration(backgroundColor: _getBackgroundColor(themeData)),
      child: new InkWell(
        onTap: config.onPressed,
        child: new Row(flexChildren)
      )
    );
  }
}
