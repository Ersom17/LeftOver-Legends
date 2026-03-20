// lib/repositories/local_item_repository.dart
// Real implementation using shared_preferences (browser localStorage).
// Engineer 2 owns this file. Swap it in via item_provider.dart
// once it's ready and tested.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item.dart';
import 'item_repository.dart';

class LocalItemRepository implements ItemRepository {
  static const _key = 'fridge_items';

  Future<List<FridgeItem>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((e) => FridgeItem.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _save(List<FridgeItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      items.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  @override
  Future<List<FridgeItem>> getAll() async {
    final items = await _load();
    items.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    return items;
  }

  @override
  Future<void> add(FridgeItem item) async {
    final items = await _load();
    items.add(item);
    await _save(items);
  }

  @override
  Future<void> delete(String id) async {
    final items = await _load();
    items.removeWhere((item) => item.id == id);
    await _save(items);
  }

  @override
  Future<void> update(FridgeItem updated) async {
    final items = await _load();
    final index = items.indexWhere((item) => item.id == updated.id);
    if (index != -1) items[index] = updated;
    await _save(items);
  }
}
