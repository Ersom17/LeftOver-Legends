// lib/repositories/item_repository.dart
// Abstract interface — Engineer 1 codes UI against this.
// Engineer 2 provides the real implementation (LocalItemRepository).
// Never import a concrete implementation directly in screens/providers.

import '../models/item.dart';

abstract class ItemRepository {
  // Returns all stored items, sorted by expiry date ascending
  Future<List<FridgeItem>> getAll();

  // Persists a new item
  Future<void> add(FridgeItem item);

  // Removes an item by its id
  Future<void> delete(String id);

  // Replaces an existing item (same id) with updated data
  Future<void> update(FridgeItem item);
}
