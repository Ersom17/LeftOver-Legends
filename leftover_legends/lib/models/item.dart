// lib/models/item.dart
// The core data model for a fridge item.
// Both engineers import this — agree on any changes before editing.

enum ItemCategory { dairy, veggies, fruit, protein, grains, other }

enum ExpiryStatus { danger, warn, good }

// TODO #12 – where in the kitchen the item is stored.
// Defaults to fridge; legacy JSON (no `location` key) also loads as fridge.
enum ItemLocation { fridge, pantry }

class FridgeItem {
  final String id;
  final String name;
  final String emoji;
  final DateTime expiryDate;
  final ItemCategory category;
  final DateTime addedAt;
  // TODO #12 – storage location (Fridge / Pantry)
  final ItemLocation location;

  const FridgeItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.expiryDate,
    required this.category,
    required this.addedAt,
    this.location = ItemLocation.fridge,
  });

  // How many days until expiry (can be negative if already expired)
  int get daysLeft =>
      expiryDate.difference(DateTime.now()).inDays;

  // Traffic-light status used by the UI for colours and badges
  ExpiryStatus get status {
    if (daysLeft <= 1) return ExpiryStatus.danger;
    if (daysLeft <= 4) return ExpiryStatus.warn;
    return ExpiryStatus.good;
  }

  // Human-readable category label
  String get categoryLabel {
    switch (category) {
      case ItemCategory.dairy:   return 'Dairy';
      case ItemCategory.veggies: return 'Veggies';
      case ItemCategory.fruit:   return 'Fruit';
      case ItemCategory.protein: return 'Protein';
      case ItemCategory.grains:  return 'Grains';
      case ItemCategory.other:   return 'Other';
    }
  }

  // TODO #12 – human-readable storage location
  String get locationLabel =>
      location == ItemLocation.fridge ? 'Fridge' : 'Pantry';

  // Human-readable expiry label shown in the badge
  String get expiryLabel {
    if (daysLeft < 0)  return 'Expired';
    if (daysLeft == 0) return 'Expires today';
    if (daysLeft == 1) return 'Expires tomorrow';
    return '$daysLeft days left';
  }

  // Serialise to/from JSON for shared_preferences storage
  Map<String, dynamic> toJson() => {
    'id':         id,
    'name':       name,
    'emoji':      emoji,
    'expiryDate': expiryDate.toIso8601String(),
    'category':   category.index,
    'addedAt':    addedAt.toIso8601String(),
    // TODO #12 – persist location index
    'location':   location.index,
  };

  factory FridgeItem.fromJson(Map<String, dynamic> json) => FridgeItem(
    id:         json['id'] as String,
    name:       json['name'] as String,
    emoji:      json['emoji'] as String,
    expiryDate: DateTime.parse(json['expiryDate'] as String),
    category:   ItemCategory.values[json['category'] as int],
    addedAt:    DateTime.parse(json['addedAt'] as String),
    // TODO #12 – legacy items without `location` default to fridge
    location:   ItemLocation.values[json['location'] as int? ?? 0],
  );

  // Returns a copy with updated fields (useful for edit screens)
  FridgeItem copyWith({
    String?       name,
    String?       emoji,
    DateTime?     expiryDate,
    ItemCategory? category,
    ItemLocation? location,
  }) =>
      FridgeItem(
        id:         id,
        name:       name ?? this.name,
        emoji:      emoji ?? this.emoji,
        expiryDate: expiryDate ?? this.expiryDate,
        category:   category ?? this.category,
        addedAt:    addedAt,
        location:   location ?? this.location,
      );
}
