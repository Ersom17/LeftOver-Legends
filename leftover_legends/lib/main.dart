// lib/main.dart
// App entry point. Do not put business logic here.
// Todo #11 — light-mode ColorScheme sourced from AppTheme tokens.
// Dark theme added: switches via themeModeProvider (light / system / dark).
// Locale switches via languageProvider (en / it).
// TODO (FUTURE): Italian localisation pending review; intl setup deferred.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'providers/item_provider.dart';

void main() {
  runApp(
    // ProviderScope enables Riverpod throughout the entire app
    const ProviderScope(
      child: LeftoverLegendsApp(),
    ),
  );
}

class LeftoverLegendsApp extends ConsumerWidget {
  const LeftoverLegendsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale    = ref.watch(languageProvider);

    return MaterialApp.router(
      title: 'Leftover Legends',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,

      // Locale
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('it')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Theme
      themeMode: themeMode,

      // TODO #11 – light-mode Penn State palette
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.navy,
          brightness: Brightness.light,
        ).copyWith(
          primary:    AppTheme.navy,
          secondary:  AppTheme.orange,
          surface:    AppTheme.surface,
          // ignore: deprecated_member_use
          background: AppTheme.bg,
        ),
        scaffoldBackgroundColor: AppTheme.bg,
        useMaterial3: true,
        fontFamily: 'Nunito',
      ),

      // Dark theme — deep navy background, warm cream text
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.navy,
          brightness: Brightness.dark,
        ).copyWith(
          primary:    AppTheme.orange,
          secondary:  AppTheme.orange,
          surface:    AppTheme.surfaceDark,
          // ignore: deprecated_member_use
          background: AppTheme.bgDark,
          onSurface:  AppTheme.textOnDark,
        ),
        scaffoldBackgroundColor: AppTheme.bgDark,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppTheme.bgDark,
          foregroundColor: AppTheme.textOnDark,
          elevation: 0,
        ),
        useMaterial3: true,
        fontFamily: 'Nunito',
      ),
    );
  }
}
