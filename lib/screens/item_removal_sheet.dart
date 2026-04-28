import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../providers/pantry_events_provider.dart';
import '../repositories/appwrite_item_repository.dart';

class ItemRemovalSheet extends ConsumerStatefulWidget {
  final FridgeItem item;
  final VoidCallback onThrowAway;
  final VoidCallback onConsumed;
  final VoidCallback onDelete;

  const ItemRemovalSheet({
    super.key,
    required this.item,
    required this.onThrowAway,
    required this.onConsumed,
    required this.onDelete,
  });

  @override
  ConsumerState<ItemRemovalSheet> createState() => _ItemRemovalSheetState();
}

class _ItemRemovalSheetState extends ConsumerState<ItemRemovalSheet> {
  bool _processing = false;

  Future<void> _handleThrowAway() async {
    setState(() => _processing = true);
    try {
      final repo = AppwriteItemRepository(widget.item.ownerId);
      await repo.markAsWaste(widget.item);
      await ref.read(pantryEventsProvider.notifier).log(
            item: widget.item,
            kind: PantryEventKind.thrownAway,
          );

      if (mounted) {
        Navigator.pop(context);
        widget.onThrowAway();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _handleConsumed() async {
    setState(() => _processing = true);
    try {
      final repo = AppwriteItemRepository(widget.item.ownerId);
      await repo.markAsConsumed(widget.item);
      await ref.read(pantryEventsProvider.notifier).log(
            item: widget.item,
            kind: PantryEventKind.consumed,
          );

      if (mounted) {
        Navigator.pop(context);
        widget.onConsumed();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _handleDelete() async {
    setState(() => _processing = true);
    try {
      final repo = AppwriteItemRepository(widget.item.ownerId);
      await repo.delete(widget.item.id);
      await ref.read(pantryEventsProvider.notifier).log(
            item: widget.item,
            kind: PantryEventKind.deleted,
          );

      if (mounted) {
        Navigator.pop(context);
        widget.onDelete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F1C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      widget.item.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'What happened to this item?',
                            style: TextStyle(
                              color: Color(0xFFF5EFE0),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            widget.item.name,
                            style: const TextStyle(
                              color: Color(0xFF8A9E90),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Thrown away option
                _actionButton(
                  icon: '🗑️',
                  title: 'Thrown away',
                  subtitle: 'It went to waste',
                  borderColor: const Color(0xFFC05050),
                  onTap: _processing ? null : _handleThrowAway,
                ),
                const SizedBox(height: 12),

                // Consumed option
                _actionButton(
                  icon: '😋',
                  title: 'Consumed',
                  subtitle: 'You ate it',
                  borderColor: const Color(0xFF6BAF7A),
                  onTap: _processing ? null : _handleConsumed,
                ),
                const SizedBox(height: 12),

                // Delete option
                _actionButton(
                  icon: '❌',
                  title: 'Delete',
                  subtitle: 'Remove from fridge',
                  borderColor: const Color(0xFF2E3830),
                  onTap: _processing ? null : _handleDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required String icon,
    required String title,
    required String subtitle,
    required Color borderColor,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF232B25),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor.withOpacity(0.5), width: 1.5),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: borderColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: borderColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (_processing)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(borderColor),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: borderColor.withOpacity(0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
