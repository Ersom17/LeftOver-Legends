// lib/repositories/appwrite_pantry_events_repository.dart
//
// Per-user log of pantry events that powers Insights. Each event is a
// fire-and-forget record: we never update or delete events from the app,
// only add and read them back.
//
// Reads are bounded by [readLimit] so a long-tenured user doesn't crush
// the Insights screen on cold launch. The server-side index is
// (ownerId, timestamp DESC), so this is a cheap query.

import 'package:appwrite/appwrite.dart';

import '../appwrite/appwrite_client.dart';
import '../appwrite/appwrite_constants.dart';
import '../models/item.dart';
import '../providers/pantry_events_provider.dart' show PantryEvent, PantryEventKind;

class AppwritePantryEventsRepository {
  final String ownerId;
  static const int readLimit = 500;

  AppwritePantryEventsRepository(this.ownerId);

  Future<List<PantryEvent>> getAll() async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.pantryEventsTableId,
      queries: [
        Query.equal('ownerId', ownerId),
        Query.orderDesc('timestamp'),
        Query.limit(readLimit),
      ],
    );
    return result.documents.map(_fromDoc).toList();
  }

  Future<void> add(PantryEvent event) async {
    await databases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.pantryEventsTableId,
      documentId: ID.unique(),
      data: {
        'ownerId': ownerId,
        'timestamp': event.timestamp.toIso8601String(),
        'name': event.name,
        'category': event.category.name,
        'kind': _kindToString(event.kind),
        'daysLeftAtEvent': event.daysLeftAtEvent,
      },
      permissions: [
        Permission.read(Role.user(ownerId)),
        Permission.update(Role.user(ownerId)),
        Permission.delete(Role.user(ownerId)),
      ],
    );
  }

  PantryEvent _fromDoc(dynamic doc) {
    final data = Map<String, dynamic>.from(doc.data);
    return PantryEvent(
      timestamp: DateTime.tryParse(data['timestamp'] as String? ?? '') ??
          DateTime.now(),
      name: data['name'] as String? ?? '',
      category: _categoryFromName(data['category'] as String?),
      kind: _kindFromString(data['kind'] as String?),
      daysLeftAtEvent: (data['daysLeftAtEvent'] as num?)?.toInt() ?? 0,
    );
  }

  static ItemCategory _categoryFromName(String? value) {
    for (final c in ItemCategory.values) {
      if (c.name == value) return c;
    }
    return ItemCategory.other;
  }

  static PantryEventKind _kindFromString(String? s) {
    switch (s) {
      case 'added':
        return PantryEventKind.added;
      case 'consumed':
        return PantryEventKind.consumed;
      case 'thrownAway':
        return PantryEventKind.thrownAway;
      default:
        return PantryEventKind.deleted;
    }
  }

  static String _kindToString(PantryEventKind k) {
    switch (k) {
      case PantryEventKind.added:
        return 'added';
      case PantryEventKind.consumed:
        return 'consumed';
      case PantryEventKind.thrownAway:
        return 'thrownAway';
      case PantryEventKind.deleted:
        return 'deleted';
    }
  }
}
