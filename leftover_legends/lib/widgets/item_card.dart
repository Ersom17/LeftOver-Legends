// lib/widgets/item_card.dart
// Reusable card shown in the fridge list. Engineer 1 owns this.
// Colour-coded left border based on expiry status.

import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemCard extends StatelessWidget {
  final FridgeItem item;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ItemCard({
    super.key,
    required this.item,
    this.onDelete,
    this.onTap,
  });

  Color get _borderColor {
    switch (item.status) {
      case ExpiryStatus.danger: return const Color(0xFFC05050);
      case ExpiryStatus.warn:   return const Color(0xFFE8A838);
      case ExpiryStatus.good:   return const Color(0xFF6BAF7A);
    }
  }

  Color get _badgeBg {
    switch (item.status) {
      case ExpiryStatus.danger: return const Color(0x22C05050);
      case ExpiryStatus.warn:   return const Color(0x22E8A838);
      case ExpiryStatus.good:   return const Color(0x226BAF7A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF232B25),
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: _borderColor, width: 3),
          ),
        ),
        child: Row(
          children: [
            // Emoji icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _borderColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(item.emoji,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),

            // Name + category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Color(0xFFF5EFE0),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.categoryLabel,
                    style: TextStyle(
                      color: _borderColor.withOpacity(0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Expiry badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: _badgeBg,
                border: Border.all(
                    color: _borderColor.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.expiryLabel,
                style: TextStyle(
                  color: _borderColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Delete button
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.chevron_right,
                    color: Color(0xFF3A4540), size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
