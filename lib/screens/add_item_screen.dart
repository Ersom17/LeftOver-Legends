import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../i18n/app_strings.dart';
import '../models/item.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/mascot_tour_provider.dart';
import '../providers/region_provider.dart';
import '../providers/user_settings_provider.dart';
import '../services/country_config_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';
import '../widgets/mascot_tour/mascot_tour_anchors.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  /// When true, fields are prefilled with a demo item so the mascot tour
  /// can walk the user through the confirm-and-save flow in one tap.
  final bool tourMode;

  const AddItemScreen({super.key, this.tourMode = false});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  ItemCategory _selectedCategory = ItemCategory.other;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 5));
  // Emoji is now optional — empty string means "no emoji".
  String _selectedEmoji = '';
  String? _selectedCurrency;
  bool _saving = false;

  late List<String> _currencies;

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
    _buildCurrencyList();

    if (widget.tourMode) {
      _nameController.text = 'Tomatoes';
      _priceController.text = '2.95';
      _selectedCategory = ItemCategory.veggies;
      _selectedEmoji = '🍅';
      _expiryDate = DateTime.now().add(const Duration(days: 5));
    }
  }

  void _buildCurrencyList() {
    const topCurrencies = ['USD', 'EUR', 'GBP', 'JPY', 'CHF', 'CAD', 'AUD', 'CNY', 'INR', 'BRL'];
    final allCurrencies = <String>{};
    for (final config in CountryConfigService.countryConfigs.values) {
      allCurrencies.add(config.currency);
    }
    final topSet = topCurrencies.toSet();
    final others = allCurrencies.where((c) => !topSet.contains(c)).toList()..sort();
    _currencies = [...topCurrencies, ...others];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    if (_priceController.text.trim().isEmpty) return;

    final price = double.tryParse(_priceController.text.trim());
    if (price == null) return;

    final user = ref.read(authProvider).value;
    if (user == null) {
      debugPrint('No logged-in user found');
      return;
    }

    setState(() => _saving = true);

    try {
      final item = FridgeItem(
        id: '',
        name: _nameController.text.trim(),
        // Empty string = no emoji. ItemCard hides the tile when empty.
        emoji: _selectedEmoji,
        expiryDate: _expiryDate,
        category: _selectedCategory,
        addedAt: DateTime.now(),
        ownerId: user.$id,
        price: price,
        unit: _selectedCurrency ?? 'CHF',
      );

      await ref.read(itemsProvider.notifier).addItem(item);

      if (widget.tourMode) {
        ref
            .read(mascotTourProvider.notifier)
            .notifyAction(MascotActions.tapSaveItem);
      }

      if (mounted) {
        final strings = ref.read(appStringsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.itemAddedSuccess)),
        );
        context.pop();
      }
    } catch (e, st) {
      debugPrint('ADD ITEM ERROR: $e');
      debugPrintStack(stackTrace: st);

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
    final defaultCurrency = ref.watch(userCurrencyProvider);
    final region = ref.watch(regionProvider);
    final strings = ref.watch(appStringsProvider);

    if (_selectedCurrency == null) {
      _selectedCurrency = defaultCurrency;
    }

    return Scaffold(
      backgroundColor: AppColors.lightBeige,
      appBar: AppBar(
        title: Text(strings.addItemScreenTitle),
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

            _EmojiExpansion(
              options: _emojiOptions,
              selected: _selectedEmoji,
              onChanged: (value) => setState(() => _selectedEmoji = value),
            ),
            const SizedBox(height: 20),

            _label(strings.categoryLabel),
            DropdownButtonFormField<ItemCategory>(
              value: _selectedCategory,
              items: ItemCategory.values.map((c) {
                return DropdownMenuItem<ItemCategory>(
                  value: c,
                  child: Text(_categoryLabel(c, strings)),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCategory = v);
              },
            ),
            const SizedBox(height: 20),

            _label(strings.expiryDateLabel),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    value: _selectedCurrency,
                    isExpanded: true,
                    items: _currencies.map((c) {
                      return DropdownMenuItem<String>(
                        value: c,
                        child: Text(c),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCurrency = v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              '${strings.defaultCurrencyPrefix}$defaultCurrency',
              style: const TextStyle(
                color: AppColors.softGrayText,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              key: MascotAnchors.keyFor(MascotAnchorIds.addItemSave),
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
                        strings.addToPantry,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
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

/// Wraps the emoji grid in an ExpansionTile so it's hidden by default —
/// the grid is visual sugar and shouldn't push the Save button off-screen.
class _EmojiExpansion extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const _EmojiExpansion({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBackground),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: const Text(
              'EMOJI (OPTIONAL)',
              style: TextStyle(
                color: AppColors.mutedOlive,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                selected.isEmpty ? 'None selected' : selected,
                style: TextStyle(
                  color: selected.isEmpty
                      ? AppColors.softGrayText
                      : AppColors.darkGreen,
                  fontSize: selected.isEmpty ? 13 : 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            iconColor: AppColors.darkGreen,
            collapsedIconColor: AppColors.mutedOlive,
            children: [
              _EmojiPicker(
                options: options,
                selected: selected,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmojiPicker extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const _EmojiPicker({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // "None" option — makes the optional nature explicit.
        _tile(
          isSelected: selected.isEmpty,
          onTap: () => onChanged(''),
          child: const Icon(
            Icons.not_interested,
            color: AppColors.softGrayText,
            size: 20,
          ),
        ),
        ...options.map((e) => _tile(
              isSelected: e == selected,
              onTap: () => onChanged(e),
              child: Text(e, style: const TextStyle(fontSize: 22)),
            )),
      ],
    );
  }

  Widget _tile({
    required bool isSelected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.darkGreen.withOpacity(0.12)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.darkGreen : Colors.transparent,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}
