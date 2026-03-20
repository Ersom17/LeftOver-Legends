// lib/screens/add_item_screen.dart
// R2 — Add item manually. Engineer 1 owns this file.
// Submits to itemsProvider which persists via the repository.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _nameController = TextEditingController();
  ItemCategory _selectedCategory = ItemCategory.other;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 5));
  String _selectedEmoji = '🍽️';
  bool _saving = false;

  static const _emojiOptions = [
    '🥛','🧀','🥚','🥦','🍎','🥕','🍳','🧅','🫙','🥩',
    '🍞','🧈','🍋','🥬','🫐','🥑','🍅','🌽','🍽️',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _saving = true);

    final item = FridgeItem(
      id:         const Uuid().v4(),
      name:       _nameController.text.trim(),
      emoji:      _selectedEmoji,
      expiryDate: _expiryDate,
      category:   _selectedCategory,
      addedAt:    DateTime.now(),
    );

    await ref.read(itemsProvider.notifier).addItem(item);
    if (mounted) context.pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context:     context,
      initialDate: _expiryDate,
      firstDate:   DateTime.now(),
      lastDate:    DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFF5C9E6E)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F1C),
        title: const Text('Add item',
            style: TextStyle(
                color: Color(0xFFF5EFE0), fontWeight: FontWeight.w900)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF8A9E90)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            _label('Item name'),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Color(0xFFF5EFE0)),
              decoration: _inputDecoration('e.g. Whole Milk'),
            ),
            const SizedBox(height: 20),

            // Emoji picker
            _label('Pick an emoji'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojiOptions.map((e) {
                final selected = e == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = e),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF5C9E6E22)
                          : const Color(0xFF232B25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF5C9E6E)
                            : const Color(0xFF2E3830),
                      ),
                    ),
                    child: Center(
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Category picker
            _label('Category'),
            DropdownButtonFormField<ItemCategory>(
              value: _selectedCategory,
              dropdownColor: const Color(0xFF232B25),
              style: const TextStyle(color: Color(0xFFF5EFE0)),
              decoration: _inputDecoration(''),
              items: ItemCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          FridgeItem(
                            id: '', name: '', emoji: '',
                            expiryDate: DateTime.now(),
                            category: c,
                            addedAt: DateTime.now(),
                          ).categoryLabel,
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCategory = v);
              },
            ),
            const SizedBox(height: 20),

            // Expiry date picker
            _label('Expiry date'),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF232B25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2E3830)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Color(0xFF8A9E90), size: 16),
                    const SizedBox(width: 10),
                    Text(
                      '${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}',
                      style: const TextStyle(
                          color: Color(0xFFF5EFE0), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
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
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Add to fridge',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF8A9E90),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF3A4540)),
        filled: true,
        fillColor: const Color(0xFF232B25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E3830)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E3830)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5C9E6E)),
        ),
      );
}
