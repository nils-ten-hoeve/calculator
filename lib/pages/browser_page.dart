import 'package:calculator/constants.dart';
import 'package:calculator/domain/url.dart';
import 'package:calculator/pages/main_menu.dart';
import 'package:calculator/pages/vault_view_page.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:provider/provider.dart';
import 'package:user_command/user_command.dart';

import 'package:calculator/app.dart';

// ignore: must_be_immutable
class BrowserPage extends StatefulWidget {
  const BrowserPage({Key? key}) : super(key: key);

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  final NetworkInfo _networkInfo = NetworkInfo();
  Future<bool> _connectedToMeyn() async {
    String? wifiName = await _networkInfo.getWifiName();
    var connectedToMeyn =
        wifiName != null && wifiName.toLowerCase().contains('meyn');
    return Future.value(connectedToMeyn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse'),
      ),
      drawer: const MainMenu(),
      body: createListView(context),
      floatingActionButton: createFloatingActionButton(context),
    );
  }

  FloatingActionButton createFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () async {
        editUrl(context, 'Enter a new URL', 'Add', 'https://').then((newUrl) {
          if (newUrl != null) {
            try {
              context.read<UrlService>().add(newUrl);
              setState(() {});
            } on Exception catch (e) {
              showException(context, e);
            }
          }
        });
      },
    );
  }

  Future<String?> editUrl(BuildContext context, String title,
      String okButtonText, String value) async {
    return await prompt(
      context,
      title: Text(title),
      initialValue: value,
      textOK: Text(okButtonText),
      textCancel: const Text('Cancel'),
      autoFocus: true,
    );
  }

  void showException(BuildContext context, Exception e) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Error adding a new url'),
              content: Text(e.toString()),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  FutureBuilder<bool> createListView(BuildContext context) {
    UrlService urlService = context.read<UrlService>();
    var urls = urlService.all;
    return FutureBuilder<bool>(
        future: _connectedToMeyn(),
        builder: (BuildContext context, AsyncSnapshot<bool> connectedToMeyn) =>
            ListView(
              children: <Widget>[
                CommandTile(Command(
                  name: 'Viewer',
                  icon: mediaFileIcon,
                  action: () {
                    context.read<Navigation>().activePage =
                        const VaultViewerPage();
                  },
                )),
                // CommandTile(Command(
                //   name: 'Vault',
                //   icon: media_file_icon,
                //   action: () {
                //     context.read<Navigation>().activePage = VaultFilterPage();
                //   },
                // )),
                for (int i = 0; i < urls.length; i++)
                  // using index otherwise the order is wrong.
                  CommandPopupMenuWrapper(
                    popupMenuTitle: urls[i],
                    event: PopupMenuEvent.onLongPress,
                    commands: [
                      Command(
                        name: 'Edit',
                        icon: Icons.edit,
                        action: () {
                          editUrl(context, 'Edit URL', 'Update', urls[i])
                              .then((newUrl) {
                            if (newUrl != null) {
                              urlService.update(urls[i], newUrl);
                              setState(() {});
                            }
                          });
                        },
                      ),
                      Command.dynamic(
                        name: () => 'Move up',
                        icon: () => Icons.arrow_upward,
                        visible: () => urls[i] != urls.first,
                        action: () {
                          urlService.moveUp(urls[i]);
                          setState(() {});
                        },
                      ),
                      Command.dynamic(
                          name: () => 'Move down',
                          icon: () => Icons.arrow_downward,
                          visible: () => urls[i] != urls.last,
                          action: () {
                            urlService.moveDown(urls[i]);
                            setState(() {});
                          }),
                      Command(
                          name: 'Delete',
                          icon: Icons.delete,
                          action: () {
                            urlService.delete(urls[i]);
                            setState(() {});
                          }),
                    ],
                    child: ListTile(
                      leading: const Icon(browserIcon),
                      title: Text(urls[i]),
                      onTap: () => {urlService.openInIncognitoBrowser(urls[i])},
                    ),
                  ),
              ],
            ));
  }
}
