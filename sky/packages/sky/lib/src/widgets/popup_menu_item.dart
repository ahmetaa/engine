// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:sky/src/widgets/basic.dart';
import 'package:sky/src/widgets/framework.dart';
import 'package:sky/src/widgets/theme.dart';

const double _kMenuItemHeight = 48.0;
const double _kBaselineOffsetFromBottom = 20.0;

class PopupMenuItem extends StatelessComponent {
  PopupMenuItem({
    Key key,
    this.value,
    this.child
  }) : super(key: key);

  final Widget child;
  final dynamic value;

  Widget build(BuildContext context) {
    return new Container(
      height: _kMenuItemHeight,
      child: new DefaultTextStyle(
        style: Theme.of(context).text.subhead,
        child: new Baseline(
          baseline: _kMenuItemHeight - _kBaselineOffsetFromBottom,
          child: child
        )
      )
    );
  }
}
