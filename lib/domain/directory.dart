import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DirectoryService {


  Directory? _appDirectory;
  Directory? _vaultDirectory;

  // Future<Directory?> get rootDirectory async {
  //   if (_rootDirectory==null) {
  //     Directory? appDir = await appDirectory;
  //     if (appDir==null) {
  //       return null;
  //     }
  //     List<String> parts = appDir.path.split('/');
  //     if (parts.length < 1) {
  //       return null;
  //     }
  //     _rootDirectory = Directory('${parts[0]}/${parts[1]}/${parts[2]}');
  //   }
  //   return _rootDirectory;
  // }

  Future<Directory?> get vaultDirectory async {
    if (_vaultDirectory==null) {
      Directory? vaultDir = await appDirectory;
      if (vaultDir == null) {
        return null;
      }
      _vaultDirectory = Directory('${vaultDir.path}/vault');
      _vaultDirectory!.createSync(recursive: true);
      if (!_vaultDirectory!.existsSync()) {
        _vaultDirectory = null;
        print('Help!');
      }
    }
    return _vaultDirectory;
  }

  Future<Directory?> get appDirectory async {
    if (_appDirectory==null) {
      List<Directory>? externalDirectories = await getExternalStorageDirectories();
      if (externalDirectories==null || externalDirectories.length<1) {
        return null;
      }
     _appDirectory= externalDirectories.firstWhere((dir) => !dir.path.startsWith('/storage/emulated/0'));
    }
    return _appDirectory;
  }



  // Future<File?> get urlsHiveFile async {
  //   if (_urlsHiveFile==null) {
  //     Directory? vaultDir = await vaultDirectory;
  //     if (vaultDir == null) {
  //       return null;
  //     }
  //     _urlsHiveFile = File('${vaultDir.path}/urls.hive');
  //     _urlsHiveFile!.createSync(recursive: true);
  //     if (!_urlsHiveFile!.existsSync()) {
  //       _urlsHiveFile = null;
  //     }
  //   }
  //   return _urlsHiveFile;
  // }
}