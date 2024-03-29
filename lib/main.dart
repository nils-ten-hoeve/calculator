import 'package:calculator/domain/url.dart';
import 'package:calculator/domain/vault_filter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'domain/media_file.dart';

/// This is a re-implementation of the default Flutter application using provider + [ChangeNotifier].

main() async {
  runApp(
    /// Providers are above [MyApp] instead of inside it, so that tests
    /// can use [MyApp] while mocking the providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Navigation()),
        ChangeNotifierProvider(create: (_) => MediaFileMoveService()),
        Provider(create: (_) => FormVaultFilter()),
        Provider(create: (_) => MediaFileService()),
        Provider(create: (_) => UrlService()),
      ],
      child: const App(),
    ),
  );
}
