// lib/models/recipe.dart

class Recipe {
  final String title;
  final String description;
  final String culture;
  final List<String> ingredientsUsed;
  final List<String> priorityIngredientsUsed;
  final List<String> missingIngredients;
  final List<String> steps;

  const Recipe({
    required this.title,
    required this.description,
    required this.culture,
    required this.ingredientsUsed,
    required this.priorityIngredientsUsed,
    required this.missingIngredients,
    required this.steps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      culture: json['culture'] as String? ?? '',
      ingredientsUsed: List<String>.from(json['ingredients_used'] ?? []),
      priorityIngredientsUsed:
          List<String>.from(json['priority_ingredients_used'] ?? []),
      missingIngredients:
          List<String>.from(json['missing_ingredients'] ?? []),
      steps: List<String>.from(json['steps'] ?? []),
    );
  }
}
