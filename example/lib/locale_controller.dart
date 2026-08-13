import 'package:flutter/widgets.dart';

/// Tiny app-level locale switcher used by the demo controller.
class LocaleController {
  static final ValueNotifier<Locale> locale =
      ValueNotifier<Locale>(const Locale('en'));

  static void toggle() {
    locale.value = locale.value.languageCode == 'en'
        ? const Locale('zh')
        : const Locale('en');
  }
}
