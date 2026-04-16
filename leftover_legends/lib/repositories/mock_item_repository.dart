// lib/repositories/mock_item_repository.dart
// Fake in-memory data — used by Engineer 1 while the real
// storage layer isn't ready yet. No packages required.
// Switch to LocalItemRepository in item_provider.dart when ready.

import '../models/item.dart';
import 'item_repository.dart';

class MockItemRepository implements ItemRepository {
  // In-memory list — resets every hot reload, that's fine for dev.
  // TODO #12 – mix of fridge/pantry seeds so the location filter is visible.
  // TODO (BACKEND): real location persistence handled by LocalItemRepository.
  final List<FridgeItem> _items = [
    FridgeItem(
      id:         '1',
      name:       'Whole Milk',
      emoji:      '🥛',
      expiryDate: DateTime.now().add(const Duration(days: 1)),
      category:   ItemCategory.dairy,
      addedAt:    DateTime.now().subtract(const Duration(days: 3)),
      location:   ItemLocation.fridge,
    ),
    FridgeItem(
      id:         '2',
      name:       'Broccoli',
      emoji:      '🥦',
      expiryDate: DateTime.now().add(const Duration(days: 3)),
      category:   ItemCategory.veggies,
      addedAt:    DateTime.now().subtract(const Duration(days: 2)),
      location:   ItemLocation.fridge,
    ),
    FridgeItem(
      id:         '3',
      name:       'Free-range Eggs',
      emoji:      '🥚',
      expiryDate: DateTime.now().add(const Duration(days: 5)),
      category:   ItemCategory.protein,
      addedAt:    DateTime.now().subtract(const Duration(days: 1)),
      location:   ItemLocation.fridge,
    ),
    FridgeItem(
      id:         '4',
      name:       'Cheddar',
      emoji:      '🧀',
      expiryDate: DateTime.now().add(const Duration(days: 7)),
      category:   ItemCategory.dairy,
      addedAt:    DateTime.now(),
      location:   ItemLocation.pantry,
    ),
    FridgeItem(
      id:         '5',
      name:       'Apples',
      emoji:      '🍎',
      expiryDate: DateTime.now().add(const Duration(days: 10)),
      category:   ItemCategory.fruit,
      addedAt:    DateTime.now(),
      location:   ItemLocation.pantry,
    ),
  ];

  @override
  Future<List<FridgeItem>> getAll() async {
    // Sort by expiry date so most urgent items appear first
    final sorted = [..._items]
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    return sorted;
  }

  @override
  Future<void> add(FridgeItem item) async {
    _items.add(item);
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> update(FridgeItem updated) async {
    final index = _items.indexWhere((item) => item.id == updated.id);
    if (index != -1) _items[index] = updated;
  }
}
