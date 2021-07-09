import 'package:calculator/domain/settings.dart';
import 'package:calculator/domain/vault_filter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';

/// This is a reimplementation of the default Flutter application using provider + [ChangeNotifier].

main() async {

  runApp(
    /// Providers are above [MyApp] instead of inside it, so that tests
    /// can use [MyApp] while mocking the providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Navigation()),
        Provider(create: (_) => FormVaultFilter()),
        Provider(create: (_) => SettingsService()),
      ],
      child: App(),
    ),
  );
}
