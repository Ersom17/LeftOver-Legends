import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../repositories/item_repository.dart';
import '../repositories/appwrite_item_repository.dart';
import 'auth_provider.dart';

final repositoryProvider = Provider<ItemRepository>((ref) {
  final authState = ref.watch(authProvider);
  final user = authState.value;

  if (user == null) {
    throw Exception('User not logged in');
  }

  return AppwriteItemRepository(user.$id);
});

class ItemNotifier extends AsyncNotifier<List<FridgeItem>> {
  @override
  Future<List<FridgeItem>> build() async {
    ref.watch(authProvider);

    final authState = ref.read(authProvider);
    final user = authState.value;

    if (user == null) {
      return [];
    }

    final repo = AppwriteItemRepository(user.$id);
    return repo.getAll();
  }

  Future<void> refreshItems() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authProvider);
      final user = authState.value;

      if (user == null) return <FridgeItem>[];

      final repo = AppwriteItemRepository(user.$id);
      return repo.getAll();
    });
  }

  Future<void> addItem(FridgeItem item) async {
    final authState = ref.read(authProvider);
    final user = authState.value;

    if (user == null) return;

    final repo = AppwriteItemRepository(user.$id);
    await repo.add(item);
    state = AsyncData(await repo.getAll());
  }

  Future<void> deleteItem(String id) async {
    final authState = ref.read(authProvider);
    final user = authState.value;

    if (user == null) return;

    final repo = AppwriteItemRepository(user.$id);
    await repo.delete(id);
    state = AsyncData(await repo.getAll());
  }

  Future<void> updateItem(FridgeItem item) async {
    final authState = ref.read(authProvider);
    final user = authState.value;

    if (user == null) return;

    final repo = AppwriteItemRepository(user.$id);
    await repo.update(item);
    state = AsyncData(await repo.getAll());
  }
}

final itemsProvider =
    AsyncNotifierProvider<ItemNotifier, List<FridgeItem>>(ItemNotifier.new);

enum FilterMode { all, expiring, fresh }

final filterProvider = StateProvider<FilterMode>((ref) => FilterMode.all);

final filteredItemsProvider = Provider<AsyncValue<List<FridgeItem>>>((ref) {
  final mode = ref.watch(filterProvider);

  return ref.watch(itemsProvider).whenData((items) {
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
        return sorted.where((i) => i.status == ExpiryStatus.good).toList();
    }
  });
});