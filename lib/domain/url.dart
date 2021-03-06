import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:calculator/constants.dart';
import 'package:hive/hive.dart';

/// Service class to manage Url's
class UrlService {

  final List<String> _urls = UrlRepository().read();

  List<String> get all => List.unmodifiable(_urls);

  void update(String oldUrl, String newUrl) {
    validate(newUrl);
    _urls.remove(oldUrl);
    _urls.add(newUrl);
    UrlRepository().write(_urls);
  }

  add(String urlToAdd) {
    validate(urlToAdd);
    _urls.add(urlToAdd);
    UrlRepository().write(_urls);
  }

  moveUp(String url) {
    int index = _urls.indexOf(url);
    if (index > 0) {
      _urls.remove(url);
      _urls.insert(index - 1, url);
      UrlRepository().write(_urls);
    }
  }

  moveDown(String url) {
    int index = _urls.indexOf(url);
    if (index < _urls.length - 1) {
      _urls.remove(url);
      _urls.insert(index + 1, url);
      UrlRepository().write(_urls);
    }
  }

  delete(String urlToRemove) {
    _urls.remove(urlToRemove);
    UrlRepository().write(_urls);
  }

  /// Opens a url (e.g.: 'https://duckduckgo.com/') in a incognito browser
  openInIncognitoBrowser(String url) async {
    if (Platform.isAndroid) {
      AndroidIntent intent = AndroidIntent(
        componentName: "nu.tommie.inbrowser.lib.Inbrowser",
        package: "nu.tommie.inbrowser",
        action: "android.intent.action.VIEW",
        category: "android.intent.category.BROWSABLE",
        data: url,
      );
      await intent.launch();
    }
  }

  static final _urlRegEx = RegExp(
      r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?",
      caseSensitive: false);

  void validate(String url) {
    if (!_urlRegEx.hasMatch(url)) throw new Exception('Invalid Url');
  }
}

class UrlRepository {
  static final UrlRepository _urlRepository = UrlRepository._();

  factory UrlRepository() => _urlRepository;

  UrlRepository._();

  static const hiveBoxName = 'urls';

  Box get box => Hive.box(hiveBoxName);


  static init() async {
    //TODO https://mukhtharcm.com/storage-permission-in-flutter
    //TODO https://pub.dev/packages/permission_handler

    await Hive.openBox(
      hiveBoxName,
      encryptionCipher: hiveCipher,
    );
  }

  List<String> read() {
    List<String>? urls = box.values.cast<String>().toList(growable: true);
    return urls;
  }

  void write(List<String> urls) async {
    for (int i = 0; i < urls.length; i++) {
      box.put(i, urls[i]);
    }
  }

}
