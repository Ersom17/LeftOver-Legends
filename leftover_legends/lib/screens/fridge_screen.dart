// lib/screens/fridge_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/item.dart';
import '../models/recipe.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../providers/user_settings_provider.dart';
import '../widgets/item_card.dart';
import '../providers/recipe_provider.dart';
import 'recipes_screen.dart';
import 'recipe_options_sheet.dart';
import '../providers/receipt_provider.dart';
import 'receipt_review_screen.dart';
import 'rewards_screen.dart';
import 'learn_screen.dart';

class FridgeScreen extends ConsumerWidget {
  const FridgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredItemsProvider);
    final currentFilter = ref.watch(filterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Fridge'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              ref.invalidate(itemsProvider);
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: SegmentedButton<FilterMode>(
              segments: const [
                ButtonSegment(value: FilterMode.all, label: Text('All')),
                ButtonSegment(
                  value: FilterMode.expiring,
                  label: Text('Expiring'),
                ),
                ButtonSegment(value: FilterMode.fresh, label: Text('Fresh')),
              ],
              selected: {currentFilter},
              onSelectionChanged: (selected) {
                ref.read(filterProvider.notifier).state = selected.first;
              },
            ),
          ),
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(child: Text('No items here.'));
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(itemsProvider.notifier).refreshItems(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '${items.length} item${items.length == 1 ? '' : 's'}',
                        ),
                      ),

                      _GenerateRecipesButton(items: items),

                      const SizedBox(height: 12),

                      ...items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ItemCard(
                            item: item,
                            onDelete: () => ref
                                .read(itemsProvider.notifier)
                                .deleteItem(item.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final source = await showModalBottomSheet<String>(
            context: context,
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Add manually'),
                    onTap: () => Navigator.pop(context, 'manual'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Scan receipt'),
                    onTap: () => Navigator.pop(context, 'scan'),
                  ),
                ],
              ),
            ),
          );

          if (source == 'manual') {
            if (context.mounted) context.push('/add');
            return;
          }

          if (source == 'scan') {
            try {
              final result = await ref
                  .read(receiptScanServiceProvider)
                  .scanReceiptFromCamera();

              if (result == null || result.items.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No items detected.')),
                  );
                }
                return;
              }

              if (!context.mounted) return;

              final added = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => ReceiptReviewScreen(items: result.items),
                ),
              );

              if (added == true) {
                ref.read(itemsProvider.notifier).refreshItems();
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Receipt scan failed: $e')),
                );
              }
            }
          }
        },
        icon: const Icon(Icons.receipt_long),
        label: const Text('Add item'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Rewards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LearnScreen()),
            );
          }
          if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RewardsScreen()),
            );
          }
          if (index == 3) {
            context.push('/profile');
          }
        },
      ),
    );
  }
}

class _GenerateRecipesButton extends ConsumerStatefulWidget {
  final List<FridgeItem> items;

  const _GenerateRecipesButton({required this.items});

  @override
  ConsumerState<_GenerateRecipesButton> createState() =>
      _GenerateRecipesButtonState();
}

class _GenerateRecipesButtonState
    extends ConsumerState<_GenerateRecipesButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _loading ? null : _generate,
      icon: _loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.restaurant_menu),
      label: Text(_loading ? 'Generating...' : 'Generate recipes'),
    );
  }

  Future<void> _generate() async {
    final defaultCulture = ref.read(userDefaultCultureProvider);
    final defaultCountry = ref.read(userCountryProvider);

    final options = await showModalBottomSheet<RecipeOptions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: RecipeOptionsSheet(
          defaultCulture: defaultCulture,
          defaultCountry: defaultCountry,
        ),
      ),
    );

    if (options == null) return;

    setState(() => _loading = true);
    try {
      final validItems =
          widget.items.where((item) => item.daysLeft >= 0).toList();

      final result = await ref.read(recipeServiceProvider).generateRecipes(
            items: validItems,
            culture: options.culture,
          );

      final recipesRaw =
          (result['data']?['recipes'] as List<dynamic>?) ?? [];
      final recipes = recipesRaw
          .map((r) => Recipe.fromJson(r as Map<String, dynamic>))
          .toList();

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RecipesScreen(
              recipes: recipes,
              fridgeItems: validItems,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recipe error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
