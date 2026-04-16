// lib/utils/app_strings.dart
// Minimal manual localisation — English and Italian.
// Usage: AppStrings.of(context, 'myFridge')
// Responds automatically to the locale set on MaterialApp (languageProvider).
// TODO (FUTURE): replace with generated .arb / flutter_gen when the full
//   Italian string catalogue is finalised.

import 'package:flutter/widgets.dart';

class AppStrings {
  AppStrings._();

  /// Look up a localised string for the current MaterialApp locale.
  /// Falls back to English if the locale or key is not found.
  static String of(BuildContext context, String key) {
    final lang = Localizations.localeOf(context).languageCode;
    return (_table[lang] ?? _table['en']!)[key] ?? _table['en']![key] ?? key;
  }

  static const _table = <String, Map<String, String>>{
    'en': {
      // ── Navigation / titles ──────────────────────────────────────
      'myFridge'          : 'My Fridge',
      'recipes'           : 'Recipes',
      'settings'          : 'Settings',
      'profile'           : 'Profile',
      'addItem'           : 'Add item',
      // ── Hero ──────────────────────────────────────────────────────
      'heroKicker'        : 'LEFTOVER LEGENDS',
      'heroHeadline'      : 'Waste less.\nCook more.',
      'heroTagline'       : 'Track your fridge, get recipes, earn Seeds.',
      'heroStep1Title'    : 'Scan',
      'heroStep1Body'     : 'Scan your groceries or add them manually.',
      'heroStep2Title'    : 'Track',
      'heroStep2Body'     : 'We color-code items by how soon they expire.',
      'heroStep3Title'    : 'Cook',
      'heroStep3Body'     : 'Get recipes based on what you have.',
      'getStarted'        : 'Get started',
      // ── Login ─────────────────────────────────────────────────────
      'loginTagline'      : 'Your fridge, your legacy.',
      'signIn'            : 'Sign in',
      // ── Region ────────────────────────────────────────────────────
      'whereAreYouBased'  : 'Where are you based?',
      'regionSubtitle'    : 'We use this to show the right units and currency.',
      'continueCta'       : 'Continue',
      // ── Fridge ────────────────────────────────────────────────────
      'all'               : 'All',
      'fridgeLocation'    : 'Fridge',
      'pantry'            : 'Pantry',
      'expiring'          : 'Expiring',
      'fresh'             : 'Fresh',
      'noItems'           : 'No items here.',
      // ── Add item ──────────────────────────────────────────────────
      'itemName'          : 'Item name',
      'itemNameHint'      : 'e.g. Whole Milk',
      'pickEmoji'         : 'Pick an emoji',
      'category'          : 'Category',
      'storedIn'          : 'Stored in',
      'expiryDate'        : 'Expiry date',
      'addToFridge'       : 'Add to fridge',
      // ── Profile / settings ────────────────────────────────────────
      'appearance'        : 'Appearance',
      'light'             : 'Light',
      'system'            : 'System',
      'dark'              : 'Dark',
      'language'          : 'Language',
      // ── Recipe screen ─────────────────────────────────────────────
      'colorKey'          : 'Color key',
      'expiringSoon'      : 'Expiring soon — use it now',
      'useWithin5'        : 'Use within 5 days',
      'plentyOfTime'      : 'Fresh — plenty of time',
      'notInFridge'       : 'Missing — not in your fridge',
      'viewRecipe'        : 'View recipe',
    },
    'it': {
      // ── Navigation / titles ──────────────────────────────────────
      'myFridge'          : 'Il mio frigo',
      'recipes'           : 'Ricette',
      'settings'          : 'Impostazioni',
      'profile'           : 'Profilo',
      'addItem'           : 'Aggiungi articolo',
      // ── Hero ──────────────────────────────────────────────────────
      'heroKicker'        : 'LEFTOVER LEGENDS',
      'heroHeadline'      : 'Spreca meno.\nCuci di più.',
      'heroTagline'       : 'Tieni traccia del frigo, scopri ricette, guadagna Semi.',
      'heroStep1Title'    : 'Scansiona',
      'heroStep1Body'     : 'Scansiona la spesa o aggiungila manualmente.',
      'heroStep2Title'    : 'Monitora',
      'heroStep2Body'     : 'Coloriamo gli articoli in base alla scadenza.',
      'heroStep3Title'    : 'Cucina',
      'heroStep3Body'     : 'Ricevi ricette in base a ciò che hai.',
      'getStarted'        : 'Inizia',
      // ── Login ─────────────────────────────────────────────────────
      'loginTagline'      : 'Il tuo frigo, la tua leggenda.',
      'signIn'            : 'Accedi',
      // ── Region ────────────────────────────────────────────────────
      'whereAreYouBased'  : 'Da dove vieni?',
      'regionSubtitle'    : 'Usiamo questa info per mostrare le unità giuste.',
      'continueCta'       : 'Continua',
      // ── Fridge ────────────────────────────────────────────────────
      'all'               : 'Tutti',
      'fridgeLocation'    : 'Frigo',
      'pantry'            : 'Dispensa',
      'expiring'          : 'In scadenza',
      'fresh'             : 'Freschi',
      'noItems'           : 'Nessun articolo qui.',
      // ── Add item ──────────────────────────────────────────────────
      'itemName'          : 'Nome articolo',
      'itemNameHint'      : 'es. Latte intero',
      'pickEmoji'         : 'Scegli emoji',
      'category'          : 'Categoria',
      'storedIn'          : 'Conservato in',
      'expiryDate'        : 'Data di scadenza',
      'addToFridge'       : 'Aggiungi al frigo',
      // ── Profile / settings ────────────────────────────────────────
      'appearance'        : 'Aspetto',
      'light'             : 'Chiaro',
      'system'            : 'Sistema',
      'dark'              : 'Scuro',
      'language'          : 'Lingua',
      // ── Recipe screen ─────────────────────────────────────────────
      'colorKey'          : 'Legenda colori',
      'expiringSoon'      : 'In scadenza — usalo subito',
      'useWithin5'        : 'Usare entro 5 giorni',
      'plentyOfTime'      : 'Fresco — hai tempo',
      'notInFridge'       : 'Mancante — non nel frigo',
      'viewRecipe'        : 'Vedi ricetta',
    },
  };
}
