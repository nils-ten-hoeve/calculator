import 'dart:io';

import 'package:calculator/domain/directory.dart';
import 'package:calculator/domain/url.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'pages/calculator_page.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // askPermissions(context);
    initHives(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData.dark().copyWith(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          floatingActionButtonTheme:
              FloatingActionButtonThemeData(backgroundColor: Colors.orange)),
      home: MainPage(),
    );
  }

  // Future<void> askPermissions(BuildContext context) async {
  //   askStoragePermissionIfNeeded();
  //   await askManageExternalStoragePermissionIdNeeded(context);
  // }

  Future<void> askManageExternalStoragePermissionIdNeeded(
      BuildContext context) async {
    // if (await Permission.manageExternalStorage.isRestricted) {
    // showDialog(
    //     context: context,
    //     builder: (BuildContext context) => AlertDialog(
    //           title: Text('Calculator needs permissions'),
    //           content: Text(
    //               'Select permissions'+
    //           'Select all permissions from the menu'+
    //           'Click on modify or delete SD content'+
    //           '  and '),
    //           actions: [
    //             TextButton(
    //                 onPressed: () {
    //                   openAppSettings();
    //                 },
    //                 child: Text('Ok'))
    //           ],
    //         ));
//TODO does not work: Permission.manageExternalStorage.request().isRestricted;
    // TODO remove manageExternalStorage (restricted above Andoid 11?) do we need it?
    // TODO is the Permission.storage good enough?
    // TODO can we use the sd card/android/app folder?

    // print('>>> ${await Permission.storage.status}');
    // print('>>> ${await Permission.manageExternalStorage.status}');
  }

  // Future<PermissionStatus> askStoragePermissionIfNeeded() =>
  //     Permission.storage.request();

  Future<void> initHives(BuildContext context) async {
    Directory? vaultDirectory =
        await context.read<DirectoryService>().vaultDirectory;
    Hive.init(vaultDirectory!.path);
    UrlRepository.init();
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    /// register [didChangeAppLifecycleState] method as listener
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    /// unregister [didChangeAppLifecycleState] method
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //Navigate to calculator page when the application life cycle state changes
    context.read<Navigation>().activePage = CalculatorPage();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.of<Navigation>(context).activePage;
  }
}

class Navigation with ChangeNotifier {
  Widget _activePage = CalculatorPage();

  Widget get activePage => _activePage;

  set activePage(Widget newActivePage) {
    _activePage = newActivePage;
    notifyListeners();
  }
}
