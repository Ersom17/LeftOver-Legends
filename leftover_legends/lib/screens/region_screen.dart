// lib/screens/region_screen.dart
// Todo #13 — region picker shown between Login and Fridge.
// Sets regionProvider (#10) which drives unit formatting on recipe cards.
// TODO (BACKEND): persist the selection to SharedPreferences once settings land.
// TODO (BACKEND): currency formatting by region will also need backend support.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/item_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_strings.dart';

class RegionScreen extends ConsumerStatefulWidget {
  const RegionScreen({super.key});

  @override
  ConsumerState<RegionScreen> createState() => _RegionScreenState();
}

class _RegionScreenState extends ConsumerState<RegionScreen> {
  Region _selected = Region.us;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                AppStrings.of(context, 'whereAreYouBased'),
                style: TextStyle(
                  color: AppTheme.primaryOf(context),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.of(context, 'regionSubtitle'),
                style: TextStyle(
                  color: AppTheme.secondaryOf(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 36),

              _RegionTile(
                region: Region.us,
                selected: _selected == Region.us,
                flag: '🇺🇸',
                title: 'United States',
                subtitle: 'Imperial · kcal',
                onTap: () => setState(() => _selected = Region.us),
              ),
              const SizedBox(height: 12),
              _RegionTile(
                region: Region.ch,
                selected: _selected == Region.ch,
                flag: '🇨🇭',
                title: 'Switzerland',
                subtitle: 'Metric · kJ',
                onTap: () => setState(() => _selected = Region.ch),
              ),

              const Spacer(),
              FilledButton(
                onPressed: () {
                  ref.read(regionProvider.notifier).state = _selected;
                  context.go('/fridge');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.orange,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  AppStrings.of(context, 'continueCta'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegionTile extends StatelessWidget {
  final Region region;
  final bool selected;
  final String flag;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RegionTile({
    required this.region,
    required this.selected,
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.navy : AppTheme.borderOf(context),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: AppTheme.cardShadow,
                    blurRadius: 12,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.primaryOf(context),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.secondaryOf(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppTheme.orange : AppTheme.border,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
