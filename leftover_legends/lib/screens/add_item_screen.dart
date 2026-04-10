import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/item.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../providers/user_settings_provider.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  ItemCategory _selectedCategory = ItemCategory.other;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 5));
  String _selectedEmoji = '🍽️';
  late String _selectedCurrency;
  bool _saving = false;

  static const _currencies = [
    'CHF', 'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CNY', 'INR', 'BRL',
    'MXN', 'KRW', 'SGD', 'HKD', 'NOK', 'SEK', 'DKK', 'PLN', 'CZK', 'TRY',
  ];

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
    '🥩', '🍗', '🥓', '🌭', '🍖', '🦐', '🐟', '🦑', '🥚',
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
    // Initialize currency after widget is built to access ref
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final defaultCurrency = ref.read(userCurrencyProvider);
      setState(() {
        _selectedCurrency = defaultCurrency;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set default currency when dependencies change
    _selectedCurrency = ref.read(userCurrencyProvider);
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
        emoji: _selectedEmoji,
        expiryDate: _expiryDate,
        category: _selectedCategory,
        addedAt: DateTime.now(),
        ownerId: user.$id,
        price: price,
        unit: _selectedCurrency,
      );

      await ref.read(itemsProvider.notifier).addItem(item);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully')),
        );
        context.pop();
      }
    } catch (e, st) {
      debugPrint('ADD ITEM ERROR: $e');
      debugPrintStack(stackTrace: st);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding item: $e')),
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
    // Get the default currency for this user
    final defaultCurrency = ref.watch(userCurrencyProvider);
    
    // Update selected currency if it's the first build
    if (_selectedCurrency.isEmpty) {
      _selectedCurrency = defaultCurrency;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F1C),
        title: const Text(
          'Add item',
          style: TextStyle(
            color: Color(0xFFF5EFE0),
            fontWeight: FontWeight.w900,
          ),
        ),
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
            // Item name
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
                          ? const Color(0xFF5C9E6E).withOpacity(0.13)
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

            // Category
            _label('Category'),
            DropdownButtonFormField<ItemCategory>(
              value: _selectedCategory,
              dropdownColor: const Color(0xFF232B25),
              style: const TextStyle(color: Color(0xFFF5EFE0)),
              decoration: _inputDecoration(''),
              items: ItemCategory.values.map((c) {
                return DropdownMenuItem<ItemCategory>(
                  value: c,
                  child: Text(_categoryLabel(c)),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCategory = v);
              },
            ),
            const SizedBox(height: 20),

            // Expiry date
            _label('Expiry date'),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            const SizedBox(height: 20),

            // Price + Currency on same line
            _label('Price & Currency'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price field
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    style: const TextStyle(color: Color(0xFFF5EFE0)),
                    decoration: _inputDecoration('e.g. 2.95'),
                  ),
                ),
                const SizedBox(width: 10),
                // Currency dropdown - shows default from country
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    dropdownColor: const Color(0xFF232B25),
                    style: const TextStyle(color: Color(0xFFF5EFE0)),
                    decoration: _inputDecoration(''),
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
            
            // Show default currency info
            Text(
              'Default: $defaultCurrency',
              style: const TextStyle(
                color: Color(0xFF8A9E90),
                fontSize: 12,
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
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Add to fridge',
                        style: TextStyle(
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
          text,
          style: const TextStyle(
            color: Color(0xFF8A9E90),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      );

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
