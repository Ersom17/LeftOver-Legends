// lib/screens/recipe_options_sheet.dart
//
// A modal bottom sheet where the user configures recipe generation options
// (cuisine culture, number of recipes in the future, etc.)
// Returns a RecipeOptions object when the user taps Generate.

import 'package:flutter/material.dart';

class RecipeOptions {
  final String culture;

  const RecipeOptions({required this.culture});
}

class RecipeOptionsSheet extends StatefulWidget {
  const RecipeOptionsSheet({super.key});

  @override
  State<RecipeOptionsSheet> createState() => _RecipeOptionsSheetState();
}

class _RecipeOptionsSheetState extends State<RecipeOptionsSheet> {
  static const _cultures = [
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
  ];

  String _selectedCulture = 'Italian';

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
            // Drag handle — outside scroll area so always visible
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
                    const Text(
                      'Customize your recipe generation',
                      style: TextStyle(color: Color(0xFF8A9E90), fontSize: 13),
                    ),
                    const SizedBox(height: 24),

                    _label('Cuisine style'),
                    const SizedBox(height: 10),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.9,
                      ),
                      itemCount: _cultures.length,
                      itemBuilder: (context, index) {
                        final (flag, name) = _cultures[index];
                        final selected = name == _selectedCulture;

                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCulture = name),
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
                                  Text(flag,
                                      style:
                                          const TextStyle(fontSize: 14)),
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
                    ),

                    const SizedBox(height: 28),

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
