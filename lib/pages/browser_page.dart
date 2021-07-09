import 'package:calculator/constants.dart';
import 'package:calculator/domain/url.dart';
import 'package:calculator/pages/main_menu.dart';
import 'package:calculator/pages/vault_filter_page.dart';
import 'package:flutter/material.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:provider/provider.dart';
import 'package:user_command/user_command.dart';

import '../app.dart';

/// TODO Add with floating plus button
/// TODO Move up with context menu
/// TODO Move down with contect menu
/// TODO Delete with contect menu

// ignore: must_be_immutable
class BrowserPage extends StatefulWidget {
  @override
  _BrowserPageState createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  UrlService urlService(BuildContext context) =>
      Provider.of<UrlService>(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Browse'),
      ),
      drawer: MainMenu(),
      body: createListView(context),
      floatingActionButton: createFloatingActionButton(context),
    );
  }

  FloatingActionButton createFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () async {
        editUrl(context, 'Enter a new URL', 'Add', 'https://').then((newUrl) {
          if (newUrl != null) {
            try {
              UrlService().add(newUrl);
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
      textCancel: Text('Cancel'),
      autoFocus: true,
    );
  }

  void showException(BuildContext context, Exception e) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Error adding a new url'),
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

  ListView createListView(BuildContext context) {
    var urls = UrlService().all;
    return ListView(
      children: <Widget>[
        ListTile(
          leading: media_file_icon,
          title: Text('Vault'),
          onTap: () => {
             context.read<Navigation>().activePage =
                VaultFilterPage()
          },
        ),
        for (String url in urls)
          CommandPopupMenuWrapper(
            child: ListTile(
              leading: browser_icon,
              title: Text(url),
              onTap: () => {UrlService().openInIncognitoBrowser(url)},
            ),
            popupMenuTitle: url,
            event: PopupMenuEvent.onLongPress,
            commands: [
              Command(
                name: 'Edit',
                icon: Icons.edit,
                action: () {
                  editUrl(context, 'Edit URL', 'Update', url).then((newUrl) {
                    if (newUrl != null) {
                      UrlService().update(url, newUrl);
                      setState(() {});
                    }
                  });
                },
              ),
              Command.dynamic(
                name: () =>'Move up',
                icon: () =>Icons.arrow_upward,
                visible: () => url!=urls.first!,
                action: () {
                  UrlService().moveUp(url);
                  setState(() {});
                },
              ),
              Command.dynamic(
                  name: () => 'Move down',
                  icon: () => Icons.arrow_downward,
                  visible: () => url!=urls.last,
                  action: () {
                    UrlService().moveDown(url);
                    setState(() {});
                  }),
              Command(
                  name: 'Delete',
                  icon: Icons.delete,
                  action: () {
                    UrlService().delete(url);
                    setState(() {});
                  }),
            ],
          ),
      ],
    );
  }
}
