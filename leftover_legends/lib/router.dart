// lib/router.dart
// All app routes in one place. Engineer 1 owns this file.
// Add new routes here as new screens are built.

import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/fridge_screen.dart';
import 'screens/add_item_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/fridge',
      builder: (context, state) => const FridgeScreen(),
    ),
    GoRoute(
      path: '/add',
      builder: (context, state) => const AddItemScreen(),
    ),
    // Add these as you build them in week 2:
    // GoRoute(path: '/scan',    builder: (_, __) => const ScanScreen()),
    // GoRoute(path: '/recipes', builder: (_, __) => const RecipesScreen()),
  ],
);
