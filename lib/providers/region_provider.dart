// lib/providers/region_provider.dart
//
// Region drives:
//   - date format (MM/DD/YYYY for US, DD/MM/YYYY for EU)
//   - currency & units (handled elsewhere via country config)
//   - the app language default (us → English, europe → Italian)
//
// On first launch (no stored pref) we infer the region from the platform
// locale: a US country code maps to us, everything else falls back to europe.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppRegion { us, europe }

AppRegion regionFromString(String? value) {
  switch (value) {
    case 'us':
      return AppRegion.us;
    case 'europe':
    case 'eu':
      return AppRegion.europe;
    default:
      return AppRegion.europe;
  }
}

String regionToString(AppRegion region) {
  switch (region) {
    case AppRegion.us:
      return 'us';
    case AppRegion.europe:
      return 'europe';
  }
}

String regionLabel(AppRegion region) {
  switch (region) {
    case AppRegion.us:
      return 'United States';
    case AppRegion.europe:
      return 'Switzerland / Europe';
  }
}

class RegionNotifier extends Notifier<AppRegion> {
  static const _prefKey = 'app_region';

  @override
  AppRegion build() {
    _load();
    return _regionFromPlatformLocale();
  }

  static AppRegion _regionFromPlatformLocale() {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    if (locale.countryCode?.toUpperCase() == 'US') return AppRegion.us;
    return AppRegion.europe;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKey);
    if (stored != null) {
      state = regionFromString(stored);
    } else {
      // Persist the locale-derived default so it remains stable across
      // launches even if the user's browser locale flips later.
      await prefs.setString(_prefKey, regionToString(state));
    }
  }

  Future<void> setRegion(AppRegion region) async {
    state = region;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, regionToString(region));
  }

  /// Sync the region from the user's selected country. Anything in the
  /// "Americas → United States" bucket maps to [AppRegion.us]; everything
  /// else is treated as Europe-style (DD/MM dates, metric units, EUR-class
  /// stores).
  Future<void> setRegionFromCountry(String country) async {
    final next = _regionFromCountry(country);
    if (next != state) {
      await setRegion(next);
    }
  }

  static AppRegion _regionFromCountry(String country) {
    // Only the US uses MM/DD/YYYY by default. Canada, UK, AU and the rest
    // are closer to the European DD/MM/YYYY pattern, so they fall into
    // [AppRegion.europe] for formatting purposes.
    if (country == 'United States') return AppRegion.us;
    return AppRegion.europe;
  }
}

final regionProvider =
    NotifierProvider<RegionNotifier, AppRegion>(RegionNotifier.new);
