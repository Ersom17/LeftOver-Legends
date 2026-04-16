// lib/router.dart
// All app routes in one place.
//
// Flow: `/` (Hero) → `/login` → `/region` → `/fridge` ↔ `/recipes`
//                                                  ↑
//                                              `/add` (from FAB)

import 'package:go_router/go_router.dart';
import 'screens/hero_screen.dart';
import 'screens/login_screen.dart';
import 'screens/region_screen.dart';
import 'screens/fridge_screen.dart';
import 'screens/add_item_screen.dart';
import 'screens/recipe_screen.dart';
import 'screens/profile_screen.dart';

final appRouter = GoRouter(
  // TODO #4 – hero/marketing is now the entry point
  initialLocation: '/',
  routes: [
    // TODO #4 – marketing/hero landing
    GoRoute(
      path: '/',
      builder: (context, state) => const HeroScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // TODO #13 – region selection at sign-in
    GoRoute(
      path: '/region',
      builder: (context, state) => const RegionScreen(),
    ),
    GoRoute(
      path: '/fridge',
      builder: (context, state) => const FridgeScreen(),
    ),
    GoRoute(
      path: '/add',
      builder: (context, state) => const AddItemScreen(),
    ),
    // TODO #5 – recipe screen with color legend (#3) and prep/link (#7)
    GoRoute(
      path: '/recipes',
      builder: (context, state) => const RecipeScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    // Add these as you build them in week 2:
    // GoRoute(path: '/scan', builder: (_, __) => const ScanScreen()),
  ],
);
