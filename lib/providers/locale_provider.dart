// lib/providers/locale_provider.dart
//
// App-wide language selection. Defaults to Italian when the user's region is
// Europe (our primary market) and English otherwise; they can flip the value
// in Profile → Language. Persisted in SharedPreferences under `app_language`.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../i18n/app_strings.dart';
import 'region_provider.dart';

enum AppLanguage { en, it }

AppLanguage appLanguageFromString(String? value) {
  switch (value) {
    case 'en':
      return AppLanguage.en;
    case 'it':
      return AppLanguage.it;
    default:
      return AppLanguage.en;
  }
}

String appLanguageToString(AppLanguage lang) =>
    lang == AppLanguage.en ? 'en' : 'it';

String appLanguageLabel(AppLanguage lang) =>
    lang == AppLanguage.en ? 'English' : 'Italiano';

class LocaleNotifier extends Notifier<AppLanguage> {
  static const _prefKey = 'app_language';

  @override
  AppLanguage build() {
    _load();
    // Initial default: Italian for Europe, English for US. The async
    // [_load] will overwrite this if the user has already picked a value.
    final region = ref.read(regionProvider);
    return region == AppRegion.europe ? AppLanguage.it : AppLanguage.en;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKey);
    if (stored != null) {
      state = appLanguageFromString(stored);
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, appLanguageToString(lang));
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, AppLanguage>(LocaleNotifier.new);

/// Derived: returns the AppStrings bundle for the active language so widgets
/// can `ref.watch(appStringsProvider).fridgeTitle` without thinking about
/// which enum value is live.
final appStringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(localeProvider);
  return AppStrings.of(lang);
});
