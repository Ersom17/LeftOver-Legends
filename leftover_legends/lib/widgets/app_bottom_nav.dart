// lib/widgets/app_bottom_nav.dart
// Todo #6 — readable, branded bottom nav.
// Active tab: navy icon + label + 6px orange dot indicator below.
// Inactive tab: slate icon + label.
// Labels use fontSize 13 (material default is 12) and fontWeight w700.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/item_provider.dart';
import '../theme/app_theme.dart';

class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = ref.watch(bottomNavIndexProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        border: Border(top: BorderSide(color: AppTheme.borderOf(context))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.kitchen,
                label: 'Fridge',
                index: 0,
                currentIndex: idx,
                onTap: () {
                  ref.read(bottomNavIndexProvider.notifier).state = 0;
                  context.go('/fridge');
                },
              ),
              _NavItem(
                icon: Icons.restaurant_menu,
                label: 'Recipes',
                index: 1,
                currentIndex: idx,
                onTap: () {
                  ref.read(bottomNavIndexProvider.notifier).state = 1;
                  context.go('/recipes');
                },
              ),
              _NavItem(
                icon: Icons.person,
                label: 'Profile',
                index: 2,
                currentIndex: idx,
                onTap: () {
                  ref.read(bottomNavIndexProvider.notifier).state = 2;
                  context.go('/profile');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == currentIndex;
    final color = active ? AppTheme.navy : AppTheme.slate;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            // TODO #6 – orange dot indicator for the active tab
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? AppTheme.orange : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
