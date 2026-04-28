// lib/widgets/item_card.dart
//
// Reusable card shown in the pantry list. Colour-coded left border based on
// expiry status. Tapping opens the edit flow (name, quantity, expiry date);
// the trash icon keeps the existing delete / consumed flow.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../providers/region_provider.dart';
import '../screens/item_removal_sheet.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';

class ItemCard extends ConsumerWidget {
  final FridgeItem item;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const ItemCard({
    super.key,
    required this.item,
    this.onDelete,
    this.onTap,
    this.onEdit,
  });

  Color get _borderColor {
    switch (item.status) {
      case ExpiryStatus.danger: return AppColors.danger;
      case ExpiryStatus.warn:   return AppColors.warn;
      case ExpiryStatus.good:   return AppColors.good;
    }
  }

  Color get _badgeBg {
    switch (item.status) {
      case ExpiryStatus.danger: return AppColors.danger.withOpacity(0.13);
      case ExpiryStatus.warn:   return AppColors.warn.withOpacity(0.13);
      case ExpiryStatus.good:   return AppColors.good.withOpacity(0.13);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final region = ref.watch(regionProvider);
    final hasEmoji = item.emoji.trim().isNotEmpty && item.emoji != '⬜';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: _borderColor, width: 3),
          ),
        ),
        child: Row(
          children: [
            if (hasEmoji) ...[
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
            ],

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: AppColors.darkGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        item.categoryLabel,
                        style: TextStyle(
                          color: _borderColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '· ${formatDate(item.expiryDate, region)}',
                        style: const TextStyle(
                          color: AppColors.softGrayText,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

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
            const SizedBox(width: 4),

            if (onEdit != null) ...[
              GestureDetector(
                onTap: onEdit,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.edit_outlined,
                      color: AppColors.softGrayText, size: 18),
                ),
              ),
            ],

            if (onDelete != null)
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => ItemRemovalSheet(
                      item: item,
                      onThrowAway: () {
                        ref.read(itemsProvider.notifier).refreshItems();
                      },
                      onConsumed: () {
                        ref.read(itemsProvider.notifier).refreshItems();
                      },
                      onDelete: () {
                        ref.read(itemsProvider.notifier).refreshItems();
                      },
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.delete_outline,
                      color: AppColors.softGrayText, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
