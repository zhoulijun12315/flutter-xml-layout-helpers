import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  String? getTranslation(String key) {
    final lang = _localizedValues[locale.languageCode];
    if (lang != null) {
      return lang[key];
    }
    return null;
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    "en": {"hello": "Hello from i18n", "goodbye": "Goodbye"},
    "zh": {"hello": "来自 i18n 的问候", "goodbye": "再见"}
  };
}
