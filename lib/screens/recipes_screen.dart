// lib/screens/recipes_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../models/recipe.dart';
import '../providers/locale_provider.dart';
import '../providers/mascot_tour_provider.dart';
import '../providers/recipe_favorites_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/mascot_tour/mascot_tour_anchors.dart';
import 'recipe_detail_screen.dart';

class RecipesScreen extends ConsumerWidget {
  final List<Recipe> recipes;
  final List<FridgeItem> fridgeItems;

  const RecipesScreen({
    super.key,
    required this.recipes,
    required this.fridgeItems,
  });

  Color _chipColor(String ingredientName) {
    final match = fridgeItems.firstWhere(
      (item) => item.name.toLowerCase() == ingredientName.toLowerCase(),
      orElse: () => FridgeItem(
        id: '',
        name: '',
        emoji: '',
        expiryDate: DateTime.now().add(const Duration(days: 999)),
        category: ItemCategory.other,
        addedAt: DateTime.now(),
        ownerId: '',
      ),
    );
    if (match.daysLeft <= 1) return AppColors.danger;
    if (match.daysLeft <= 4) return AppColors.warn;
    return AppColors.good;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(recipeFavoritesProvider);
    final favoritesNotifier = ref.read(recipeFavoritesProvider.notifier);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBeige,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(strings.recipesTitle),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: recipes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          final isFirst = index == 0;
          final isFavorite =
              favorites.any((r) => r.title == recipe.title && r.culture == recipe.culture);

          return GestureDetector(
            key: isFirst
                ? MascotAnchors.keyFor(MascotAnchorIds.recipeCardFirst)
                : null,
            onTap: () {
              if (isFirst) {
                ref
                    .read(mascotTourProvider.notifier)
                    .notifyAction(MascotActions.tapRecipeCard);
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecipeDetailScreen(
                    recipe: recipe,
                    fridgeItems: fridgeItems,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isFirst
                      ? AppColors.darkGreen.withOpacity(0.5)
                      : AppColors.cardBackground,
                  width: isFirst ? 1.5 : 1,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isFirst
                              ? AppColors.darkGreen
                              : AppColors.darkGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isFirst
                                  ? AppColors.white
                                  : AppColors.darkGreen,
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
                            color: AppColors.darkGreen,
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
                            color: AppColors.warmGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.warmGold.withOpacity(0.5)),
                          ),
                          child: Text(
                            strings.recipesBestMatch,
                            style: const TextStyle(
                              color: AppColors.warmGold,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => favoritesNotifier.toggle(recipe),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            isFavorite
                                ? Icons.bookmark
                                : Icons.bookmark_outline,
                            color: isFavorite
                                ? AppColors.warmGold
                                : AppColors.softGrayText,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    recipe.description,
                    style: const TextStyle(
                      color: AppColors.softGrayText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...recipe.ingredientsUsed.map(
                        (ing) => _chip(ing, _chipColor(ing)),
                      ),
                      ...recipe.missingIngredients.map(
                        (ing) => _chip(ing, AppColors.mutedOlive, isShop: true),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.format_list_numbered,
                          color: AppColors.softGrayText, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.steps.length} ${strings.recipesStepsSuffix}',
                        style: const TextStyle(
                          color: AppColors.softGrayText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right,
                          color: AppColors.softGrayText, size: 18),
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
