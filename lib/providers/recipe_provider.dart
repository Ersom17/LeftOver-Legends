import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/recipe_service.dart';

final recipeServiceProvider = Provider<RecipeService>((ref) {
  return RecipeService();
});