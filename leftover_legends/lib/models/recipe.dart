// lib/models/recipe.dart
// Recipe data model used by the recipe screen (Todos #5, #7, #10).
// Frontend-only; recipes are hardcoded in recipe_provider.dart.
// TODO (BACKEND): replace with an API-backed list when the backend lands.

// Ingredient state relative to the user's fridge.
// Drives chip color on recipe cards:
//   available → green   (fridge has it, fresh or warn)
//   expiring  → red     (fridge has it, daysLeft <= 1)
//   missing   → grey    (not in fridge)
// NOTE: yellow (warn) resolves to `available` on recipe cards — yellow is
// fridge-only per the todo. The legend sheet (#3) still mentions yellow so
// users can connect the traffic-light system on fridge items to the recipe
// screen's reduced palette.
enum IngredientStatus { available, expiring, missing }

class RecipeIngredient {
  final String name;   // matched against FridgeItem.name (case-insensitive contains)
  final String emoji;

  const RecipeIngredient({
    required this.name,
    required this.emoji,
  });
}

class Recipe {
  final String id;
  final String title;
  final int prepMinutes;              // Todo #7
  final String url;                   // Todo #7 — opened via url_launcher
  final List<RecipeIngredient> ingredients;
  final double energyKcalPerServing;  // Todo #10 — formatted as kcal or kJ
  final double servingGrams;          // Todo #10 — formatted as oz or g

  const Recipe({
    required this.id,
    required this.title,
    required this.prepMinutes,
    required this.url,
    required this.ingredients,
    required this.energyKcalPerServing,
    required this.servingGrams,
  });
}
