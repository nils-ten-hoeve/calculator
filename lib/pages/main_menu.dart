import 'package:calculator/constants.dart';
import 'package:calculator/pages/vault_view_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_command/user_command.dart';

import '../app.dart';
import 'browser_page.dart';
import 'move_file_log_page.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: CommandListView([
        // Command(
        //   name: 'Vault',
        //   icon: media_file_icon,
        //   action: () {
        //     context.read<Navigation>().activePage =
        //         VaultFilterPage();
        //     Navigator.pop(context);
        //   },
        // ),
        Command(
          name: 'Viewer',
          icon: mediaFileIcon,
          action: () {
            context.read<Navigation>().activePage = const VaultViewerPage();
            Navigator.pop(context);
          },
        ),

        Command(
          name: 'Browse',
          icon: browserIcon,
          action: () {
            context.read<Navigation>().activePage = const BrowserPage();
            Navigator.pop(context);
          },
        ),

        Command(
          name: 'Move file log',
          icon: Icons.drive_file_move_outline,
          action: () {
            context.read<Navigation>().activePage = const MoveFileLogPage();
            Navigator.pop(context);
          },
        ),
      ]),
    ));
  }
}
