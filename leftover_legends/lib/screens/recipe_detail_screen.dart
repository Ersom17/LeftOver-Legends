// lib/screens/recipe_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/recipe.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  final List<FridgeItem> fridgeItems;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.fridgeItems,
  });

  Color _chipColor(String ingredientName) {
    final match = fridgeItems.firstWhere(
      (item) => item.name.toLowerCase() == ingredientName.toLowerCase(),
      orElse: () => FridgeItem(
        id: '', name: '', emoji: '', expiryDate: DateTime.now().add(const Duration(days: 999)),
        category: ItemCategory.other, addedAt: DateTime.now(), ownerId: '',
      ),
    );
    if (match.daysLeft <= 1) return const Color(0xFFC05050);
    if (match.daysLeft <= 4) return const Color(0xFFE8A838);
    return const Color(0xFF6BAF7A);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F1C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8A9E90)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          recipe.culture,
          style: const TextStyle(
            color: Color(0xFF5C9E6E),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              recipe.title,
              style: const TextStyle(
                color: Color(0xFFF5EFE0),
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              recipe.description,
              style: const TextStyle(
                color: Color(0xFF8A9E90),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Ingredients from fridge
            _sectionTitle('From your fridge'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recipe.ingredientsUsed
                  .map((ing) {
                    final color = _chipColor(ing);
                    return _ingredientChip(
                      ing,
                      color,
                      icon: color == const Color(0xFFC05050)
                          ? Icons.warning_amber_rounded
                          : Icons.check,
                    );
                  })
                  .toList(),
            ),

            if (recipe.missingIngredients.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionTitle('You\'ll also need'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: recipe.missingIngredients
                    .map((ing) => _ingredientChip(
                          ing,
                          const Color(0xFF8A9E90),
                          icon: Icons.add_shopping_cart,
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 28),
            _sectionTitle('Steps'),
            const SizedBox(height: 14),

            ...recipe.steps.asMap().entries.map((entry) {
              final i = entry.key;
              final step = entry.value;
              final isLast = i == recipe.steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step number + line
                  Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5C9E6E).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF5C9E6E).withOpacity(0.4),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Color(0xFF5C9E6E),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 1,
                          height: 24,
                          color: const Color(0xFF2E3830),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                      child: Text(
                        step,
                        style: const TextStyle(
                          color: Color(0xFFF5EFE0),
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF8A9E90),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      );

  Widget _ingredientChip(String label, Color color, {required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
