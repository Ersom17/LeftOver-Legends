// lib/providers/pantry_events_provider.dart
//
// Server-backed pantry event log. Used by the Insights screen to surface
// user-behaviour patterns ("you tend to let chicken expire", total
// consumed vs thrown, etc).
//
// SharedPreferences is kept as a write-through cache: build() returns the
// server snapshot on success, and falls back to the cache when the user
// is offline or signed out. On first run after the migration, if the
// server is empty but the local cache has rows, we upload the cache once
// so existing local-only users don't lose their history.
//
// The log is capped to [readLimit] on the server side via the repository
// query, and to [_localCap] on the local cache to keep prefs small.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/item.dart';
import '../repositories/appwrite_pantry_events_repository.dart';
import 'auth_provider.dart';

enum PantryEventKind {
  /// User added an item to the pantry.
  added,

  /// User marked it as consumed (cooked, eaten, used).
  consumed,

  /// User marked it as thrown away — wasted food.
  thrownAway,

  /// User deleted the item without picking an outcome.
  deleted,
}

class PantryEvent {
  final DateTime timestamp;
  final String name;
  final ItemCategory category;
  final PantryEventKind kind;

  /// Days remaining at the moment of the event. Negative means already
  /// expired. Stored so Insights can tell "consumed before expiring" apart
  /// from "consumed last-minute" etc.
  final int daysLeftAtEvent;

  const PantryEvent({
    required this.timestamp,
    required this.name,
    required this.category,
    required this.kind,
    required this.daysLeftAtEvent,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'name': name,
        'category': category.name,
        'kind': _kindToString(kind),
        'daysLeftAtEvent': daysLeftAtEvent,
      };

  factory PantryEvent.fromJson(Map<String, dynamic> json) {
    return PantryEvent(
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      name: json['name'] as String? ?? '',
      category: _categoryFromName(json['category'] as String?),
      kind: _kindFromString(json['kind'] as String?),
      daysLeftAtEvent: (json['daysLeftAtEvent'] as num?)?.toInt() ?? 0,
    );
  }

  static ItemCategory _categoryFromName(String? value) {
    for (final c in ItemCategory.values) {
      if (c.name == value) return c;
    }
    return ItemCategory.other;
  }
}

PantryEventKind _kindFromString(String? s) {
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

String _kindToString(PantryEventKind k) {
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

class PantryEventsNotifier extends AsyncNotifier<List<PantryEvent>> {
  static const _prefKey = 'pantry_event_log';
  static const _migrationFlag = 'pantry_events_migrated_v1';

  /// Local SharedPreferences cap. The server keeps more rows; this just
  /// bounds the size of the offline fallback so prefs stay snappy.
  static const _localCap = 500;

  @override
  Future<List<PantryEvent>> build() async {
    ref.watch(authProvider);
    final user = ref.read(authProvider).value;
    if (user == null) return _readCache();

    final repo = AppwritePantryEventsRepository(user.$id);
    try {
      final server = await repo.getAll();
      await _maybeMigrate(repo, server);
      final merged = await repo.getAll();
      await _writeCache(merged);
      return merged;
    } catch (e) {
      debugPrint('Pantry events fetch failed, falling back to cache: $e');
      return _readCache();
    }
  }

  Future<void> _maybeMigrate(
    AppwritePantryEventsRepository repo,
    List<PantryEvent> server,
  ) async {
    if (server.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationFlag) ?? false) return;
    final cached = await _readCache();
    if (cached.isEmpty) {
      await prefs.setBool(_migrationFlag, true);
      return;
    }
    // Upload oldest-first so the server's orderDesc(timestamp) reflects the
    // original chronology when readers fetch later.
    for (final e in cached.reversed) {
      try {
        await repo.add(e);
      } catch (err) {
        debugPrint('Migration of event "${e.name}" failed: $err');
      }
    }
    await prefs.setBool(_migrationFlag, true);
  }

  Future<List<PantryEvent>> _readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefKey) ?? const [];
      return raw
          .map((s) =>
              PantryEvent.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to read events cache: $e');
      return const [];
    }
  }

  Future<void> _writeCache(List<PantryEvent> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final capped =
          list.length > _localCap ? list.sublist(0, _localCap) : list;
      await prefs.setStringList(
        _prefKey,
        capped.map((e) => jsonEncode(e.toJson())).toList(),
      );
    } catch (e) {
      debugPrint('Failed to persist events cache: $e');
    }
  }

  /// Append an event to both server and cache. Best-effort: if the server
  /// write fails the cache still records the event so Insights stays
  /// consistent locally; the next successful fetch will reconcile.
  Future<void> log({
    required FridgeItem item,
    required PantryEventKind kind,
  }) async {
    final event = PantryEvent(
      timestamp: DateTime.now(),
      name: item.name,
      category: item.category,
      kind: kind,
      daysLeftAtEvent: item.daysLeft,
    );

    // Optimistic cache + state update.
    final current = state.value ?? const <PantryEvent>[];
    final next = [event, ...current];
    state = AsyncData(next);
    await _writeCache(next);

    final user = ref.read(authProvider).value;
    if (user == null) return; // logged-out users only have local data

    try {
      final repo = AppwritePantryEventsRepository(user.$id);
      await repo.add(event);
    } catch (e) {
      debugPrint('Failed to write event to server: $e');
      // Don't roll back — local fallback still has the event.
    }
  }
}

final pantryEventsProvider =
    AsyncNotifierProvider<PantryEventsNotifier, List<PantryEvent>>(
        PantryEventsNotifier.new);
