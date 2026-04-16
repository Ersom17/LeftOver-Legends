// lib/screens/fridge_screen.dart
// R3/R4 — Main fridge list with filter switching.
// Todo #6 — uses shared AppBottomNav.
// Todo #8 — horizontal category filter chips above the status segmented.
// Todo #11 — palette swapped to AppTheme light-mode tokens.
// Todo #12 — location tabs (All / Fridge / Pantry) above the category chips.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_strings.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/item_card.dart';

class FridgeScreen extends ConsumerWidget {
  const FridgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredItemsProvider);
    final currentFilter = ref.watch(filterProvider);
    final currentCategory = ref.watch(categoryFilterProvider);
    final currentLocation = ref.watch(locationFilterProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bgOf(context),
        foregroundColor: AppTheme.primaryOf(context),
        elevation: 0,
        title: Text(
          AppStrings.of(context, 'myFridge'),
          style: TextStyle(
            color: AppTheme.primaryOf(context),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Column(
        children: [
          // TODO #12 – location tabs (All / Fridge / Pantry)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LocationChip(value: null,                  current: currentLocation, label: AppStrings.of(context, 'all'),            ref: ref),
                _LocationChip(value: ItemLocation.fridge,   current: currentLocation, label: AppStrings.of(context, 'fridgeLocation'), ref: ref),
                _LocationChip(value: ItemLocation.pantry,   current: currentLocation, label: AppStrings.of(context, 'pantry'),         ref: ref),
              ],
            ),
          ),

          // TODO #8 – horizontal category filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CategoryChip(value: null, current: currentCategory, label: AppStrings.of(context, 'all'), ref: ref),
                  ...ItemCategory.values.map((c) => _CategoryChip(
                        value: c,
                        current: currentCategory,
                        label: _categoryLabel(c),
                        ref: ref,
                      )),
                ],
              ),
            ),
          ),

          // Existing status filter (All / Expiring / Fresh)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: SegmentedButton<FilterMode>(
              segments: [
                ButtonSegment(value: FilterMode.all,      label: Text(AppStrings.of(context, 'all'))),
                ButtonSegment(value: FilterMode.expiring, label: Text(AppStrings.of(context, 'expiring'))),
                ButtonSegment(value: FilterMode.fresh,    label: Text(AppStrings.of(context, 'fresh'))),
              ],
              selected: {currentFilter},
              onSelectionChanged: (selected) {
                ref.read(filterProvider.notifier).state = selected.first;
              },
            ),
          ),

          // Item list
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      AppStrings.of(context, 'noItems'),
                      style: TextStyle(color: AppTheme.secondaryOf(context)),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '${items.length} item${items.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: AppTheme.secondaryOf(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    ...items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ItemCard(
                            item: item,
                            onDelete: () => ref
                                .read(itemsProvider.notifier)
                                .deleteItem(item.id),
                            // TODO #12 – tap the label row to toggle location
                            onLocationTap: () => ref
                                .read(itemsProvider.notifier)
                                .updateItem(item.copyWith(
                                  location: item.location == ItemLocation.fridge
                                      ? ItemLocation.pantry
                                      : ItemLocation.fridge,
                                )),
                          ),
                        )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add'),
        backgroundColor: AppTheme.orange,
        foregroundColor: AppTheme.white,
        child: const Icon(Icons.add),
      ),
      // TODO #6 – shared bottom nav with navy-active + orange-dot
      bottomNavigationBar: const AppBottomNav(),
    );
  }

  String _categoryLabel(ItemCategory c) {
    switch (c) {
      case ItemCategory.dairy:   return 'Dairy';
      case ItemCategory.veggies: return 'Veggies';
      case ItemCategory.fruit:   return 'Fruit';
      case ItemCategory.protein: return 'Protein';
      case ItemCategory.grains:  return 'Grains';
      case ItemCategory.other:   return 'Other';
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final ItemCategory? value;
  final ItemCategory? current;
  final String label;
  final WidgetRef ref;

  const _CategoryChip({
    required this.value,
    required this.current,
    required this.label,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          ref.read(categoryFilterProvider.notifier).state = value;
        },
        backgroundColor: AppTheme.surfaceOf(context),
        selectedColor: AppTheme.orange.withValues(alpha: 0.2),
        checkmarkColor: AppTheme.primaryOf(context),
        side: BorderSide(
          color: selected ? AppTheme.orange : AppTheme.borderOf(context),
        ),
        labelStyle: TextStyle(
          color: selected ? AppTheme.primaryOf(context) : AppTheme.secondaryOf(context),
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  final ItemLocation? value;
  final ItemLocation? current;
  final String label;
  final WidgetRef ref;

  const _LocationChip({
    required this.value,
    required this.current,
    required this.label,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
          label: Center(child: Text(label)),
          selected: selected,
          onSelected: (_) {
            ref.read(locationFilterProvider.notifier).state = value;
          },
          backgroundColor: AppTheme.surfaceOf(context),
          selectedColor: AppTheme.navy,
          side: BorderSide(
            color: selected ? AppTheme.navy : AppTheme.borderOf(context),
          ),
          labelStyle: TextStyle(
            color: selected ? AppTheme.white : AppTheme.primaryOf(context),
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
