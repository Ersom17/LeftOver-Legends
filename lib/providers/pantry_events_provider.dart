// lib/providers/pantry_events_provider.dart
//
// Local SharedPreferences-backed log of pantry events. Used by the Insights
// screen to surface user-behavior patterns ("you tend to let chicken expire",
// total consumed vs thrown, etc).
//
// Each event captures the minimum we need to answer the questions Insights
// asks: when it happened, what the item was, which category it belonged to,
// and what kind of event it was. We deliberately do NOT log price here —
// totalSpent / totalWasted on the user profile already covers the money side.
//
// The log is capped at [_maxEntries] to avoid SharedPreferences blow-up.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/item.dart';

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

class PantryEventsNotifier extends Notifier<List<PantryEvent>> {
  static const _prefKey = 'pantry_event_log';
  static const _maxEntries = 500;

  @override
  List<PantryEvent> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefKey) ?? const [];
      state = raw
          .map((s) => PantryEvent.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to load pantry events: $e');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _prefKey,
        state.map((e) => jsonEncode(e.toJson())).toList(),
      );
    } catch (e) {
      debugPrint('Failed to persist pantry events: $e');
    }
  }

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
    final next = [event, ...state];
    state = next.length > _maxEntries ? next.sublist(0, _maxEntries) : next;
    await _persist();
  }
}

final pantryEventsProvider =
    NotifierProvider<PantryEventsNotifier, List<PantryEvent>>(
        PantryEventsNotifier.new);
