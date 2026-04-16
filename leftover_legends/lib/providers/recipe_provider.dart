// lib/providers/recipe_provider.dart
// Todo #5 — hardcoded recipes + ingredient status resolution against fridge.
// TODO (BACKEND): replace _seed with an API-backed Future provider.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../models/recipe.dart';

// Resolves an ingredient's status against the user's current fridge.
// Logic (per plan):
//   - missing   → no fridge item's name (lowercased) contains this ingredient.
//   - expiring  → matched fridge item has status == danger (daysLeft <= 1).
//   - available → otherwise (includes warn items — yellow is fridge-only).
IngredientStatus statusFor(RecipeIngredient ing, List<FridgeItem> fridge) {
  final needle = ing.name.toLowerCase();
  FridgeItem? match;
  for (final item in fridge) {
    if (item.name.toLowerCase().contains(needle)) {
      match = item;
      break;
    }
  }
  if (match == null) return IngredientStatus.missing;
  if (match.status == ExpiryStatus.danger) return IngredientStatus.expiring;
  return IngredientStatus.available;
}

// Seed list — intentionally small and ingredient names chosen to overlap
// with the mock fridge items (Milk, Broccoli, Eggs, Cheddar, Apples) so the
// status resolution is visible in dev.
const _seed = <Recipe>[
  Recipe(
    id: 'scrambled-eggs',
    title: 'Scrambled Eggs on Toast',
    prepMinutes: 10,
    url: 'https://leftoverlegends.com/recipes/scrambled-eggs',
    ingredients: [
      RecipeIngredient(name: 'Eggs',   emoji: '🥚'),
      RecipeIngredient(name: 'Milk',   emoji: '🥛'),
      RecipeIngredient(name: 'Bread',  emoji: '🍞'),
      RecipeIngredient(name: 'Butter', emoji: '🧈'),
    ],
    energyKcalPerServing: 320,
    servingGrams: 180,
  ),
  Recipe(
    id: 'veggie-stir-fry',
    title: 'Quick Veggie Stir-Fry',
    prepMinutes: 20,
    url: 'https://leftoverlegends.com/recipes/veggie-stir-fry',
    ingredients: [
      RecipeIngredient(name: 'Broccoli', emoji: '🥦'),
      RecipeIngredient(name: 'Onion',    emoji: '🧅'),
      RecipeIngredient(name: 'Pepper',   emoji: '🫑'),
      RecipeIngredient(name: 'Rice',     emoji: '🍚'),
    ],
    energyKcalPerServing: 410,
    servingGrams: 320,
  ),
  Recipe(
    id: 'grilled-cheese',
    title: 'Classic Grilled Cheese',
    prepMinutes: 8,
    url: 'https://leftoverlegends.com/recipes/grilled-cheese',
    ingredients: [
      RecipeIngredient(name: 'Cheddar', emoji: '🧀'),
      RecipeIngredient(name: 'Bread',   emoji: '🍞'),
      RecipeIngredient(name: 'Butter',  emoji: '🧈'),
    ],
    energyKcalPerServing: 480,
    servingGrams: 160,
  ),
  Recipe(
    id: 'apple-crumble',
    title: 'Warm Apple Crumble',
    prepMinutes: 35,
    url: 'https://leftoverlegends.com/recipes/apple-crumble',
    ingredients: [
      RecipeIngredient(name: 'Apples', emoji: '🍎'),
      RecipeIngredient(name: 'Butter', emoji: '🧈'),
      RecipeIngredient(name: 'Flour',  emoji: '🌾'),
      RecipeIngredient(name: 'Sugar',  emoji: '🍬'),
    ],
    energyKcalPerServing: 560,
    servingGrams: 240,
  ),
  Recipe(
    id: 'tomato-pasta',
    title: 'Pasta al Pomodoro',
    prepMinutes: 25,
    url: 'https://leftoverlegends.com/recipes/pasta-al-pomodoro',
    ingredients: [
      RecipeIngredient(name: 'Pasta',  emoji: '🍝'),
      RecipeIngredient(name: 'Tomato', emoji: '🍅'),
      RecipeIngredient(name: 'Garlic', emoji: '🧄'),
      RecipeIngredient(name: 'Basil',  emoji: '🌿'),
    ],
    energyKcalPerServing: 520,
    servingGrams: 300,
  ),
];

// Public provider consumed by the recipe screen.
final hardcodedRecipesProvider = Provider<List<Recipe>>((ref) => _seed);
