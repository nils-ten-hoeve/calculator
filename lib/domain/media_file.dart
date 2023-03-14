import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart';

class MediaFileService {
  Directory? _appDirectory;
  Directory? _vaultDirectory;
  Directory? _microSdDirectory;

  Future<Directory> get vaultDirectory async {
    if (_vaultDirectory == null) {
      Directory? microSdAppDir = await microSdAppDirectory;
      _vaultDirectory = Directory('${microSdAppDir.path}/vault');

      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        await Permission.manageExternalStorage.request();
      }
      status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      _vaultDirectory!.createSync(recursive: true);
      if (!_vaultDirectory!.existsSync()) {
        throw Exception('Could not create the vault directory');
      }
    }
    return _vaultDirectory!;
  }

  Future<Directory> get inBrowserDirectory async {
    return Directory('/storage/emulated/0/InBrowser');
  }

  Future<Directory> get microSdAppDirectory async {
    if (_appDirectory == null) {
      List<Directory>? externalDirectories =
          await getExternalStorageDirectories();
      if (externalDirectories == null || externalDirectories.isEmpty) {
        throw Exception('Could not find the MicroSD application directory.');
      }
      _appDirectory = externalDirectories
          .firstWhere((dir) => !dir.path.startsWith('/storage/emulated/0'));
    }
    return _appDirectory!;
  }

  Future<Directory> get microSdDirectory async {
    if (_microSdDirectory == null) {
      Directory? microSdAppDir = await microSdAppDirectory;
      _microSdDirectory =
          Directory(microSdAppDir.path.replaceAll(RegExp(r'/Android.*'), ''));
    }
    return _microSdDirectory!;
  }

  /// shared directory on phone memory
  Directory get internalDirectory {
    return Directory('/storage/emulated/0');
  }

  Future<List<String>> findMediaFilesInVault() async {
    Directory vaultDirectory = await MediaFileService().vaultDirectory;
    Stream<FileSystemEntity> vaultFiles = vaultDirectory.list();
    return vaultFiles
        .where((FileSystemEntity e) => e.path.endsWith('.dat'))
        .map<String>((FileSystemEntity e) => e.path)
        .toList();
  }

  Future<List<String>> findMediaFilesInBrowserDirectory() async {
    Directory inBrowserDirectory = await MediaFileService().inBrowserDirectory;
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    Stream<FileSystemEntity> files = inBrowserDirectory.list();
    return files
        .where(
            (FileSystemEntity e) => MediaFileMappings().hasTypeSuffix(e.path))
        .map<String>((FileSystemEntity e) => e.path)
        .toList();
  }
}

class MediaFileMoveLogItem {
  final DateTime dateTime = DateTime.now();
  final String status;
  final String? sourcePath;
  final String? destinationPath;

  MediaFileMoveLogItem({
    required this.status,
    this.sourcePath,
    this.destinationPath,
  });

  String get title => '$dateTime $status';

  String? get subTitle {
    String subTitle = '';
    if (sourcePath != null) subTitle = 'from: $sourcePath';
    if (sourcePath != null && destinationPath != null) subTitle += '\n';
    if (destinationPath != null) subTitle += 'to: $destinationPath';
    return subTitle;
  }
}

class MediaFileMoveService with ChangeNotifier {
  /// starts moving files directly when [MediaFileMoveService] constructor is called
  /// (when [Provider] is initialized).
  /// Its progress can be viewed in [MoveFileLog]
  MediaFileMoveService() {
    moveMediaFilesFromInBrowserToVault();
  }

  List<MediaFileMoveLogItem> log = [];

  Future moveMediaFilesFromInBrowserToVault() async {
    log.clear();
    int filesMoved = 0;
    int filesFailedToMove = 0;
    List<String> paths =
        await MediaFileService().findMediaFilesInBrowserDirectory();
    for (String sourcePath in paths) {
      MediaFileMappings()
          .createVaultFilePath(sourcePath)
          .then((destinationPath) async {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }

        status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          await Permission.manageExternalStorage.request();
        }

        try {
          File(sourcePath).copy(destinationPath);
          File(sourcePath).delete();
          log.add(MediaFileMoveLogItem(
            status: 'OK',
            sourcePath: sourcePath,
            destinationPath: destinationPath,
          ));
          notifyListeners();
          filesMoved++;
        } on Exception catch (e) {
          log.add(MediaFileMoveLogItem(
            status: 'Failed: $e',
            sourcePath: sourcePath,
            destinationPath: destinationPath,
          ));
          notifyListeners();
          filesFailedToMove++;
        }
      });
    }
    log.add(MediaFileMoveLogItem(
      status: 'Completed: moved: $filesMoved, failed: $filesFailedToMove',
    ));
    notifyListeners();
  }
}

enum MediaFileType {
  image,
  animatedImage,
  movie,
}

class MediaFileMapping {
// TODO convert to enum;
// TODO combine with MediaFileMappings class

  final String vaultSuffix;
  final String typeSuffix;
  final RegExp vaultSuffixExp;
  final RegExp typeSuffixExp;
  final MediaFileType type;

  MediaFileMapping(this.vaultSuffix, this.typeSuffix, this.type)
      : vaultSuffixExp = RegExp('${vaultSuffix.replaceAll('.', '\\.')}\$',
            caseSensitive: false),
        typeSuffixExp = RegExp('${typeSuffix.replaceAll('.', '\\.')}\$',
            caseSensitive: false);

  bool matchesVaultSuffix(String vaultPath) =>
      vaultPath.contains(vaultSuffixExp);

  bool matchesTypeSuffix(String sourcePath) =>
      sourcePath.contains(typeSuffixExp);
}

class MediaFileMappings extends DelegatingList<MediaFileMapping> {
  final uuid = const Uuid();
  static final MediaFileMappings _singleton = MediaFileMappings._();

  factory MediaFileMappings() {
    return _singleton;
  }

  MediaFileMappings._()
      : super([
          MediaFileMapping('1.dat', '.png', MediaFileType.image),
          MediaFileMapping('2.dat', '.jpg', MediaFileType.image),
          MediaFileMapping('2.dat', '.jpeg', MediaFileType.image),
          MediaFileMapping('3.dat', '.wepb', MediaFileType.image),
          MediaFileMapping('4.dat', '.bmp', MediaFileType.image),
          MediaFileMapping('5.dat', '.wbmp', MediaFileType.image),
          MediaFileMapping('8.dat', '.gif', MediaFileType.animatedImage),
          MediaFileMapping('a.dat', '.mp4', MediaFileType.movie),
          MediaFileMapping('b.dat', '.3gp', MediaFileType.movie),
        ]);

  Future<String> createVaultFilePath(String sourceFilePath) async {
    var mapping =
        firstWhere((m) => m.matchesTypeSuffix(sourceFilePath), orElse: () {
      throw Exception(
          'Invalid or unknown sourceFilePath file name suffix: $sourceFilePath');
    });
    var vaultDirectory = await MediaFileService().vaultDirectory;
    var fileName = createVaultFileName(sourceFilePath);
    var path = '${vaultDirectory.path}/$fileName${mapping.vaultSuffix}';
    return path;
  }

  /// Converts a file name to a consistent number
  /// * To obscure some file names
  /// * But still be sortable
  /// * And for fast lookup metadata
  ///   (link file names with meta object containing tags, rating, etc)
  String createVaultFileName(String sourceFilePath) =>
      convertToNumber(fileNameWithoutExtension(sourceFilePath));

  String fileExtension(sourceFileName) => extension(sourceFileName);

  // converts a string with characters to a number. These numbers should
  // roughly order the same as their source strings when sorted.
  // (so that file stay together)
  String convertToNumber(String string) {
    String letters = '';
    String number = '';
    for (var char in string.split('')) {
      var codeUnit = char.toLowerCase().codeUnitAt(0);
      if (isLetter(codeUnit)) {
        letters += char;
      } else {
        if (letters.isNotEmpty) {
          number += lettersToNumber(letters).toString();
          letters = '';
        }
        if (isNumber(codeUnit)) {
          number += char;
        } else {
          number += '0';
        }
      }
    }
    if (letters.isNotEmpty) {
      number += lettersToNumber(letters).toString();
    }
    return number;
  }

  bool isNumber(int codeUnit) =>
      codeUnit >= '0'.codeUnitAt(0) && codeUnit <= '9'.codeUnitAt(0);

  bool isLetter(int codeUnit) =>
      codeUnit >= 'a'.codeUnitAt(0) && codeUnit <= 'z'.codeUnitAt(0);

// "a" is 1, "z" is 26, "aa" is 27, "az" is 52, "ba" is 53, etc.
  int lettersToNumber(String letters) {
    var result = 0;
    for (var i = 0; i < letters.length; i++) {
      result = result * 26 + (letters.codeUnitAt(i) & 0x1f);
    }
    return result;
  }

  String fileNameWithoutExtension(String sourceFilePath) =>
      basenameWithoutExtension(sourceFilePath);

  bool hasTypeSuffix(String sourceFilePath) {
    return where((m) => m.matchesTypeSuffix(sourceFilePath)).isNotEmpty;
  }

  String createEmulatedVaultFilePath(String vaultFilePath) {
    var mapping =
        firstWhere((m) => m.matchesVaultSuffix(vaultFilePath), orElse: () {
      throw Exception(
          'Invalid or unknown vaultFilePath file name suffix: $vaultFilePath');
    });
    var datExtExp = RegExp(r'\.dat$');
    var path = vaultFilePath.replaceFirst(datExtExp, mapping.typeSuffix);
    return path;
  }

  MediaFileType vaultFileType(String vaultFilePath) {
    var mapping =
        firstWhere((m) => m.matchesVaultSuffix(vaultFilePath), orElse: () {
      throw Exception(
          'Invalid or unknown vaultFilePath file name suffix: $vaultFilePath');
    });
    return mapping.type;
  }
}

/// Wraps 2 files.
/// It links to a vault file
/// But the [emulatedVaultFile] has the correct media file extension.
class MediaFile implements File {
  final File vaultFile;
  final File emulatedVaultFile;
  final MediaFileType type;

  MediaFile(String vaultFilePath)
      : vaultFile = File(vaultFilePath),
        emulatedVaultFile = File(
            MediaFileMappings().createEmulatedVaultFilePath(vaultFilePath)),
        type = MediaFileMappings().vaultFileType(vaultFilePath);

  @override
  File get absolute => emulatedVaultFile.absolute;

  @override
  Future<File> copy(String newPath) {
    throw UnimplementedError();
  }

  @override
  File copySync(String newPath) {
    throw UnimplementedError();
  }

  // @override
  // Future<File> create({bool recursive = false}) {
  //   throw UnimplementedError();
  // }

  // @override
  // void createSync({bool recursive = false}) {}

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) {
    return vaultFile.delete(recursive: recursive);
  }

  @override
  void deleteSync({bool recursive = false}) {}

  @override
  Future<bool> exists() => vaultFile.exists();

  @override
  bool existsSync() => vaultFile.existsSync();

  @override
  bool get isAbsolute => emulatedVaultFile.isAbsolute;

  @override
  Future<DateTime> lastAccessed() {
    throw UnimplementedError();
  }

  @override
  DateTime lastAccessedSync() {
    throw UnimplementedError();
  }

  @override
  Future<DateTime> lastModified() {
    throw UnimplementedError();
  }

  @override
  DateTime lastModifiedSync() {
    throw UnimplementedError();
  }

  @override
  Future<int> length() => vaultFile.length();

  @override
  int lengthSync() => vaultFile.lengthSync();

  @override
  Future<RandomAccessFile> open({FileMode mode = FileMode.read}) =>
      vaultFile.open(mode: mode);

  @override
  Stream<List<int>> openRead([int? start, int? end]) =>
      vaultFile.openRead(start, end);

  @override
  RandomAccessFile openSync({FileMode mode = FileMode.read}) =>
      vaultFile.openSync(mode: mode);

  @override
  IOSink openWrite({FileMode mode = FileMode.write, Encoding encoding = utf8}) {
    throw UnimplementedError();
  }

  @override
  Directory get parent => vaultFile.parent;

  @override
  String get path => emulatedVaultFile.path;

  @override
  Future<Uint8List> readAsBytes() => vaultFile.readAsBytes();

  @override
  Uint8List readAsBytesSync() => vaultFile.readAsBytesSync();

  @override
  Future<List<String>> readAsLines({Encoding encoding = utf8}) {
    throw UnimplementedError();
  }

  @override
  List<String> readAsLinesSync({Encoding encoding = utf8}) {
    throw UnimplementedError();
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) {
    throw UnimplementedError();
  }

  @override
  String readAsStringSync({Encoding encoding = utf8}) {
    throw UnimplementedError();
  }

  @override
  Future<File> rename(String newPath) {
    throw UnimplementedError();
  }

  @override
  File renameSync(String newPath) {
    throw UnimplementedError();
  }

  @override
  Future<String> resolveSymbolicLinks() {
    throw UnimplementedError();
  }

  @override
  String resolveSymbolicLinksSync() {
    throw UnimplementedError();
  }

  @override
  Future setLastAccessed(DateTime time) {
    throw UnimplementedError();
  }

  @override
  void setLastAccessedSync(DateTime time) {}

  @override
  Future setLastModified(DateTime time) {
    throw UnimplementedError();
  }

  @override
  void setLastModifiedSync(DateTime time) {}

  @override
  Future<FileStat> stat() {
    throw UnimplementedError();
  }

  @override
  FileStat statSync() {
    throw UnimplementedError();
  }

  @override
  Uri get uri => emulatedVaultFile.uri;

  @override
  Stream<FileSystemEvent> watch(
      {int events = FileSystemEvent.all, bool recursive = false}) {
    throw UnimplementedError();
  }

  @override
  Future<File> writeAsBytes(List<int> bytes,
      {FileMode mode = FileMode.write, bool flush = false}) {
    throw UnimplementedError();
  }

  @override
  void writeAsBytesSync(List<int> bytes,
      {FileMode mode = FileMode.write, bool flush = false}) {}

  @override
  Future<File> writeAsString(String contents,
      {FileMode mode = FileMode.write,
      Encoding encoding = utf8,
      bool flush = false}) {
    throw UnimplementedError();
  }

  @override
  void writeAsStringSync(String contents,
      {FileMode mode = FileMode.write,
      Encoding encoding = utf8,
      bool flush = false}) {}

  @override
  Future<File> create({bool recursive = false, bool exclusive = false}) {
    throw UnimplementedError();
  }

  @override
  void createSync({bool recursive = false, bool exclusive = false}) {}
}

class LastSeenFilePathRepository {
  static final LastSeenFilePathRepository _repository =
      LastSeenFilePathRepository._();

  factory LastSeenFilePathRepository() => _repository;

  LastSeenFilePathRepository._();

  static const hiveBoxName = 'last_seen';

  Box get box => Hive.box(hiveBoxName);

  static init() async {
    await Hive.openBox(
      hiveBoxName,
    );
  }

  String read() {
    List<String>? lastSeenFilePaths =
        box.values.cast<String>().toList(growable: true);
    return (lastSeenFilePaths.isEmpty) ? 'noneFound' : lastSeenFilePaths.first;
  }

  void write(String lastSeenFilePath) async {
    box.put(0, lastSeenFilePath);
  }
}