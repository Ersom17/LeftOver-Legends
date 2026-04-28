import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'widgets/mascot_tour/mascot_tour_overlay.dart';

void main() {
  runApp(
    const ProviderScope(
      child: IngredientConservoApp(),
    ),
  );
}

class IngredientConservoApp extends StatelessWidget {
  const IngredientConservoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'IngredientConservo',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.light(),
      // Mascot tour overlay lives above every route so the walkthrough
      // can follow the user across /fridge, /add, recipe sheets, etc.
      builder: (context, child) => Stack(
        children: [
          child ?? const SizedBox.shrink(),
          const MascotTourOverlay(),
        ],
      ),
    );
  }
}
