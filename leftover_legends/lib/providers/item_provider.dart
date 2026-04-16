// lib/providers/item_provider.dart
// State management layer — shared between both engineers.
// To switch from mock to real storage, change MockItemRepository
// to LocalItemRepository on line 16. That's the only change needed.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../repositories/item_repository.dart';
// import '../repositories/mock_item_repository.dart';
import '../repositories/local_item_repository.dart'; // ← real storage

// The repository provider — swap implementation here
final repositoryProvider = Provider<ItemRepository>((ref) {
  // return MockItemRepository();
  return LocalItemRepository(); // ← real localStorage persistence
});

// The main items state notifier
class ItemNotifier extends AsyncNotifier<List<FridgeItem>> {
  late ItemRepository _repo;

  @override
  Future<List<FridgeItem>> build() async {
    _repo = ref.read(repositoryProvider);
    return _repo.getAll();
  }

  Future<void> addItem(FridgeItem item) async {
    await _repo.add(item);
    state = AsyncData(await _repo.getAll());
  }

  Future<void> deleteItem(String id) async {
    await _repo.delete(id);
    state = AsyncData(await _repo.getAll());
  }

  Future<void> updateItem(FridgeItem item) async {
    await _repo.update(item);
    state = AsyncData(await _repo.getAll());
  }
}

// The provider screens watch
final itemsProvider =
    AsyncNotifierProvider<ItemNotifier, List<FridgeItem>>(ItemNotifier.new);

// Filter mode enum
enum FilterMode { all, expiring, fresh }

// Filter state provider
final filterProvider = StateProvider<FilterMode>((ref) => FilterMode.all);

// TODO #8 – filter by food category; null = All
final categoryFilterProvider = StateProvider<ItemCategory?>((ref) => null);

// TODO #12 – filter by storage location; null = All
final locationFilterProvider = StateProvider<ItemLocation?>((ref) => null);

// Filtered + sorted items provider.
// Sort: ascending by expiryDate — soonest-to-expire first (Todo #8 default).
// Filters applied in order: location (Todo #12) → category (Todo #8) → expiry.
final filteredItemsProvider = Provider<AsyncValue<List<FridgeItem>>>((ref) {
  final mode = ref.watch(filterProvider);
  final category = ref.watch(categoryFilterProvider);
  final location = ref.watch(locationFilterProvider);
  return ref.watch(itemsProvider).whenData((items) {
    // Soonest-to-expire first
    final sorted = [...items]
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    // TODO #12 – location filter first
    final afterLocation = location == null
        ? sorted
        : sorted.where((i) => i.location == location).toList();

    // TODO #8 – category filter
    final afterCategory = category == null
        ? afterLocation
        : afterLocation.where((i) => i.category == category).toList();

    // Expiry-status filter (existing behavior)
    switch (mode) {
      case FilterMode.all:
        return afterCategory;
      case FilterMode.expiring:
        return afterCategory
            .where((i) =>
                i.status == ExpiryStatus.danger ||
                i.status == ExpiryStatus.warn)
            .toList();
      case FilterMode.fresh:
        return afterCategory
            .where((i) => i.status == ExpiryStatus.good)
            .toList();
    }
  });
});

// Convenience provider: items filtered by expiry status
// Usage: ref.watch(expiringItemsProvider) in any screen
final expiringItemsProvider = Provider<AsyncValue<List<FridgeItem>>>((ref) {
  return ref.watch(itemsProvider).whenData(
    (items) => items
        .where((i) => i.status != ExpiryStatus.good)
        .toList(),
  );
});

// TODO #6 – which bottom-nav tab is currently active.
// 0 = Fridge, 1 = Recipes, 2 = Profile.
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

// Appearance — light / system / dark theme mode.
// TODO (BACKEND): persist to SharedPreferences once settings land.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Language / locale selection.
// TODO (FUTURE): full intl string catalogue for Italian; currently controls
// built-in Flutter widget locale (date pickers, etc.).
// TODO (BACKEND): persist to SharedPreferences once settings land.
final languageProvider = StateProvider<Locale>((ref) => const Locale('en'));

// TODO #10 – region drives units (kcal vs kJ, imperial vs metric).
// Set by the RegionScreen (#13) at sign-in; consumed by recipe cards.
// TODO (BACKEND): persist selection in SharedPreferences once settings land.
enum Region { us, ch }

final regionProvider = StateProvider<Region>((ref) => Region.us);

// Unit formatters — pure functions called from UI.
// US → imperial + kcal; CH → metric + kJ.
String formatEnergy(double kcal, Region r) => r == Region.us
    ? '${kcal.round()} kcal'
    : '${(kcal * 4.184).round()} kJ';

String formatWeight(double grams, Region r) => r == Region.us
    ? '${(grams / 28.35).toStringAsFixed(1)} oz'
    : '${grams.round()} g';
