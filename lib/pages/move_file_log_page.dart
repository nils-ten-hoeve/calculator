import 'package:calculator/domain/media_file.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main_menu.dart';

class MoveFileLogPage extends StatelessWidget {
  const MoveFileLogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var log = Provider.of<MediaFileMoveService>(context).log;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Move file log'),
      ),
      drawer: const MainMenu(),
      body: ListView(children: [
        ...log
            .map((logItem) => ListTile(
                title: Text(logItem.title),
                subtitle:
                    logItem.subTitle == '' ? null : Text(logItem.subTitle!)))
            .toList()
      ]),
    );
  }
}
