// lib/screens/edit_item_screen.dart
//
// Edit an existing pantry item (name, quantity/price, expiry, category, emoji)
// without requiring a delete + re-add. Emoji selection is optional.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../i18n/app_strings.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/region_provider.dart';
import '../providers/user_settings_provider.dart';
import '../services/country_config_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';

class EditItemScreen extends ConsumerStatefulWidget {
  final FridgeItem item;

  const EditItemScreen({super.key, required this.item});

  @override
  ConsumerState<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends ConsumerState<EditItemScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;

  late ItemCategory _selectedCategory;
  late DateTime _expiryDate;
  late String _selectedEmoji;
  String? _selectedCurrency;
  bool _saving = false;

  late List<String> _currencies;

  static const _emojiOptions = [
    '⬜',
    '🥛', '🧀', '🥚', '🧈', '🍦',
    '🥦', '🥕', '🧅', '🥬', '🌽', '🍅', '🧄', '🥔', '🌶️', '🫑',
    '🥒', '🫛', '🧆', '🥗',
    '🍎', '🍋', '🫐', '🥑', '🍇', '🍓', '🍑', '🥭', '🍍', '🥝',
    '🍊', '🍌', '🍒', '🫒', '🍈',
    '🥩', '🍗', '🥓', '🌭', '🍖', '🦐', '🐟', '🦑',
    '🍞', '🥐', '🥨', '🧇', '🍚', '🍝', '🌮', '🥙', '🫓',
    '🧃', '🥤', '🍷', '🍺', '☕', '🧋',
    '🫙', '🍳', '🫕', '🥫', '🧂', '🍯', '🫚', '🥜', '🍽️',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _priceController =
        TextEditingController(text: widget.item.price?.toString() ?? '');
    _selectedCategory = widget.item.category;
    _expiryDate = widget.item.expiryDate;
    _selectedEmoji = widget.item.emoji;
    _selectedCurrency = widget.item.unit;
    _buildCurrencyList();
  }

  void _buildCurrencyList() {
    const top = ['USD', 'EUR', 'GBP', 'JPY', 'CHF', 'CAD', 'AUD', 'CNY', 'INR', 'BRL'];
    final all = <String>{};
    for (final c in CountryConfigService.countryConfigs.values) {
      all.add(c.currency);
    }
    final topSet = top.toSet();
    final others = all.where((c) => !topSet.contains(c)).toList()..sort();
    _currencies = [...top, ...others];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;

    final priceStr = _priceController.text.trim();
    final price = priceStr.isEmpty ? widget.item.price : double.tryParse(priceStr);

    setState(() => _saving = true);

    try {
      final updated = widget.item.copyWith(
        name: _nameController.text.trim(),
        emoji: _selectedEmoji,
        expiryDate: _expiryDate,
        category: _selectedCategory,
        price: price,
        unit: _selectedCurrency ?? widget.item.unit,
      );

      await ref.read(itemsProvider.notifier).updateItem(updated);

      if (mounted) {
        final strings = ref.read(appStringsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.itemUpdatedSuccess)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        final strings = ref.read(appStringsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${strings.itemAddError}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final region = ref.watch(regionProvider);
    final defaultCurrency = ref.watch(userCurrencyProvider);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBeige,
      appBar: AppBar(
        title: Text(strings.editItemScreenTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(strings.itemNameLabel),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: strings.itemNameHint),
            ),
            const SizedBox(height: 20),

            _label(strings.emojiLabelUpper),
            const SizedBox(height: 10),
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
                          ? AppColors.darkGreen.withOpacity(0.12)
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.darkGreen
                            : Colors.transparent,
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

            _label(strings.categoryLabel),
            DropdownButtonFormField<ItemCategory>(
              value: _selectedCategory,
              items: ItemCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(_categoryLabel(c, strings)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCategory = v);
              },
            ),
            const SizedBox(height: 20),

            _label(strings.expiryDateLabel),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBackground),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: AppColors.darkGreen, size: 16),
                    const SizedBox(width: 10),
                    Text(
                      formatDate(_expiryDate, region),
                      style: const TextStyle(
                          color: AppColors.darkGreen, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _label(strings.priceAndCurrencyLabel),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(hintText: strings.priceHint),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedCurrency ?? defaultCurrency,
                    isExpanded: true,
                    items: _currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCurrency = v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        strings.saveChanges,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
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
          text.toUpperCase(),
          style: const TextStyle(
            color: AppColors.mutedOlive,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      );

  String _categoryLabel(ItemCategory category, AppStrings s) {
    switch (category) {
      case ItemCategory.dairy:   return s.categoryDairy;
      case ItemCategory.veggies: return s.categoryVeggies;
      case ItemCategory.fruit:   return s.categoryFruit;
      case ItemCategory.protein: return s.categoryProtein;
      case ItemCategory.grains:  return s.categoryGrains;
      case ItemCategory.other:   return s.categoryOther;
    }
  }
}
