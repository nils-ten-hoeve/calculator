import 'dart:io';

import 'package:hive/hive.dart';

const downloadFolderKey = 'downloadFolder';
const vaultFolderKey = 'vaultFolder';

const downloadDirectoryDefault = '/InBrowser';
const vaultDirectoryDefault = '/storage/emulated/0/.vault';

class Settings {
  Directory downloadDirectory = Directory(downloadDirectoryDefault);
  Directory vaultDirectory = Directory(vaultDirectoryDefault);
}

class SettingsService {
  final SettingsRepository repository = SettingsRepository();

  Settings read() {
    return repository.read();
  }

  void write(Settings settings) {
    repository.write(settings);
  }
}

class SettingsRepository {
  static const hiveBoxName = 'settings';

  Box get box => Hive.box(hiveBoxName);

  SettingsRepository();

  static init() async {
    await Hive.openBox(hiveBoxName);
  }

  Settings read() {
    Settings settings = Settings();
    String downloadPath = // box.get(downloadFolderKey) ??
        downloadDirectoryDefault;
    settings.downloadDirectory = Directory(downloadPath);
    String vaultPath = // box.get(downloadFolderKey) ??
        vaultDirectoryDefault;
    settings.vaultDirectory = Directory(vaultPath);
    return settings;
  }

  void write(Settings settings) async {
    box.put(downloadFolderKey, settings.downloadDirectory.path);
    box.put(vaultFolderKey, settings.vaultDirectory.path);
  }
}
