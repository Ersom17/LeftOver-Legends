// lib/widgets/item_card.dart
// Reusable card shown in the fridge list.
// Colour-coded left border based on expiry status (status colors frozen).
// Todo #11 — light surface + soft shadow, navy text.
// Todo #12 — tappable category/location row toggles location.

import 'package:flutter/material.dart';
import '../models/item.dart';
import '../theme/app_theme.dart';

class ItemCard extends StatelessWidget {
  final FridgeItem item;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  // TODO #12 – called when user taps the Category · Location row
  final VoidCallback? onLocationTap;

  const ItemCard({
    super.key,
    required this.item,
    this.onDelete,
    this.onTap,
    this.onLocationTap,
  });

  Color get _borderColor {
    switch (item.status) {
      case ExpiryStatus.danger: return AppTheme.danger;
      case ExpiryStatus.warn:   return AppTheme.warn;
      case ExpiryStatus.good:   return AppTheme.good;
    }
  }

  Color get _badgeBg {
    // Status color at ~13% opacity for the expiry badge background.
    switch (item.status) {
      case ExpiryStatus.danger: return AppTheme.danger.withValues(alpha: 0.13);
      case ExpiryStatus.warn:   return AppTheme.warn.withValues(alpha: 0.13);
      case ExpiryStatus.good:   return AppTheme.good.withValues(alpha: 0.13);
    }
  }

  IconData get _locationIcon =>
      item.location == ItemLocation.fridge
          ? Icons.kitchen
          : Icons.inventory_2;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: _borderColor, width: 3),
          ),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.cardShadow,
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Emoji icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _borderColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(item.emoji,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),

            // Name + category · location row
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      color: AppTheme.primaryOf(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // TODO #12 – tap to toggle between Fridge and Pantry
                  GestureDetector(
                    onTap: onLocationTap,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Text(
                          item.categoryLabel,
                          style: TextStyle(
                            color: _borderColor.withValues(alpha: 0.85),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          ' · ',
                          style: TextStyle(
                            color: AppTheme.secondaryOf(context),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(_locationIcon, color: AppTheme.secondaryOf(context), size: 12),
                        const SizedBox(width: 3),
                        Text(
                          item.locationLabel,
                          style: TextStyle(
                            color: AppTheme.secondaryOf(context),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
                    color: _borderColor.withValues(alpha: 0.5)),
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
                child: Icon(Icons.chevron_right,
                    color: AppTheme.secondaryOf(context), size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
