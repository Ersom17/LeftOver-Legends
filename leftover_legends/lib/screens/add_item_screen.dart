// lib/screens/add_item_screen.dart
// R2 — Add item manually. Engineer 1 owns this file.
// Submits to itemsProvider which persists via the repository.
// Todo #1 — default emoji is now 📦 (neutral "package").
// Todo #11 — palette swapped to AppTheme light-mode tokens.
// Todo #12 — location picker (Fridge / Pantry).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_strings.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _nameController = TextEditingController();
  ItemCategory _selectedCategory = ItemCategory.other;
  // TODO #12 – default storage location is the fridge
  ItemLocation _selectedLocation = ItemLocation.fridge;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 5));
  // TODO #1 – neutral default emoji (package/box) instead of plate
  String _selectedEmoji = '📦';
  bool _saving = false;

  static const _emojiOptions = [
    '🥛','🧀','🥚','🥦','🍎','🥕','🍳','🧅','🫙','🥩',
    '🍞','🧈','🍋','🥬','🫐','🥑','🍅','🌽','📦',
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
      // TODO #12 – persist selected location
      location:   _selectedLocation,
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
        // TODO #11 – light date picker with navy accent
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary:   AppTheme.navy,
            onPrimary: AppTheme.white,
            surface:   AppTheme.surface,
            onSurface: AppTheme.navy,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bgOf(context),
        foregroundColor: AppTheme.primaryOf(context),
        elevation: 0,
        title: Text(
          AppStrings.of(context, 'addItem'),
          style: TextStyle(
            color: AppTheme.primaryOf(context),
            fontWeight: FontWeight.w900,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppTheme.secondaryOf(context)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            _label('itemName'),
            TextField(
              controller: _nameController,
              style: TextStyle(color: AppTheme.primaryOf(context)),
              decoration: _inputDecoration(context, AppStrings.of(context, 'itemNameHint')),
            ),
            const SizedBox(height: 20),

            // Emoji picker
            _label('pickEmoji'),
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
                          ? AppTheme.orange.withValues(alpha: 0.15)
                          : AppTheme.surfaceOf(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? AppTheme.orange : AppTheme.borderOf(context),
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
            _label('category'),
            DropdownButtonFormField<ItemCategory>(
              initialValue: _selectedCategory,
              dropdownColor: AppTheme.surfaceOf(context),
              style: TextStyle(color: AppTheme.primaryOf(context)),
              decoration: _inputDecoration(context, ''),
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

            // TODO #12 – location picker (Fridge / Pantry)
            _label('storedIn'),
            Builder(builder: (context) => SegmentedButton<ItemLocation>(
              segments: [
                ButtonSegment(
                  value: ItemLocation.fridge,
                  label: Text(AppStrings.of(context, 'fridgeLocation')),
                  icon: const Icon(Icons.kitchen),
                ),
                ButtonSegment(
                  value: ItemLocation.pantry,
                  label: Text(AppStrings.of(context, 'pantry')),
                  icon: const Icon(Icons.inventory_2),
                ),
              ],
              selected: {_selectedLocation},
              onSelectionChanged: (s) =>
                  setState(() => _selectedLocation = s.first),
            )),
            const SizedBox(height: 20),

            // Expiry date picker
            _label('expiryDate'),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceOf(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderOf(context)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: AppTheme.secondaryOf(context), size: 16),
                    const SizedBox(width: 10),
                    Text(
                      '${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}',
                      style: TextStyle(
                          color: AppTheme.primaryOf(context), fontSize: 14),
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
                  backgroundColor: AppTheme.orange,
                  foregroundColor: AppTheme.white,
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
                            strokeWidth: 2, color: AppTheme.white),
                      )
                    : Text(AppStrings.of(context, 'addToFridge'),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // text is an AppStrings key — looked up via context inside the Builder.
  Widget _label(String key) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          AppStrings.of(context, key),
          style: TextStyle(
            color: AppTheme.secondaryOf(context),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.secondaryOf(context)),
        filled: true,
        fillColor: AppTheme.surfaceOf(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.borderOf(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.borderOf(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.orange, width: 1.5),
        ),
      );
}
