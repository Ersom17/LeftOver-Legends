// lib/providers/recipe_favorites_provider.dart
//
// Local (shared_preferences-backed) store for saved favorite recipes and a
// rolling history of recently generated recipes. Kept local so the feature
// works even before a server-side "favorites" collection exists.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

Map<String, dynamic> _recipeToJson(Recipe r) => {
      'title': r.title,
      'description': r.description,
      'culture': r.culture,
      'ingredients_used': r.ingredientsUsed,
      'priority_ingredients_used': r.priorityIngredientsUsed,
      'missing_ingredients': r.missingIngredients,
      'steps': r.steps,
    };

class RecipeFavoritesNotifier extends Notifier<List<Recipe>> {
  static const _prefKey = 'recipe_favorites';

  @override
  List<Recipe> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefKey) ?? const [];
      state = raw
          .map((s) => Recipe.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to load recipe favorites: $e');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _prefKey,
        state.map((r) => jsonEncode(_recipeToJson(r))).toList(),
      );
    } catch (e) {
      debugPrint('Failed to persist recipe favorites: $e');
    }
  }

  bool isFavorite(Recipe recipe) =>
      state.any((r) => r.title == recipe.title && r.culture == recipe.culture);

  Future<void> toggle(Recipe recipe) async {
    if (isFavorite(recipe)) {
      state = state
          .where((r) =>
              !(r.title == recipe.title && r.culture == recipe.culture))
          .toList();
    } else {
      state = [recipe, ...state];
    }
    await _persist();
  }
}

final recipeFavoritesProvider =
    NotifierProvider<RecipeFavoritesNotifier, List<Recipe>>(
        RecipeFavoritesNotifier.new);

class RecipeHistoryNotifier extends Notifier<List<Recipe>> {
  static const _prefKey = 'recipe_history';
  static const _maxEntries = 20;

  @override
  List<Recipe> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefKey) ?? const [];
      state = raw
          .map((s) => Recipe.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to load recipe history: $e');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _prefKey,
        state.map((r) => jsonEncode(_recipeToJson(r))).toList(),
      );
    } catch (e) {
      debugPrint('Failed to persist recipe history: $e');
    }
  }

  Future<void> addMany(List<Recipe> recipes) async {
    if (recipes.isEmpty) return;
    final merged = <Recipe>[...recipes, ...state];
    // Deduplicate by (title + culture) keeping first (most recent) occurrence.
    final seen = <String>{};
    final deduped = <Recipe>[];
    for (final r in merged) {
      final key = '${r.title}|${r.culture}';
      if (seen.add(key)) deduped.add(r);
    }
    state = deduped.take(_maxEntries).toList();
    await _persist();
  }
}

final recipeHistoryProvider =
    NotifierProvider<RecipeHistoryNotifier, List<Recipe>>(
        RecipeHistoryNotifier.new);
