// lib/screens/profile_screen.dart
// Settings / profile screen — accessible from the bottom nav Profile tab.
// Sections:
//   Appearance — light / system / dark theme toggle
//   Language   — English / Italian

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/item_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_strings.dart';
import '../widgets/app_bottom_nav.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale    = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bgOf(context),
        foregroundColor: AppTheme.primaryOf(context),
        elevation: 0,
        title: Text(
          AppStrings.of(context, 'settings'),
          style: TextStyle(
            color: AppTheme.primaryOf(context),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // ── Appearance ──────────────────────────────────────────
          _SectionLabel(AppStrings.of(context, 'appearance')),
          const SizedBox(height: 10),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.light,
                icon: const Icon(Icons.wb_sunny_outlined),
                label: Text(AppStrings.of(context, 'light')),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                icon: const Icon(Icons.brightness_auto),
                label: Text(AppStrings.of(context, 'system')),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: const Icon(Icons.nights_stay_outlined),
                label: Text(AppStrings.of(context, 'dark')),
              ),
            ],
            selected: {themeMode},
            onSelectionChanged: (s) =>
                ref.read(themeModeProvider.notifier).state = s.first,
          ),
          const SizedBox(height: 28),

          // ── Language ────────────────────────────────────────────
          _SectionLabel(AppStrings.of(context, 'language')),
          const SizedBox(height: 10),
          _LanguageTile(
            flag: '🇬🇧',
            name: 'English',
            locale: const Locale('en'),
            selected: locale.languageCode == 'en',
            onTap: () =>
                ref.read(languageProvider.notifier).state = const Locale('en'),
          ),
          const SizedBox(height: 8),
          _LanguageTile(
            flag: '🇮🇹',
            name: 'Italiano',
            locale: const Locale('it'),
            selected: locale.languageCode == 'it',
            onTap: () =>
                ref.read(languageProvider.notifier).state = const Locale('it'),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}

// ── Private helpers ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: AppTheme.secondaryOf(context),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String flag;
  final String name;
  final Locale locale;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.flag,
    required this.name,
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.orange : AppTheme.borderOf(context),
            width: selected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.cardShadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: AppTheme.primaryOf(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_off,
              color: selected ? AppTheme.orange : AppTheme.secondaryOf(context),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
