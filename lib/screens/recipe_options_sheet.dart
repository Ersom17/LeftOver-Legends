// lib/screens/recipe_options_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../providers/mascot_tour_provider.dart';
import '../services/country_config_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mascot_tour/mascot_tour_anchors.dart';

class RecipeOptions {
  final String culture;

  const RecipeOptions({required this.culture});
}

class RecipeOptionsSheet extends ConsumerStatefulWidget {
  final String defaultCulture;
  final String defaultCountry;

  const RecipeOptionsSheet({
    super.key,
    this.defaultCulture = 'Italian',
    this.defaultCountry = 'Switzerland',
  });

  @override
  ConsumerState<RecipeOptionsSheet> createState() => _RecipeOptionsSheetState();
}

class _RecipeOptionsSheetState extends ConsumerState<RecipeOptionsSheet> {
  late String _selectedCulture;
  late String _selectedCountry;

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
    final strings = ref.watch(appStringsProvider);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightBeige,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.optionsTitle,
                      style: const TextStyle(
                        color: AppColors.darkGreen,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${strings.optionsSuggestedPrefix}$_selectedCulture',
                      style: const TextStyle(
                        color: AppColors.mutedOlive,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _label(strings.optionsYourDefault),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              AppColors.darkGreen.withOpacity(0.12),
                          foregroundColor: AppColors.darkGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: AppColors.darkGreen,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedCulture = widget.defaultCulture;
                            _selectedCountry = widget.defaultCountry;
                          });
                        },
                        child: Text(
                          '${widget.defaultCountry} · ${widget.defaultCulture}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Replaced the cuisine grid + country toggle with a single
                    // dropdown selector — per product direction.
                    _label(strings.optionsPickCountry),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedCountry,
                      isExpanded: true,
                      items: _countries
                          .map((country) => DropdownMenuItem<String>(
                                value: country,
                                child: Text(country),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) _updateCultureFromCountry(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${strings.optionsCuisinePrefix}$_selectedCulture',
                      style: const TextStyle(
                        color: AppColors.softGrayText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      key: MascotAnchors.keyFor(
                          MascotAnchorIds.recipeOptionsConfirm),
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          ref
                              .read(mascotTourProvider.notifier)
                              .notifyAction(
                                  MascotActions.tapConfirmRecipeOptions);
                          Navigator.of(context).pop(
                            RecipeOptions(culture: _selectedCulture),
                          );
                        },
                        icon: const Icon(Icons.restaurant_menu),
                        label: Text(
                          strings.optionsGenerate,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
          color: AppColors.mutedOlive,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      );
}
