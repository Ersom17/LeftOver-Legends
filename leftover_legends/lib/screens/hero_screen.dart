// lib/screens/hero_screen.dart
// Todo #4 — Hero/marketing landing screen (new initial route).
// Todo #9 — 3-step tutorial embedded between screenshots and CTAs.
// Todo #2 — Website URL button replaces App Store / Play Store badges.
//
// Flow: `/` (Hero) → `/login` → `/region` → `/fridge`.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../utils/app_strings.dart';

class HeroScreen extends StatelessWidget {
  const HeroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Brand kicker
              Text(
                AppStrings.of(context, 'heroKicker'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.primaryOf(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 12),
              // Headline
              Text(
                AppStrings.of(context, 'heroHeadline'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.primaryOf(context),
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              // Tagline
              Text(
                AppStrings.of(context, 'heroTagline'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.secondaryOf(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),

              // TODO #4 – screenshot placeholders
              // Swap each _ScreenshotPlaceholder for an Image.asset('...') once
              // the real screenshots land under assets/screenshots/.
              SizedBox(
                height: 340,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _ScreenshotPlaceholder(label: 'Fridge'),
                    SizedBox(width: 16),
                    _ScreenshotPlaceholder(label: 'Recipes'),
                    SizedBox(width: 16),
                    _ScreenshotPlaceholder(label: 'Add item'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // TODO #9 – three-step tutorial
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceOf(context),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: AppTheme.cardShadow,
                      blurRadius: 12,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    _TutorialStep(
                      number: 1,
                      titleKey: 'heroStep1Title',
                      bodyKey:  'heroStep1Body',
                    ),
                    SizedBox(height: 14),
                    _TutorialStep(
                      number: 2,
                      titleKey: 'heroStep2Title',
                      bodyKey:  'heroStep2Body',
                    ),
                    SizedBox(height: 14),
                    _TutorialStep(
                      number: 3,
                      titleKey: 'heroStep3Title',
                      bodyKey:  'heroStep3Body',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Primary CTA → /login
              FilledButton(
                onPressed: () => context.go('/login'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.orange,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  AppStrings.of(context, 'getStarted'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // TODO #2 – single website CTA (replaces old App Store / Play Store badges)
              OutlinedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse('https://leftoverlegends.com'),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Visit leftoverlegends.com'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.navy,
                  side: const BorderSide(color: AppTheme.navy, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
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

class _ScreenshotPlaceholder extends StatelessWidget {
  final String label;
  const _ScreenshotPlaceholder({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        border: Border.all(color: AppTheme.borderOf(context), width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.phone_iphone, size: 48, color: AppTheme.secondaryOf(context)),
          const SizedBox(height: 12),
          Text(
            'App screenshot',
            style: TextStyle(
              color: AppTheme.secondaryOf(context),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.primaryOf(context),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialStep extends StatelessWidget {
  final int number;
  final String titleKey;
  final String bodyKey;
  const _TutorialStep({
    required this.number,
    required this.titleKey,
    required this.bodyKey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppTheme.navy,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.of(context, titleKey),
                style: TextStyle(
                  color: AppTheme.primaryOf(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppStrings.of(context, bodyKey),
                style: TextStyle(
                  color: AppTheme.secondaryOf(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
