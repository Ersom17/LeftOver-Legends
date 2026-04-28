// lib/screens/recipe_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/item.dart';
import '../models/recipe.dart';
import '../providers/item_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/mascot_tour_provider.dart';
import '../providers/recipe_favorites_provider.dart';
import '../services/item_removal_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mascot_tour/mascot_tour_anchors.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Recipe recipe;
  final List<FridgeItem> fridgeItems;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.fridgeItems,
  });

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  bool _consuming = false;

  Recipe get recipe => widget.recipe;
  List<FridgeItem> get fridgeItems => widget.fridgeItems;

  Future<void> _openSearch(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _youtubeSearchUrl() {
    final q = Uri.encodeQueryComponent('${recipe.title} recipe how to cook');
    return 'https://www.youtube.com/results?search_query=$q';
  }

  String _recipeSearchUrl() {
    final q = Uri.encodeQueryComponent('${recipe.title} ${recipe.culture} recipe');
    return 'https://www.google.com/search?q=$q';
  }

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
  Widget build(BuildContext context) {
    final favorites = ref.watch(recipeFavoritesProvider);
    final isFavorite = favorites
        .any((r) => r.title == recipe.title && r.culture == recipe.culture);
    final itemsAsync = ref.watch(itemsProvider);
    final currentItems = itemsAsync.maybeWhen(
      data: (items) => items,
      orElse: () => fridgeItems,
    );
    final matchedItems = _matchIngredientsToItems(currentItems);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBeige,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          recipe.culture,
          style: const TextStyle(
            color: AppColors.mutedOlive,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(recipeFavoritesProvider.notifier).toggle(recipe),
            icon: Icon(
              isFavorite ? Icons.bookmark : Icons.bookmark_outline,
              color:
                  isFavorite ? AppColors.warmGold : AppColors.softGrayText,
            ),
            tooltip: isFavorite
                ? strings.detailRemoveFavorite
                : strings.detailSaveFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipe.title,
              style: const TextStyle(
                color: AppColors.darkGreen,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              recipe.description,
              style: const TextStyle(
                color: AppColors.softGrayText,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  key: MascotAnchors.keyFor(MascotAnchorIds.recipeYoutube),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref
                          .read(mascotTourProvider.notifier)
                          .notifyAction(MascotActions.tapYoutubeButton);
                      _openSearch(_youtubeSearchUrl());
                    },
                    icon: const Icon(Icons.play_circle_outline, size: 18),
                    label: Text(
                      strings.detailWatchYoutube,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(color: AppColors.danger.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openSearch(_recipeSearchUrl()),
                    icon: const Icon(Icons.menu_book_outlined, size: 18),
                    label: Text(
                      strings.detailFindOnline,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _sectionTitle(strings.detailFromFridge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recipe.ingredientsUsed.map((ing) {
                final color = _chipColor(ing);
                return _ingredientChip(
                  ing,
                  color,
                  icon: color == AppColors.danger
                      ? Icons.warning_amber_rounded
                      : Icons.check,
                );
              }).toList(),
            ),

            if (recipe.missingIngredients.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionTitle(strings.detailAlsoNeed),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: recipe.missingIngredients
                    .map((ing) => _ingredientChip(
                          ing,
                          AppColors.mutedOlive,
                          icon: Icons.add_shopping_cart,
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 28),
            _sectionTitle(strings.detailSteps),
            const SizedBox(height: 14),

            ...recipe.steps.asMap().entries.map((entry) {
              final i = entry.key;
              final step = entry.value;
              final isLast = i == recipe.steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.darkGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.darkGreen.withOpacity(0.4),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: AppColors.darkGreen,
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
                          color: AppColors.cardBackground,
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
                          color: AppColors.darkGreen,
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _consuming || matchedItems.isEmpty
                  ? null
                  : () => _confirmAndConsume(matchedItems),
              icon: _consuming
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                matchedItems.isEmpty
                    ? strings.consumeIdleNone
                    : _consuming
                        ? strings.consumeLoading
                        : '${strings.consumeCtaPrefix}${matchedItems.length} ${matchedItems.length == 1 ? strings.consumeCtaItemOne : strings.consumeCtaItemMany}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Find pantry items whose name matches an ingredient the recipe will use.
  /// Case-insensitive, deduped so we never remove the same item twice if the
  /// recipe mentions the same ingredient more than once.
  List<FridgeItem> _matchIngredientsToItems(List<FridgeItem> items) {
    final usedNames = recipe.ingredientsUsed
        .map((n) => n.trim().toLowerCase())
        .where((n) => n.isNotEmpty)
        .toSet();

    final matches = <FridgeItem>[];
    final seenIds = <String>{};
    for (final item in items) {
      if (usedNames.contains(item.name.trim().toLowerCase()) &&
          seenIds.add(item.id)) {
        matches.add(item);
      }
    }
    return matches;
  }

  Future<void> _confirmAndConsume(List<FridgeItem> items) async {
    final strings = ref.read(appStringsProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.lightBeige,
        title: Text(strings.consumeDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.consumeDialogBody),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '• ${item.emoji.isNotEmpty ? '${item.emoji} ' : ''}${item.name}',
                  style: const TextStyle(
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.softGrayText,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(strings.cancel),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(strings.consumeDialogConfirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _consuming = true);
    try {
      final notifier = ref.read(itemsProvider.notifier);
      for (final item in items) {
        await notifier.removeItem(item.id, ItemRemovalReason.consumed);
      }
      if (!mounted) return;
      final successMessage = items.length == 1
          ? strings.consumeSuccessOne
          : strings.consumeSuccessMany
              .replaceAll('{n}', items.length.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: AppColors.darkGreen,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${strings.consumeFailure}: $e')),
      );
    } finally {
      if (mounted) setState(() => _consuming = false);
    }
  }

  Widget _sectionTitle(String text) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.mutedOlive,
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
