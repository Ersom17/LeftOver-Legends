import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item.dart';
import '../models/scanned_receipt_item.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';

class ReceiptReviewScreen extends ConsumerStatefulWidget {
  final List<ScannedReceiptItem> items;

  const ReceiptReviewScreen({
    super.key,
    required this.items,
  });

  @override
  ConsumerState<ReceiptReviewScreen> createState() =>
      _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends ConsumerState<ReceiptReviewScreen> {
  late List<ScannedReceiptItem> _items;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _items = widget.items;
  }

  Future<void> _pickDate(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _items[index].expiryDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked == null) return;

    setState(() {
      _items[index] = _items[index].copyWith(expiryDate: picked);
    });
  }

  Future<void> _saveSelected() async {
    final user = ref.read(authProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in.')),
      );
      return;
    }

    final selected = _items.where((e) => e.selected && e.name.trim().isNotEmpty);

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one item.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      for (final scanned in selected) {
        final item = FridgeItem(
          id: '',
          name: scanned.name.trim(),
          emoji: scanned.emoji,
          expiryDate: scanned.expiryDate,
          category: scanned.category,
          addedAt: DateTime.now(),
          ownerId: user.$id,
          price: scanned.price,
          unit: scanned.currency,
        );

        await ref.read(itemsProvider.notifier).addItem(item);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${selected.length} item(s) added to fridge.')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving items: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _categoryLabel(ItemCategory category) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review receipt items'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _items[index];

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: item.selected,
                        onChanged: (value) {
                          setState(() {
                            _items[index] =
                                item.copyWith(selected: value ?? true);
                          });
                        },
                      ),
                      Text(item.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: item.name,
                          decoration:
                              const InputDecoration(labelText: 'Item name'),
                          onChanged: (value) {
                            _items[index] = _items[index].copyWith(name: value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<ItemCategory>(
                          value: item.category,
                          decoration:
                              const InputDecoration(labelText: 'Category'),
                          items: ItemCategory.values
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(_categoryLabel(category)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _items[index] =
                                  item.copyWith(category: value);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: item.price?.toString() ?? '',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration:
                              InputDecoration(labelText: 'Price (${item.currency})'),
                          onChanged: (value) {
                            _items[index] = item.copyWith(
                              price: double.tryParse(value),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDate(index),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            '${item.expiryDate.day}/${item.expiryDate.month}/${item.expiryDate.year}',
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.sourceText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'OCR: ${item.sourceText}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Confidence: ${(item.confidence * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _saving ? null : _saveSelected,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add selected items'),
        ),
      ),
    );
  }
}