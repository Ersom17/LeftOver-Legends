// lib/widgets/recipe_card.dart
// Todo #5 / #7 / #10 — recipe card showing:
//   - Title (navy) and prep time (#7)
//   - Ingredient chips colored by status: green/red/grey (#5)
//   - Energy + serving line formatted per region (#10)
//   - "View recipe" link opening the URL via url_launcher (#7)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/recipe.dart';
import '../providers/item_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_strings.dart';

class RecipeCard extends ConsumerWidget {
  final Recipe recipe;
  // Per-ingredient status resolved by the parent from the current fridge.
  final Map<String, IngredientStatus> statuses;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.statuses,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO #10 – energy/weight formatted based on the selected region
    final region = ref.watch(regionProvider);
    final energy = formatEnergy(recipe.energyKcalPerServing, region);
    final weight = formatWeight(recipe.servingGrams, region);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            recipe.title,
            style: TextStyle(
              color: AppTheme.primaryOf(context),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),

          // TODO #7 – prep time row
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: AppTheme.secondaryOf(context)),
              const SizedBox(width: 6),
              Text(
                '${recipe.prepMinutes} min',
                style: TextStyle(
                  color: AppTheme.secondaryOf(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 14),
              // TODO #10 – energy/weight per region
              Icon(Icons.local_fire_department,
                  size: 16, color: AppTheme.secondaryOf(context)),
              const SizedBox(width: 6),
              Text(
                '$energy · $weight',
                style: TextStyle(
                  color: AppTheme.secondaryOf(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // TODO #5 – ingredient chips colored by status
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: recipe.ingredients.map((ing) {
              final status = statuses[ing.name] ?? IngredientStatus.missing;
              final c = _statusColor(status);
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.15),
                  border: Border.all(color: c),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(ing.emoji, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      ing.name,
                      style: TextStyle(
                        color: c,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // TODO #7 – view recipe link (url_launcher)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => launchUrl(
                Uri.parse(recipe.url),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: Text(AppStrings.of(context, 'viewRecipe')),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.orange,
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(IngredientStatus s) {
    switch (s) {
      case IngredientStatus.available: return AppTheme.good;
      case IngredientStatus.expiring:  return AppTheme.danger;
      case IngredientStatus.missing:   return AppTheme.missing;
    }
  }
}
