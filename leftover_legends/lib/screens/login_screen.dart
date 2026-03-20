// lib/screens/login_screen.dart
// R1 — Login screen. Engineer 1 owns this file.
// For the skeleton, just a button that navigates to /fridge.
// Real auth (Firebase / mock) can be wired in later.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F1C),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / branding
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3D7A56), Color(0xFF5C9E6E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text('🌱', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: 24),

              // App name
              const Text(
                'Leftover Legends',
                style: TextStyle(
                  color: Color(0xFF7FAF8A),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your fridge, your legacy.',
                style: TextStyle(
                  color: Color(0xFFF5EFE0),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Sign in button (skeleton — no real auth yet)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go('/fridge'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5C9E6E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Get started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Secondary button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/fridge'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7FAF8A),
                    side: const BorderSide(color: Color(0xFF7FAF8A)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Sign in',
                    style: TextStyle(
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
