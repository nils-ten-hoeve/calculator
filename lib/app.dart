import 'dart:io';

import 'package:calculator/domain/media_file.dart';
import 'package:calculator/domain/url.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:volume_control/volume_control.dart';

import 'pages/calculator_page.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // askPermissions(context);
    initHives(context);
    VolumeControl.setVolume(0); //Just in case we forget :-(
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData.dark().copyWith(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.orange)),
      home: const MainPage(),
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
    // TODO can we use the sdcard/android/app folder?

    // print('>>> ${await Permission.storage.status}');
    // print('>>> ${await Permission.manageExternalStorage.status}');
  }

  // Future<PermissionStatus> askStoragePermissionIfNeeded() =>
  //     Permission.storage.request();

  Future<void> initHives(BuildContext context) async {
    Directory? vaultDirectory =
        await context.read<MediaFileService>().vaultDirectory;
    Hive.init(vaultDirectory.path);
    UrlRepository.init();
    LastSeenFilePathRepository.init();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
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
    context.read<Navigation>().activePage = const CalculatorPage();
    VolumeControl.setVolume(0); //Just in case we forget :-(
  }

  @override
  Widget build(BuildContext context) {
    return Provider.of<Navigation>(context).activePage;
  }
}

class Navigation with ChangeNotifier {
  Widget _activePage = const CalculatorPage();

  Widget get activePage => _activePage;

  set activePage(Widget newActivePage) {
    _activePage = newActivePage;
    notifyListeners();
  }
}
