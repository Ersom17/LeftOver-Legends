import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/fridge_screen.dart';
import 'screens/add_item_screen.dart';
import 'screens/edit_item_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/insights_screen.dart';
import 'models/item.dart';

/// Exposed so the mascot tour overlay (which sits above GoRouter's navigator
/// in the widget tree) can imperatively pop pushed routes like RecipesScreen
/// / RecipeDetailScreen when the walkthrough needs the user back on /fridge.
final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
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
      builder: (context, state) {
        final tourMode = state.uri.queryParameters['tour'] == '1';
        return AddItemScreen(tourMode: tourMode);
      },
    ),
    GoRoute(
      path: '/edit',
      builder: (context, state) {
        final item = state.extra as FridgeItem?;
        if (item == null) return const FridgeScreen();
        return EditItemScreen(item: item);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/learn',
      builder: (context, state) => const LearnScreen(),
    ),
    GoRoute(
      path: '/recipes/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/insights',
      builder: (context, state) => const InsightsScreen(),
    ),
  ],
);
