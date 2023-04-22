
import 'package:android_intent/android_intent.dart';
import 'package:android_intent/flag.dart';
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

  static final _urlRegEx = RegExp(
      r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?",
      caseSensitive: false);

  void validate(String url) {
    if (!_urlRegEx.hasMatch(url)) throw Exception('Invalid Url');
  }
}

class IncognitoBrowser {
  // Could also be: "nu.tommie.inbrowser"
  static String packageName = "com.lechneralexander.privatebrowser";

  Future<void> open(String url) async {
    AndroidIntent intent = AndroidIntent(
      // np longer needed: componentName: "nu.tommie.inbrowser.lib.Inbrowser",
      package: packageName,
      action: "android.intent.action.VIEW",
      data: url,
    );
    try {
      await intent.launch();
    } catch (e) {
      //failed
    }
  }

  void close() {
    AndroidIntent intent = AndroidIntent(
      action: 'android.intent.action.MAIN',
      category: 'android.intent.category.HOME',
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK], 
      package: packageName,
    );
    try {
      intent.launch();
    } catch (e) {
      // failed
    }
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
