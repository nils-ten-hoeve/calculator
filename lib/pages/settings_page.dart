import 'dart:io';

import 'package:calculator/domain/settings.dart';
import 'package:calculator/pages/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController downloadFolderController =
      TextEditingController();
  final TextEditingController vaultFolderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initEditingControllers();
  }

  void initEditingControllers()  {
    SettingsService settingsService =
        Provider.of<SettingsService>(context, listen: false);
    Settings settings = settingsService.read();
    downloadFolderController.text = settings.downloadDirectory.path;
    downloadFolderController.addListener(() {
      settings.downloadDirectory = Directory(downloadFolderController.text);
      settingsService.write(settings);
    });
    vaultFolderController.text = settings.vaultDirectory.path;
    vaultFolderController.addListener(() {
      settings.vaultDirectory = Directory(vaultFolderController.text);
      settingsService.write(settings);
    });
  }

  @override
  void dispose() {
    downloadFolderController.dispose();
    vaultFolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        drawer: MainMenu(),
        body: ListView(children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
                labelText: 'Download folder',
                floatingLabelBehavior: FloatingLabelBehavior.always),
            controller: downloadFolderController,
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
                labelText: 'Vault folder',
                floatingLabelBehavior: FloatingLabelBehavior.always),
            controller: vaultFolderController,
          ),
        ]));
  }

  Directory getRootDirectory() => Directory('storage/emulated/0');
}
