enum ItemCategory { dairy, veggies, fruit, protein, grains, other }

enum ExpiryStatus { danger, warn, good }

class FridgeItem {
  final String id;
  final String name;
  final String emoji;
  final DateTime expiryDate;
  final ItemCategory category;
  final DateTime addedAt;
  final String ownerId;
  final double? price;
  final String? unit;

  const FridgeItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.expiryDate,
    required this.category,
    required this.addedAt,
    required this.ownerId,
    this.price,
    this.unit,
  });

  int get daysLeft => expiryDate.difference(DateTime.now()).inDays;

  ExpiryStatus get status {
    if (daysLeft <= 1) return ExpiryStatus.danger;
    if (daysLeft <= 4) return ExpiryStatus.warn;
    return ExpiryStatus.good;
  }

  String get categoryLabel {
    switch (category) {
      case ItemCategory.dairy:
        return 'Dairy';
      case ItemCategory.veggies:
        return 'Veggies';
      case ItemCategory.fruit:
        return 'Fruit';
      case ItemCategory.protein:
        return 'Protein';
      case ItemCategory.grains:
        return 'Grains';
      case ItemCategory.other:
        return 'Other';
    }
  }

  String get expiryLabel {
    if (daysLeft < 0) return 'Expired';
    if (daysLeft == 0) return 'Expires today';
    if (daysLeft == 1) return 'Expires tomorrow';
    return '$daysLeft days left';
  }

  Map<String, dynamic> toAppwriteMap() => {
        'name': name,
        'emoji': emoji,
        'expirationDate': expiryDate.toIso8601String(),
        'category': category.name,
        'ownerId': ownerId,
        'price': price,
        'unit': unit,
      };

  factory FridgeItem.fromAppwrite(Map<String, dynamic> json) {
    return FridgeItem(
      id: json[r'$id'] as String,
      name: json['name'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🍽️',
      expiryDate: DateTime.parse(json['expirationDate'] as String),
      category: _categoryFromString(json['category'] as String?),
      addedAt: DateTime.parse(
        json[r'$createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      ownerId: json['ownerId'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
    );
  }

  static ItemCategory _categoryFromString(String? value) {
    switch (value) {
      case 'dairy':
        return ItemCategory.dairy;
      case 'veggies':
        return ItemCategory.veggies;
      case 'fruit':
        return ItemCategory.fruit;
      case 'protein':
        return ItemCategory.protein;
      case 'grains':
        return ItemCategory.grains;
      default:
        return ItemCategory.other;
    }
  }

  FridgeItem copyWith({
    String? name,
    String? emoji,
    DateTime? expiryDate,
    ItemCategory? category,
    DateTime? addedAt,
    String? ownerId,
    double? price,
    String? unit,
  }) {
    return FridgeItem(
      id: id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      expiryDate: expiryDate ?? this.expiryDate,
      category: category ?? this.category,
      addedAt: addedAt ?? this.addedAt,
      ownerId: ownerId ?? this.ownerId,
      price: price ?? this.price,
      unit: unit ?? this.unit,
    );
  }
}