import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';

void main() {
  runApp(
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
          seedColor: const Color(0xFF5C9E6E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Nunito',
      ),
    );
  }
}