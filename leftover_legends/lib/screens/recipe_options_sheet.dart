// lib/screens/recipe_options_sheet.dart (Updated)

import 'package:flutter/material.dart';
import '../services/country_config_service.dart';

class RecipeOptions {
  final String culture;

  const RecipeOptions({required this.culture});
}

class RecipeOptionsSheet extends StatefulWidget {
  final String defaultCulture;
  final String defaultCountry;

  const RecipeOptionsSheet({
    super.key,
    this.defaultCulture = 'Italian',
    this.defaultCountry = 'Switzerland',
  });

  @override
  State<RecipeOptionsSheet> createState() => _RecipeOptionsSheetState();
}

class _RecipeOptionsSheetState extends State<RecipeOptionsSheet> {
  late String _selectedCulture;
  late String _selectedCountry;
  bool _useCountryDropdown = false;

  // Get all countries from country config
  late List<String> _countries;

  @override
  void initState() {
    super.initState();
    _selectedCulture = widget.defaultCulture;
    _selectedCountry = widget.defaultCountry;
    _countries = CountryConfigService.countryConfigs.keys.toList()..sort();
  }

  void _updateCultureFromCountry(String country) {
    final culture = CountryConfigService.getCulture(country);
    setState(() {
      _selectedCountry = country;
      _selectedCulture = culture;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F1C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E3830),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recipe options',
                      style: TextStyle(
                        color: Color(0xFFF5EFE0),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Suggested: ${_selectedCulture}',
                      style: const TextStyle(
                        color: Color(0xFF5C9E6E),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Default country quick button
                    _label('Quick select'),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF5C9E6E).withOpacity(0.2),
                          side: const BorderSide(
                            color: Color(0xFF5C9E6E),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          setState(() {
                            _useCountryDropdown = false;
                            _selectedCulture = widget.defaultCulture;
                            _selectedCountry = widget.defaultCountry;
                          });
                        },
                        child: Text(
                          '${widget.defaultCountry} - ${widget.defaultCulture}',
                          style: const TextStyle(
                            color: Color(0xFF5C9E6E),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Cuisine style section (original)
                    if (!_useCountryDropdown) ...[
                      _label('Cuisine style'),
                      const SizedBox(height: 10),
                      _buildCuisineGrid(),
                    ],

                    // Country dropdown section
                    if (_useCountryDropdown) ...[
                      _label('Select country'),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedCountry,
                        dropdownColor: const Color(0xFF232B25),
                        style: const TextStyle(color: Color(0xFFF5EFE0)),
                        decoration: InputDecoration(
                          hintText: 'Select country',
                          hintStyle: const TextStyle(color: Color(0xFF6E7D74)),
                          filled: true,
                          fillColor: const Color(0xFF1A1F1C),
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
                        ),
                        items: _countries.map((country) {
                          return DropdownMenuItem<String>(
                            value: country,
                            child: Text(country),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _updateCultureFromCountry(value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Culture: ${_selectedCulture}',
                        style: const TextStyle(
                          color: Color(0xFF8A9E90),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Toggle button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _useCountryDropdown = !_useCountryDropdown;
                          });
                        },
                        icon: Icon(
                          _useCountryDropdown
                              ? Icons.restaurant_menu
                              : Icons.public,
                        ),
                        label: Text(
                          _useCountryDropdown
                              ? 'Browse cuisines'
                              : 'Browse countries',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF8A9E90),
                          side: const BorderSide(color: Color(0xFF8A9E90)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).pop(
                          RecipeOptions(culture: _selectedCulture),
                        ),
                        icon: const Icon(Icons.restaurant_menu),
                        label: const Text(
                          'Generate recipes',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF5C9E6E),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCuisineGrid() {
    final cultures = [
      ('🇮🇹', 'Italian'),
      ('🇯🇵', 'Japanese'),
      ('🇲🇽', 'Mexican'),
      ('🇮🇳', 'Indian'),
      ('🇨🇳', 'Chinese'),
      ('🇫🇷', 'French'),
      ('🇬🇷', 'Greek'),
      ('🇹🇭', 'Thai'),
      ('🇪🇸', 'Spanish'),
      ('🇱🇧', 'Lebanese'),
      ('🇹🇷', 'Turkish'),
      ('🇰🇷', 'Korean'),
      ('🇻🇳', 'Vietnamese'),
      ('🇲🇦', 'Moroccan'),
      ('🇵🇪', 'Peruvian'),
      ('🇺🇸', 'American'),
      ('🇧🇷', 'Brazilian'),
      ('🇪🇹', 'Ethiopian'),
      ('🇵🇹', 'Portuguese'),
      ('🇩🇪', 'German'),
      ('🇦🇹', 'Austrian'),
      ('🇬🇧', 'British'),
      ('🇸🇪', 'Scandinavian'),
      ('🇨🇭', 'Swiss'),
      ('🇵🇱', 'Polish'),
      ('🇷🇺', 'Russian'),
      ('🇦🇺', 'Australian'),
      ('🇳🇿', 'Pacific'),
      ('🌍', 'Caribbean'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.9,
      ),
      itemCount: cultures.length,
      itemBuilder: (context, index) {
        final (flag, name) = cultures[index];
        final selected = name == _selectedCulture;

        return GestureDetector(
          onTap: () => setState(() => _selectedCulture = name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF5C9E6E).withOpacity(0.15)
                  : const Color(0xFF232B25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? const Color(0xFF5C9E6E)
                    : const Color(0xFF2E3830),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(flag, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFF5C9E6E)
                            : const Color(0xFF8A9E90),
                        fontSize: 11,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _label(String text) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF8A9E90),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      );
}
