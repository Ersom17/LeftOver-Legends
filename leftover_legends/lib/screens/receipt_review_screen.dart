import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item.dart';
import '../models/scanned_receipt_item.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../providers/user_settings_provider.dart';

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
  late String _receiptCurrency;

  // Top 10 currencies + all others sorted (same list as AddItemScreen)
  static const _topCurrencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'CHF', 'CAD', 'AUD', 'CNY', 'INR', 'BRL'
  ];

  static const _allCurrencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'CHF', 'CAD', 'AUD', 'CNY', 'INR', 'BRL',
    'AED', 'AFN', 'ALL', 'AMD', 'AOA', 'ARS', 'AUD', 'AZN', 'BAM', 'BBD',
    'BDT', 'BGN', 'BHD', 'BIF', 'BMD', 'BND', 'BOB', 'BSD', 'BTN', 'BWP',
    'BYN', 'BZD', 'CDF', 'CLP', 'COP', 'CRC', 'CUP', 'CVE', 'CZK', 'DJF',
    'DKK', 'DOP', 'DZD', 'EGP', 'ERN', 'ETB', 'FJD', 'GEL', 'GHS', 'GMD',
    'GNF', 'GTQ', 'GYD', 'HKD', 'HNL', 'HRK', 'HTG', 'HUF', 'IDR', 'ILS',
    'IQD', 'IRR', 'ISK', 'JMD', 'JOD', 'KES', 'KGS', 'KHR', 'KMF', 'KPW',
    'KRW', 'KWD', 'KZT', 'LAK', 'LBP', 'LKR', 'LRD', 'LSL', 'LYD', 'MAD',
    'MDL', 'MGA', 'MKD', 'MMK', 'MNT', 'MRU', 'MUR', 'MVR', 'MWK', 'MXN',
    'MYR', 'MZN', 'NAD', 'NGN', 'NIO', 'NOK', 'NPR', 'NZD', 'OMR', 'PEN',
    'PGK', 'PHP', 'PKR', 'PLN', 'PYG', 'QAR', 'RON', 'RSD', 'RUB', 'RWF',
    'SAR', 'SBD', 'SCR', 'SDG', 'SEK', 'SGD', 'SLL', 'SOS', 'SRD', 'SSP',
    'SYP', 'SZL', 'THB', 'TJS', 'TMT', 'TND', 'TOP', 'TRY', 'TTD', 'TWD',
    'TZS', 'UAH', 'UGX', 'UYU', 'UZS', 'VES', 'VND', 'VUV', 'WST', 'XAF',
    'XCD', 'XOF', 'YER', 'ZAR', 'ZMW', 'ZWL',
  ];

  @override
  void initState() {
    super.initState();
    _items = widget.items;
    // Default to the user's country currency, set after first frame
    _receiptCurrency = widget.items.isNotEmpty
        ? (widget.items.first.currency)
        : 'CHF';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Override with user's default currency from provider
    final defaultCurrency = ref.read(userCurrencyProvider);
    if (mounted) {
      setState(() {
        _receiptCurrency = defaultCurrency;
      });
    }
  }

  /// Apply the selected currency to all items
  void _applyReceiptCurrency(String currency) {
    setState(() {
      _receiptCurrency = currency;
      _items = _items
          .map((item) => item.copyWith(currency: currency))
          .toList();
    });
  }

  Future<void> _pickDate(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _items[index].expiryDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFF5C9E6E)),
        ),
        child: child!,
      ),
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

    final selected =
        _items.where((e) => e.selected && e.name.trim().isNotEmpty);

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
        SnackBar(
          content: Text('${selected.length} item(s) added to fridge.'),
          backgroundColor: const Color(0xFF3D7A56),
        ),
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
    final selectedCount = _items.where((e) => e.selected).length;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F1C),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF8A9E90)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Review receipt',
          style: TextStyle(
            color: Color(0xFFF5EFE0),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Currency selector banner ──────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF232B25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2E3830)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C9E6E).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFF5C9E6E).withOpacity(0.4)),
                  ),
                  child: const Center(
                    child: Text('💱', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RECEIPT CURRENCY',
                        style: TextStyle(
                          color: Color(0xFF8A9E90),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Applied to all $_selectedCount item${_selectedCount == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: Color(0xFF5C9E6E),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Currency dropdown
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F1C),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFF5C9E6E).withOpacity(0.5)),
                  ),
                  child: DropdownButton<String>(
                    value: _receiptCurrency,
                    dropdownColor: const Color(0xFF232B25),
                    underline: const SizedBox.shrink(),
                    isDense: true,
                    style: const TextStyle(
                      color: Color(0xFF5C9E6E),
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Color(0xFF5C9E6E), size: 18),
                    items: _allCurrencies
                      .toSet()
                      .map((currency) => DropdownMenuItem<String>(
                            value: currency,
                            child: Text(currency),
                          ))
                      .toList()
                      ..removeWhere((c) => _topCurrencies.contains(c))
                      ..insertAll(
                        0,
                        _topCurrencies.map(
                          (c) => DropdownMenuItem<String>(
                            value: c,
                            child: Text(c),
                          ),
                        ),
                      ),
                    onChanged: (value) {
                      if (value != null) _applyReceiptCurrency(value);
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Items list ────────────────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _items[index];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: item.selected
                        ? const Color(0xFF232B25)
                        : const Color(0xFF1E2420),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: item.selected
                          ? const Color(0xFF2E3830)
                          : const Color(0xFF1E2420),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Row 1: checkbox + emoji + name
                        Row(
                          children: [
                            Transform.scale(
                              scale: 1.1,
                              child: Checkbox(
                                value: item.selected,
                                activeColor: const Color(0xFF5C9E6E),
                                checkColor: Colors.white,
                                side: const BorderSide(
                                    color: Color(0xFF3A4540), width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                onChanged: (value) {
                                  setState(() {
                                    _items[index] =
                                        item.copyWith(selected: value ?? true);
                                  });
                                },
                              ),
                            ),
                            Text(item.emoji,
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                initialValue: item.name,
                                style: TextStyle(
                                  color: item.selected
                                      ? const Color(0xFFF5EFE0)
                                      : const Color(0xFF4A5550),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Item name',
                                  labelStyle: const TextStyle(
                                      color: Color(0xFF6E7D74), fontSize: 12),
                                  filled: true,
                                  fillColor: const Color(0xFF1A1F1C),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF2E3830)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF2E3830)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF5C9E6E)),
                                  ),
                                ),
                                onChanged: (value) {
                                  _items[index] =
                                      _items[index].copyWith(name: value);
                                },
                              ),
                            ),
                          ],
                        ),
                        if (item.selected) ...[
                          const SizedBox(height: 10),
                          // Row 2: category + price (currency shown from receipt level)
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<ItemCategory>(
                                  value: item.category,
                                  dropdownColor: const Color(0xFF232B25),
                                  style: const TextStyle(
                                      color: Color(0xFFF5EFE0), fontSize: 13),
                                  isDense: true,
                                  decoration: InputDecoration(
                                    labelText: 'Category',
                                    labelStyle: const TextStyle(
                                        color: Color(0xFF6E7D74), fontSize: 11),
                                    filled: true,
                                    fillColor: const Color(0xFF1A1F1C),
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF2E3830)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF2E3830)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF5C9E6E)),
                                    ),
                                  ),
                                  items: ItemCategory.values
                                      .map(
                                        (category) => DropdownMenuItem(
                                          value: category,
                                          child:
                                              Text(_categoryLabel(category)),
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
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  initialValue: item.price?.toString() ?? '',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  style: const TextStyle(
                                      color: Color(0xFFF5EFE0), fontSize: 13),
                                  decoration: InputDecoration(
                                    labelText: 'Price ($_receiptCurrency)',
                                    labelStyle: const TextStyle(
                                        color: Color(0xFF6E7D74), fontSize: 11),
                                    filled: true,
                                    fillColor: const Color(0xFF1A1F1C),
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF2E3830)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF2E3830)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF5C9E6E)),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _items[index] = item.copyWith(
                                        price: double.tryParse(value));
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Row 3: expiry date picker
                          OutlinedButton.icon(
                            onPressed: () => _pickDate(index),
                            icon: const Icon(Icons.calendar_today,
                                size: 14, color: Color(0xFF8A9E90)),
                            label: Text(
                              '${item.expiryDate.day}/${item.expiryDate.month}/${item.expiryDate.year}',
                              style: const TextStyle(
                                  color: Color(0xFFF5EFE0), fontSize: 13),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF2E3830)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                          if (item.sourceText.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'OCR: ${item.sourceText}',
                                style: const TextStyle(
                                    color: Color(0xFF4A5550), fontSize: 10),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: FilledButton(
          onPressed: _saving ? null : _saveSelected,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF5C9E6E),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  'Add $selectedCount item${selectedCount == 1 ? '' : 's'} to fridge',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800),
                ),
        ),
      ),
    );
  }

  int get _selectedCount => _items.where((e) => e.selected).length;
}
