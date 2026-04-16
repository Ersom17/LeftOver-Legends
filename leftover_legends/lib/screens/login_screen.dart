// lib/screens/login_screen.dart
// Login screen.
// Todo #11 — palette swapped to AppTheme light-mode tokens.
// Todo #13 — both buttons now route to /region for unit selection before /fridge.
// Real auth (Firebase / mock) can be wired in later.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../utils/app_strings.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / branding — solid navy (replaces dark green gradient)
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.navy,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: AppTheme.cardShadow,
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🌱', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: 24),

              // App name
              Text(
                'LEFTOVER LEGENDS',
                style: TextStyle(
                  color: AppTheme.primaryOf(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.of(context, 'loginTagline'),
                style: TextStyle(
                  color: AppTheme.primaryOf(context),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Primary button — orange CTA
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  // TODO #13 – route through region selection
                  onPressed: () => context.go('/region'),
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
              ),
              const SizedBox(height: 12),

              // Secondary button — outlined navy
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  // TODO #13 – route through region selection
                  onPressed: () => context.go('/region'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.navy,
                    side: const BorderSide(color: AppTheme.navy, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    AppStrings.of(context, 'signIn'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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
