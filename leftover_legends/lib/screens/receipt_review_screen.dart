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

  static const _emojiOptions = [
    // Dairy
    '🥛', '🧀', '🥚', '🧈', '🍦',
    // Vegetables
    '🥦', '🥕', '🧅', '🥬', '🌽', '🍅', '🧄', '🥔', '🌶️', '🫑',
    '🥒', '🫛', '🧆', '🥗',
    // Fruit
    '🍎', '🍋', '🫐', '🥑', '🍇', '🍓', '🍑', '🥭', '🍍', '🥝',
    '🍊', '🍌', '🍒', '🫒', '🍈',
    // Protein / Meat
    '🥩', '🍗', '🥓', '🌭', '🍖', '🦐', '🐟', '🦑',
    // Grains / Bread
    '🍞', '🥐', '🥨', '🧇', '🍚', '🍝', '🌮', '🥙', '🫓',
    // Drinks
    '🧃', '🥤', '🍷', '🍺', '☕', '🧋',
    // Condiments / Other
    '🫙', '🍳', '🫕', '🥫', '🧂', '🍯', '🫚', '🥜', '🍽️',
  ];

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
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

  Future<void> _pickEmoji(int index) async {
    final current = _items[index].emoji;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1A1F1C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _EmojiPickerSheet(
        current: current,
        options: _emojiOptions,
      ),
    );
    if (picked == null) return;
    setState(() {
      _items[index] = _items[index].copyWith(emoji: picked);
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

    final selected = _items.where((e) => e.selected && e.name.trim().isNotEmpty).toList();

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
      case ItemCategory.dairy:   return 'Dairy';
      case ItemCategory.veggies: return 'Veggies';
      case ItemCategory.fruit:   return 'Fruit';
      case ItemCategory.protein: return 'Protein';
      case ItemCategory.grains:  return 'Grains';
      case ItemCategory.other:   return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F1C),
        title: const Text(
          'Review receipt items',
          style: TextStyle(color: Color(0xFFF5EFE0), fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF8A9E90)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF232B25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: item.selected
                    ? const Color(0xFF5C9E6E).withOpacity(0.4)
                    : const Color(0xFF2E3830),
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    // Checkbox
                    Checkbox(
                      value: item.selected,
                      activeColor: const Color(0xFF5C9E6E),
                      onChanged: (value) {
                        setState(() {
                          _items[index] = item.copyWith(selected: value ?? true);
                        });
                      },
                    ),

                    // Emoji — tappable to change
                    GestureDetector(
                      onTap: () => _pickEmoji(index),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5C9E6E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF5C9E6E).withOpacity(0.4),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                item.emoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                            // Small edit indicator
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5C9E6E),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 9,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Name field
                    Expanded(
                      child: TextFormField(
                        initialValue: item.name,
                        style: const TextStyle(
                          color: Color(0xFFF5EFE0),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Item name',
                          labelStyle: const TextStyle(
                            color: Color(0xFF8A9E90),
                            fontSize: 11,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1A1F1C),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF2E3830)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF2E3830)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF5C9E6E)),
                          ),
                        ),
                        onChanged: (value) {
                          _items[index] = _items[index].copyWith(name: value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Category + Price row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<ItemCategory>(
                        value: item.category,
                        dropdownColor: const Color(0xFF232B25),
                        style: const TextStyle(color: Color(0xFFF5EFE0), fontSize: 13),
                        decoration: _inputDeco('Category'),
                        items: ItemCategory.values.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(_categoryLabel(c)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _items[index] = item.copyWith(category: value);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        initialValue: item.price?.toString() ?? '',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Color(0xFFF5EFE0), fontSize: 13),
                        decoration: _inputDeco('Price (${item.currency})'),
                        onChanged: (value) {
                          _items[index] = item.copyWith(price: double.tryParse(value));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Expiry date
                GestureDetector(
                  onTap: () => _pickDate(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1F1C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF2E3830)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Color(0xFF8A9E90), size: 14),
                        const SizedBox(width: 8),
                        Text(
                          'Expires: ${item.expiryDate.day}/${item.expiryDate.month}/${item.expiryDate.year}',
                          style: const TextStyle(
                            color: Color(0xFFF5EFE0),
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.edit, color: Color(0xFF5C9E6E), size: 14),
                      ],
                    ),
                  ),
                ),

                if (item.sourceText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'OCR: ${item.sourceText}',
                      style: const TextStyle(
                        color: Color(0xFF4A5550),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _saving ? null : _saveSelected,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF5C9E6E),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  'Add ${_items.where((i) => i.selected).length} item(s) to fridge',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF8A9E90), fontSize: 11),
        filled: true,
        fillColor: const Color(0xFF1A1F1C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2E3830)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2E3830)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF5C9E6E)),
        ),
      );
}

// ─── Emoji picker bottom sheet ────────────────────────────────────────────────

class _EmojiPickerSheet extends StatefulWidget {
  final String current;
  final List<String> options;

  const _EmojiPickerSheet({required this.current, required this.options});

  @override
  State<_EmojiPickerSheet> createState() => _EmojiPickerSheetState();
}

class _EmojiPickerSheetState extends State<_EmojiPickerSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F1C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2E3830),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'PICK AN EMOJI',
            style: TextStyle(
              color: Color(0xFF8A9E90),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: widget.options.length,
              itemBuilder: (context, index) {
                final emoji = widget.options[index];
                final isSelected = emoji == _selected;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selected = emoji);
                    Navigator.of(context).pop(emoji);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF5C9E6E).withOpacity(0.2)
                          : const Color(0xFF232B25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF5C9E6E)
                            : const Color(0xFF2E3830),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
