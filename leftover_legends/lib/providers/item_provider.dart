// lib/providers/item_provider.dart
// State management layer — shared between both engineers.
// To switch from mock to real storage, change MockItemRepository
// to LocalItemRepository on line 16. That's the only change needed.

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

// Filtered + sorted items provider
final filteredItemsProvider = Provider<AsyncValue<List<FridgeItem>>>((ref) {
  final mode = ref.watch(filterProvider);
  return ref.watch(itemsProvider).whenData((items) {
    // Sort by expiry date, soonest first
    final sorted = [...items]
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    switch (mode) {
      case FilterMode.all:
        return sorted;
      case FilterMode.expiring:
        return sorted
            .where((i) =>
                i.status == ExpiryStatus.danger ||
                i.status == ExpiryStatus.warn)
            .toList();
      case FilterMode.fresh:
        return sorted
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
