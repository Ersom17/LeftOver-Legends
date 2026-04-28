import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../repositories/item_repository.dart';
import '../repositories/appwrite_item_repository.dart';
import '../services/item_removal_service.dart';
import 'auth_provider.dart';
import 'pantry_events_provider.dart';

final itemRemovalServiceProvider = Provider<ItemRemovalService>((ref) {
  return ItemRemovalService();
});

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
    // Track for Insights — we use the input item directly because the
    // listing reload below may reorder it.
    await ref
        .read(pantryEventsProvider.notifier)
        .log(item: item, kind: PantryEventKind.added);
    state = AsyncData(await repo.getAll());
  }

  /// Delete an item with a removal reason
  /// - [ItemRemovalReason.thrownAway]: Increments totalWasted counter
  /// - [ItemRemovalReason.consumed]: Just deletes the item
  /// - [ItemRemovalReason.deleted]: Just deletes the item
  Future<void> removeItem(
    String itemId,
    ItemRemovalReason reason,
  ) async {
    final authState = ref.read(authProvider);
    final user = authState.value;

    if (user == null) return;

    // Snapshot the item from the current list so we can log it AFTER
    // removal completes — once the doc is gone the repository can no
    // longer answer "what category was that?".
    final priorItem = state.value
        ?.firstWhere((i) => i.id == itemId, orElse: () => _emptyItem(itemId));

    final removalService = ref.read(itemRemovalServiceProvider);
    await removalService.removeItem(
      itemId: itemId,
      userId: user.$id,
      reason: reason,
    );

    if (priorItem != null && priorItem.name.isNotEmpty) {
      await ref.read(pantryEventsProvider.notifier).log(
            item: priorItem,
            kind: _eventKindFromReason(reason),
          );
    }

    state = AsyncData(await AppwriteItemRepository(user.$id).getAll());
  }

  Future<void> deleteItem(String id) async {
    final authState = ref.read(authProvider);
    final user = authState.value;

    if (user == null) return;

    final priorItem = state.value
        ?.firstWhere((i) => i.id == id, orElse: () => _emptyItem(id));

    final repo = AppwriteItemRepository(user.$id);
    await repo.delete(id);

    if (priorItem != null && priorItem.name.isNotEmpty) {
      await ref.read(pantryEventsProvider.notifier).log(
            item: priorItem,
            kind: PantryEventKind.deleted,
          );
    }

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

/// Maps an [ItemRemovalReason] to its [PantryEventKind] counterpart.
PantryEventKind _eventKindFromReason(ItemRemovalReason r) {
  switch (r) {
    case ItemRemovalReason.consumed:
      return PantryEventKind.consumed;
    case ItemRemovalReason.thrownAway:
      return PantryEventKind.thrownAway;
    case ItemRemovalReason.deleted:
      return PantryEventKind.deleted;
  }
}

/// Sentinel item used when the prior list snapshot doesn't contain the id.
/// We never log empty-name events, so this just prevents nullable dance
/// at every call site.
FridgeItem _emptyItem(String id) => FridgeItem(
      id: id,
      name: '',
      emoji: '',
      expiryDate: DateTime.now(),
      category: ItemCategory.other,
      addedAt: DateTime.now(),
      ownerId: '',
    );

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
