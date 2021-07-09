import 'package:calculator/constants.dart';
import 'package:calculator/domain/url.dart';
import 'package:calculator/pages/main_menu.dart';
import 'package:calculator/pages/vault_filter_page.dart';
import 'package:flutter/material.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:provider/provider.dart';

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

  final delete = "Delete";
  final moveDown = "Move down";
  final moveUp = "Move up";
  final edit = "Edit";

  Future<String?> _showPopupMenu(
      BuildContext context, Offset offset, String url) async {
    return await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, 100, 400),
      items: [
        PopupMenuItem(
          child: Text(edit),
          value: edit,
        ),
        PopupMenuItem(
          child: Text(moveUp),
          value: moveUp,
        ),
        PopupMenuItem(
          child: Text(moveDown),
          value: moveDown,
        ),
        PopupMenuItem(
          child: Text(delete),
          value: delete,
        ),
      ],
      elevation: 8.0,
    );
  }

  ListView createListView(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: media_file_icon,
          title: Text('Vault'),
          onTap: () => {
            Provider.of<Navigation>(context, listen: false).activePage =
                VaultFilterPage()
          },
        ),
        for (String url in UrlService().all)
          GestureDetector(
            onLongPressStart: (LongPressStartDetails details) => {
              _showPopupMenu(context, details.globalPosition, url)
                  .then((value) {
                if (value == edit) {
                  editUrl(context, 'Edit URL', 'Update', url)
                      .then((newUrl) {
                    if (newUrl != null) {
                      UrlService().update(url, newUrl);
                      setState(() {});
                    }
                  });
                } else if (value == moveUp) {
                  UrlService().moveUp(url);
                  setState(() {});
                } else if (value == moveDown) {
                  UrlService().moveDown(url);
                  setState(() {});
                } else if (value == delete) {
                  UrlService().delete(url);
                  setState(() {});
                }
              })
            },
            child: ListTile(
              leading: browser_icon,
              title: Text(url),
              onTap: () => {UrlService().openInIncognitoBrowser(url)},
            ),
          ),
      ],
    );
  }
}
