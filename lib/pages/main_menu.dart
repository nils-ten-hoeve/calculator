import 'package:calculator/pages/settings_page.dart';
import 'package:calculator/pages/vault_filter_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculator/constants.dart';

import '../app.dart';
import 'browser_page.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Scaffold(
      appBar: AppBar(title: Text('Menu')),
      body: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              leading: media_file_icon,
              title: Text('Vault'),
              onTap: () {
                Provider.of<Navigation>(context, listen: false).activePage =
                    VaultFilterPage();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: browser_icon,
              title: Text('Browse'),
              onTap: () {
                Provider.of<Navigation>(context, listen: false).activePage =
                    BrowserPage();
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: settings_icon,
              title: Text('Settings'),
              onTap: () {
                Provider.of<Navigation>(context, listen: false).activePage =
                    SettingsPage();
                Navigator.pop(context);
              },
            ),

          ]),
    ));
  }
}
