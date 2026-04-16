// lib/screens/recipe_screen.dart
// Todo #5 — recipe list with status-colored ingredient chips.
// Todo #3 — help icon in the AppBar opens a color-legend bottom sheet.
// TODO (FUTURE): SUPSI education tab; awaiting markdown/JSON content delivery.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import '../providers/item_provider.dart';
import '../providers/recipe_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_strings.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/recipe_card.dart';

class RecipeScreen extends ConsumerWidget {
  const RecipeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(hardcodedRecipesProvider);
    final itemsAsync = ref.watch(itemsProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bgOf(context),
        foregroundColor: AppTheme.primaryOf(context),
        title: Text(
          AppStrings.of(context, 'recipes'),
          style: TextStyle(
            color: AppTheme.primaryOf(context),
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          // TODO #3 – help icon opens the color legend
          IconButton(
            icon: Icon(Icons.help_outline, color: AppTheme.primaryOf(context)),
            tooltip: 'Color legend',
            onPressed: () => _showColorLegend(context),
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (fridge) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          itemCount: recipes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final recipe = recipes[i];
            // Pre-compute a map of {ingredient name → status} for this recipe
            final statuses = <String, IngredientStatus>{
              for (final ing in recipe.ingredients)
                ing.name: statusFor(ing, fridge),
            };
            return RecipeCard(recipe: recipe, statuses: statuses);
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }

  void _showColorLegend(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO #3 – color legend explaining the status system
            Text(
              AppStrings.of(ctx, 'colorKey'),
              style: TextStyle(
                color: AppTheme.primaryOf(ctx),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            _LegendRow(color: AppTheme.danger,  label: AppStrings.of(ctx, 'expiringSoon')),
            const SizedBox(height: 10),
            _LegendRow(color: AppTheme.warn,    label: AppStrings.of(ctx, 'useWithin5')),
            const SizedBox(height: 10),
            _LegendRow(color: AppTheme.good,    label: AppStrings.of(ctx, 'plentyOfTime')),
            const SizedBox(height: 10),
            _LegendRow(color: AppTheme.missing, label: AppStrings.of(ctx, 'notInFridge')),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppTheme.primaryOf(context),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
