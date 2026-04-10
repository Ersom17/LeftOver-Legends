// lib/providers/user_settings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/country_config_service.dart';

// Provider to store the logged-in user's country
final userCountryProvider = StateProvider<String>((ref) => 'Switzerland');

// Derived provider that gets currency based on country
final userCurrencyProvider = Provider<String>((ref) {
  final country = ref.watch(userCountryProvider);
  return CountryConfigService.getCurrency(country);
});

// Derived provider that gets default culture based on country
final userDefaultCultureProvider = Provider<String>((ref) {
  final country = ref.watch(userCountryProvider);
  return CountryConfigService.getCulture(country);
});

// Derived provider that gets the full config
final userConfigProvider = Provider<CountryConfig>((ref) {
  final country = ref.watch(userCountryProvider);
  return CountryConfigService.getConfig(country);
});
