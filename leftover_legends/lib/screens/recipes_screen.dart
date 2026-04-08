// lib/screens/recipes_screen.dart

import 'package:flutter/material.dart';
import '../models/recipe.dart';
import 'recipe_detail_screen.dart';

class RecipesScreen extends StatelessWidget {
  final List<Recipe> recipes;

  const RecipesScreen({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F1C),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF8A9E90)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Generated Recipes',
          style: TextStyle(
            color: Color(0xFFF5EFE0),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: recipes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          final isFirst = index == 0;

          return GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RecipeDetailScreen(recipe: recipe),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF232B25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isFirst
                      ? const Color(0xFF5C9E6E).withOpacity(0.6)
                      : const Color(0xFF2E3830),
                  width: isFirst ? 1.5 : 1,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Index badge
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isFirst
                              ? const Color(0xFF5C9E6E)
                              : const Color(0xFF2E3830),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isFirst
                                  ? Colors.white
                                  : const Color(0xFF8A9E90),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          recipe.title,
                          style: const TextStyle(
                            color: Color(0xFFF5EFE0),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (isFirst)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5C9E6E).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFF5C9E6E).withOpacity(0.4)),
                          ),
                          child: const Text(
                            'Best match',
                            style: TextStyle(
                              color: Color(0xFF5C9E6E),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    recipe.description,
                    style: const TextStyle(
                      color: Color(0xFF8A9E90),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Ingredients chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...recipe.ingredientsUsed.map(
                        (ing) => _chip(
                          ing,
                          recipe.priorityIngredientsUsed.contains(ing)
                              ? const Color(0xFFC05050)
                              : const Color(0xFF5C9E6E),
                        ),
                      ),
                      ...recipe.missingIngredients.map(
                        (ing) => _chip(ing, const Color(0xFF3A4540),
                            isShop: true),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.format_list_numbered,
                          color: Color(0xFF3A4540), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.steps.length} steps',
                        style: const TextStyle(
                          color: Color(0xFF3A4540),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right,
                          color: Color(0xFF3A4540), size: 18),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _chip(String label, Color color, {bool isShop = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isShop) ...[
            Icon(Icons.add_shopping_cart, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
