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
  ],
);