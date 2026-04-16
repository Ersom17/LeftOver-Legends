// lib/theme/app_theme.dart
// Single source of truth for palette tokens.
// Only this file should contain raw hex colors — every other file should
// reference AppTheme.* constants.
//
// Penn State-inspired light-mode palette:
//   bg      Tradition Tan   — page background
//   navy    Nittany Navy    — headings, nav active, primary text
//   orange  Action Orange   — CTA, FAB, active indicator
//   slate   Victory Slate   — secondary text, inactive nav
//   surface                 — cards/sheets (white)
//   border                  — subtle light-mode borders
//
// Dark-mode counterparts (bgDark, surfaceDark, borderDark, textOnDark, slateOnDark).
// Use the context-aware helpers (bgOf, surfaceOf, …) in widgets so they
// automatically switch between light and dark values.
//
// Status colors (danger/warn/good) are FROZEN — do not change. They drive
// the traffic-light expiry system across item cards and recipe chips.

import 'package:flutter/material.dart';

class AppTheme {
  // ── Light palette ──────────────────────────────────────────────
  static const bg      = Color(0xFFE3D7C1); // Tradition Tan
  static const navy    = Color(0xFF001E44); // Nittany Navy
  static const orange  = Color(0xFFFF7A00); // Action Orange
  static const slate   = Color(0xFF75787B); // Victory Slate
  static const surface = Color(0xFFFFFFFF);
  static const border  = Color(0xFFE0D8C8);
  static const white   = Color(0xFFFFFFFF);

  // ── Dark palette ───────────────────────────────────────────────
  static const bgDark      = Color(0xFF0D1A2E); // deep navy background
  static const surfaceDark = Color(0xFF162240); // raised card surface
  static const borderDark  = Color(0xFF243758); // subtle border on dark
  static const textOnDark  = Color(0xFFF0EAD6); // warm cream — readable on dark bg
  static const slateOnDark = Color(0xFF9BA1A6); // muted slate for secondary text

  // ── Status — FROZEN ─────────────────────────────────────────────
  static const danger  = Color(0xFFC05050);
  static const warn    = Color(0xFFE8A838);
  static const good    = Color(0xFF6BAF7A);

  // ── Semantic ─────────────────────────────────────────────────────
  static const missing    = Color(0xFFB0B0B0); // grey for missing recipe ingredient
  static const cardShadow = Color(0x14000000); // rgba(0,0,0,0.08)

  // ── Context-aware helpers ────────────────────────────────────────
  // Use these in widgets instead of the bare constants so dark mode works.

  /// Page / scaffold background.
  static Color bgOf(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? bgDark : bg;

  /// Card, sheet, and input-fill background.
  static Color surfaceOf(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? surfaceDark : surface;

  /// Hairline border colour.
  static Color borderOf(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? borderDark : border;

  /// Primary text (headings, active labels).
  static Color primaryOf(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? textOnDark : navy;

  /// Secondary / muted text.
  static Color secondaryOf(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? slateOnDark : slate;
}
