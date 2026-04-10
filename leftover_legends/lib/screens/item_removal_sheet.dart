import 'package:flutter/material.dart';
import '../services/item_removal_service.dart';

class ItemRemovalSheet extends StatelessWidget {
  final String itemName;
  final String itemEmoji;
  final VoidCallback onThrownAway;
  final VoidCallback onConsumed;
  final VoidCallback onDeleted;

  const ItemRemovalSheet({
    super.key,
    required this.itemName,
    required this.itemEmoji,
    required this.onThrownAway,
    required this.onConsumed,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F1C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E3830),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Item preview
              Row(
                children: [
                  Text(itemEmoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'What happened to this item?',
                          style: TextStyle(
                            color: Color(0xFFF5EFE0),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          itemName,
                          style: const TextStyle(
                            color: Color(0xFF8A9E90),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Options
              _RemovalOption(
                emoji: '🗑️',
                title: 'Thrown away',
                subtitle: 'It went to waste',
                color: const Color(0xFFC05050),
                onTap: () {
                  Navigator.pop(context);
                  onThrownAway();
                },
              ),
              const SizedBox(height: 12),

              _RemovalOption(
                emoji: '😋',
                title: 'Consumed',
                subtitle: 'You ate it',
                color: const Color(0xFF6BAF7A),
                onTap: () {
                  Navigator.pop(context);
                  onConsumed();
                },
              ),
              const SizedBox(height: 12),

              _RemovalOption(
                emoji: '❌',
                title: 'Delete',
                subtitle: 'Remove from fridge',
                color: const Color(0xFF8A9E90),
                onTap: () {
                  Navigator.pop(context);
                  onDeleted();
                },
              ),
              const SizedBox(height: 12),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8A9E90),
                    side: const BorderSide(color: Color(0xFF2E3830)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RemovalOption extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RemovalOption({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: color.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: color.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
