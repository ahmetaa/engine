// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of stocks;

typedef void SettingsUpdater({
  StockMode optimism,
  BackupMode backup
});

class StockSettings extends StatefulComponent {
  const StockSettings(this.navigator, this.optimism, this.backup, this.updater);

  final NavigatorState navigator;
  final StockMode optimism;
  final BackupMode backup;
  final SettingsUpdater updater;

  StockSettingsState createState() => new StockSettingsState();
}

class StockSettingsState extends State<StockSettings> {
  void _handleOptimismChanged(bool value) {
    sendUpdates(value ? StockMode.optimistic : StockMode.pessimistic, config.backup);
  }

  void _handleBackupChanged(bool value) {
    sendUpdates(config.optimism, value ? BackupMode.enabled : BackupMode.disabled);
  }

  void _confirmOptimismChange() {
    switch (config.optimism) {
      case StockMode.optimistic:
        _handleOptimismChanged(false);
        break;
      case StockMode.pessimistic:
        showDialog(config.navigator, (NavigatorState navigator) {
          return new Dialog(
            title: new Text("Change mode?"),
            content: new Text("Optimistic mode means everything is awesome. Are you sure you can handle that?"),
            onDismiss: () {
              navigator.pop(false);
            },
            actions: [
              new FlatButton(
                child: new Text('NO THANKS'),
                onPressed: () {
                  navigator.pop(false);
                }
              ),
              new FlatButton(
                child: new Text('AGREE'),
                onPressed: () {
                  navigator.pop(true);
                }
              ),
            ]
          );
        }).then(_handleOptimismChanged);
        break;
    }
  }

  void sendUpdates(StockMode optimism, BackupMode backup) {
    if (config.updater != null)
      config.updater(
        optimism: optimism,
        backup: backup
      );
  }

  Widget buildToolBar(BuildContext context) {
    return new ToolBar(
      left: new IconButton(
        icon: 'navigation/arrow_back',
        onPressed: config.navigator.pop
      ),
      center: new Text('Settings')
    );
  }

  Widget buildSettingsPane(BuildContext context) {
    // TODO(ianh): Once we have the gesture API hooked up, fix https://github.com/domokit/mojo/issues/281
    // (whereby tapping the widgets below causes both the widget and the menu item to fire their callbacks)
    return new Material(
      type: MaterialType.canvas,
      child: new ScrollableViewport(
        child: new Container(
          padding: const EdgeDims.symmetric(vertical: 20.0),
          child: new BlockBody([
            new DrawerItem(
              icon: 'action/thumb_up',
              onPressed: () => _confirmOptimismChange(),
              child: new Row([
                new Flexible(child: new Text('Everything is awesome')),
                new Checkbox(
                  value: config.optimism == StockMode.optimistic,
                  onChanged: (_) => _confirmOptimismChange()
                ),
              ])
            ),
            new DrawerItem(
              icon: 'action/backup',
              onPressed: () { _handleBackupChanged(!(config.backup == BackupMode.enabled)); },
              child: new Row([
                new Flexible(child: new Text('Back up stock list to the cloud')),
                new Switch(
                  value: config.backup == BackupMode.enabled,
                  onChanged: _handleBackupChanged
                ),
              ])
            ),
          ])
        )
      )
    );
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      toolbar: buildToolBar(context),
      body: buildSettingsPane(context)
    );
  }
}
