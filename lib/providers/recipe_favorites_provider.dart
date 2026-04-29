// lib/providers/recipe_favorites_provider.dart
//
// Server-backed (Appwrite) saved favorites + rolling generation history.
// Uses SharedPreferences only as a fast-paint cache: build() returns the
// server snapshot on success, falls back to the prefs cache on failure
// or when the user is signed out.
//
// On first run after the migration, if the server has no docs but the
// prefs cache has rows, the cache is uploaded once so existing local-only
// users don't lose their data.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';
import '../repositories/appwrite_recipe_favorites_repository.dart';
import '../repositories/appwrite_recipe_history_repository.dart';
import 'auth_provider.dart';

Map<String, dynamic> _recipeToJson(Recipe r) => {
      'title': r.title,
      'description': r.description,
      'culture': r.culture,
      'ingredients_used': r.ingredientsUsed,
      'priority_ingredients_used': r.priorityIngredientsUsed,
      'missing_ingredients': r.missingIngredients,
      'steps': r.steps,
    };

// ─── Favorites ──────────────────────────────────────────────────────────────

class RecipeFavoritesNotifier extends AsyncNotifier<List<Recipe>> {
  static const _prefKey = 'recipe_favorites';
  static const _migrationFlag = 'recipe_favorites_migrated_v1';

  @override
  Future<List<Recipe>> build() async {
    // Re-run when auth changes so a fresh login pulls the right user's
    // favorites instead of the previous session's cache.
    ref.watch(authProvider);

    final user = ref.read(authProvider).value;
    if (user == null) {
      return _readCache();
    }

    final repo = AppwriteRecipeFavoritesRepository(user.$id);
    try {
      final stored = await repo.getAll();
      final serverRecipes = stored.map((s) => s.recipe).toList();

      // First-run migration: upload local cache once, then trust server.
      await _maybeMigrate(repo, serverRecipes);

      // After migration, refetch to pick up uploaded rows.
      final merged = await repo.getAll();
      final list = merged.map((s) => s.recipe).toList();
      await _writeCache(list);
      return list;
    } catch (e) {
      debugPrint('Recipe favorites fetch failed, falling back to cache: $e');
      return _readCache();
    }
  }

  Future<void> _maybeMigrate(
    AppwriteRecipeFavoritesRepository repo,
    List<Recipe> serverRecipes,
  ) async {
    if (serverRecipes.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationFlag) ?? false) return;
    final cached = await _readCache();
    if (cached.isEmpty) {
      await prefs.setBool(_migrationFlag, true);
      return;
    }
    for (final r in cached.reversed) {
      try {
        await repo.add(r);
      } catch (e) {
        debugPrint('Migration of favorite "${r.title}" failed: $e');
      }
    }
    await prefs.setBool(_migrationFlag, true);
  }

  Future<List<Recipe>> _readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefKey) ?? const [];
      return raw
          .map((s) => Recipe.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to read favorites cache: $e');
      return const [];
    }
  }

  Future<void> _writeCache(List<Recipe> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _prefKey,
        list.map((r) => jsonEncode(_recipeToJson(r))).toList(),
      );
    } catch (e) {
      debugPrint('Failed to persist favorites cache: $e');
    }
  }

  bool isFavorite(Recipe recipe) {
    final list = state.value ?? const [];
    return list
        .any((r) => r.title == recipe.title && r.culture == recipe.culture);
  }

  Future<void> toggle(Recipe recipe) async {
    final user = ref.read(authProvider).value;
    if (user == null) {
      // Logged-out: still toggle the cache so the UI feels responsive.
      final current = state.value ?? const <Recipe>[];
      final isFav = current.any(
          (r) => r.title == recipe.title && r.culture == recipe.culture);
      final next = isFav
          ? current
              .where((r) =>
                  !(r.title == recipe.title && r.culture == recipe.culture))
              .toList()
          : <Recipe>[recipe, ...current];
      state = AsyncData(next);
      await _writeCache(next);
      return;
    }

    final repo = AppwriteRecipeFavoritesRepository(user.$id);
    final current = state.value ?? const <Recipe>[];
    final isFav = current.any(
        (r) => r.title == recipe.title && r.culture == recipe.culture);

    // Optimistic local update first.
    final optimistic = isFav
        ? current
            .where((r) =>
                !(r.title == recipe.title && r.culture == recipe.culture))
            .toList()
        : <Recipe>[recipe, ...current];
    state = AsyncData(optimistic);

    try {
      if (isFav) {
        await repo.deleteByTitleCulture(recipe.title, recipe.culture);
      } else {
        await repo.add(recipe);
      }
      await _writeCache(optimistic);
    } catch (e) {
      debugPrint('Toggle favorite failed: $e');
      // Roll back on failure.
      state = AsyncData(current);
      rethrow;
    }
  }
}

final recipeFavoritesProvider =
    AsyncNotifierProvider<RecipeFavoritesNotifier, List<Recipe>>(
        RecipeFavoritesNotifier.new);

// ─── History ────────────────────────────────────────────────────────────────

class RecipeHistoryNotifier extends AsyncNotifier<List<Recipe>> {
  static const _prefKey = 'recipe_history';
  static const _migrationFlag = 'recipe_history_migrated_v1';

  @override
  Future<List<Recipe>> build() async {
    ref.watch(authProvider);

    final user = ref.read(authProvider).value;
    if (user == null) return _readCache();

    final repo = AppwriteRecipeHistoryRepository(user.$id);
    try {
      final server = await repo.getAll();
      await _maybeMigrate(repo, server);
      final merged = await repo.getAll();
      await _writeCache(merged);
      return merged;
    } catch (e) {
      debugPrint('Recipe history fetch failed, falling back to cache: $e');
      return _readCache();
    }
  }

  Future<void> _maybeMigrate(
    AppwriteRecipeHistoryRepository repo,
    List<Recipe> server,
  ) async {
    if (server.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationFlag) ?? false) return;
    final cached = await _readCache();
    if (cached.isEmpty) {
      await prefs.setBool(_migrationFlag, true);
      return;
    }
    try {
      // Cached list is already newest-first; addMany inserts in order so the
      // first-listed recipe ends up newest on the server too.
      await repo.addMany(cached);
    } catch (e) {
      debugPrint('History migration failed: $e');
    }
    await prefs.setBool(_migrationFlag, true);
  }

  Future<List<Recipe>> _readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefKey) ?? const [];
      return raw
          .map((s) => Recipe.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to read history cache: $e');
      return const [];
    }
  }

  Future<void> _writeCache(List<Recipe> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _prefKey,
        list.map((r) => jsonEncode(_recipeToJson(r))).toList(),
      );
    } catch (e) {
      debugPrint('Failed to persist history cache: $e');
    }
  }

  Future<void> addMany(List<Recipe> recipes) async {
    if (recipes.isEmpty) return;

    final user = ref.read(authProvider).value;
    if (user == null) {
      // Cache-only path for the logged-out edge case.
      final merged = <Recipe>[...recipes, ...(state.value ?? const [])];
      final seen = <String>{};
      final deduped = <Recipe>[];
      for (final r in merged) {
        final key = '${r.title}|${r.culture}';
        if (seen.add(key)) deduped.add(r);
      }
      final capped =
          deduped.take(AppwriteRecipeHistoryRepository.maxEntries).toList();
      state = AsyncData(capped);
      await _writeCache(capped);
      return;
    }

    final repo = AppwriteRecipeHistoryRepository(user.$id);
    try {
      await repo.addMany(recipes);
      final fresh = await repo.getAll();
      state = AsyncData(fresh);
      await _writeCache(fresh);
    } catch (e) {
      debugPrint('addMany history failed: $e');
      rethrow;
    }
  }
}

final recipeHistoryProvider =
    AsyncNotifierProvider<RecipeHistoryNotifier, List<Recipe>>(
        RecipeHistoryNotifier.new);
