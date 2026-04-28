import 'item.dart';

class ScannedReceiptItem {
  final String name;
  final ItemCategory category;
  final String emoji;
  final DateTime expiryDate;
  final double? price;
  final String currency;
  final String? quantity;
  final double confidence;
  final String sourceText;
  final bool selected;

  const ScannedReceiptItem({
    required this.name,
    required this.category,
    required this.emoji,
    required this.expiryDate,
    required this.price,
    required this.currency,
    required this.quantity,
    required this.confidence,
    required this.sourceText,
    this.selected = true,
  });

  factory ScannedReceiptItem.fromJson(Map<String, dynamic> json) {
    return ScannedReceiptItem(
      name: (json['name'] ?? '').toString(),
      category: _categoryFromString(json['category']?.toString()),
      emoji: (json['emoji'] ?? '🍽️').toString(),
      expiryDate: DateTime.tryParse(
            (json['estimatedExpirationDate'] ?? '').toString(),
          ) ??
          DateTime.now().add(const Duration(days: 5)),
      price: (json['price'] as num?)?.toDouble(),
      currency: (json['currency'] ?? 'CHF').toString(),
      quantity: json['quantity']?.toString(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      sourceText: (json['sourceText'] ?? '').toString(),
    );
  }

  ScannedReceiptItem copyWith({
    String? name,
    ItemCategory? category,
    String? emoji,
    DateTime? expiryDate,
    double? price,
    String? currency,
    String? quantity,
    double? confidence,
    String? sourceText,
    bool? selected,
  }) {
    return ScannedReceiptItem(
      name: name ?? this.name,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      expiryDate: expiryDate ?? this.expiryDate,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      quantity: quantity ?? this.quantity,
      confidence: confidence ?? this.confidence,
      sourceText: sourceText ?? this.sourceText,
      selected: selected ?? this.selected,
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
}