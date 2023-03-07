import 'package:calculator/constants.dart';
import 'package:calculator/pages/vault_filter_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_command/user_command.dart';

import '../app.dart';
import 'browser_page.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Scaffold(
      appBar: AppBar(title: Text('Menu')),
      body: CommandListView([
        Command(
          name: 'Vault',
          icon: media_file_icon,
          action: () {
            context.read<Navigation>().activePage = VaultFilterPage();
            Navigator.pop(context);
          },
        ),
        Command(
          name: 'Browse',
          icon: browser_icon,
          action: () {
            context.read<Navigation>().activePage = BrowserPage();
            Navigator.pop(context);
          },
        ),
      ]),
    ));
  }
}
