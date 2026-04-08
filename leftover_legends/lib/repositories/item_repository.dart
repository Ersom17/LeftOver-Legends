import '../models/item.dart';

abstract class ItemRepository {
  Future<List<FridgeItem>> getAll();
  Future<void> add(FridgeItem item);
  Future<void> delete(String id);
  Future<void> update(FridgeItem item);
}