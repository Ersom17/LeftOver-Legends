// lib/main.dart
// App entry point. Do not put business logic here.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';

void main() {
  runApp(
    // ProviderScope enables Riverpod throughout the entire app
    const ProviderScope(
      child: LeftoverLegendsApp(),
    ),
  );
}

class LeftoverLegendsApp extends StatelessWidget {
  const LeftoverLegendsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Leftover Legends',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C9E6E), // green from the mockup
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Nunito',
      ),
    );
  }
}
