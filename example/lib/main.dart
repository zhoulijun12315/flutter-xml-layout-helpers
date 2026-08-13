import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_xml_layout_helpers/headers.dart';
import 'package:provider/provider.dart';

import 'demo/demo_page.xml.dart';
import 'i18n/gen/delegate.dart';
import 'i18n/gen/localizations.dart';
import 'locale_controller.dart';

/// A custom pipe demonstrating how to extend the XML layout pipes.
class TranslatePipe extends Pipe {
  @override
  String get name => 'translate';

  @override
  dynamic transform(BuildContext context, dynamic value, List<dynamic> args) {
    final translation = AppLocalizations.of(context)?.getTranslation(
      value.toString(),
    );
    return translation ?? value.toString();
  }
}

/// A custom pipe with arguments: truncate a string to N characters.
class TruncatePipe extends Pipe {
  @override
  String get name => 'truncate';

  @override
  dynamic transform(BuildContext context, dynamic value, List<dynamic> args) {
    final text = value.toString();
    final maxLength = args.isNotEmpty ? (args.first as num).toInt() : 20;
    return text.length <= maxLength ? text : '${text.substring(0, maxLength)}…';
  }
}

/// A custom pipe that uppercases text (used to demonstrate pipe chaining).
class UppercasePipe extends Pipe {
  @override
  String get name => 'uppercase';

  @override
  dynamic transform(BuildContext context, dynamic value, List<dynamic> args) {
    return value.toString().toUpperCase();
  }
}

void main() {
  runApp(const XmlLayoutDemoApp());
}

class XmlLayoutDemoApp extends StatelessWidget {
  const XmlLayoutDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PipeProvider>.value(
          value: PipeProvider()
            ..register(TranslatePipe())
            ..register(TruncatePipe())
            ..register(UppercasePipe()),
        ),
      ],
      child: ValueListenableBuilder<Locale>(
        valueListenable: LocaleController.locale,
        builder: (context, locale, _) {
          final scheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF5B6CFF),
          );
          return MaterialApp(
            title: 'XML Layout for Flutter Demo',
            locale: locale,
            supportedLocales: const <Locale>[Locale('en'), Locale('zh')],
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: scheme,
              scaffoldBackgroundColor: const Color(0xFFF5F6FC),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF5B6CFF),
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: false,
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              cardTheme: const CardThemeData(
                color: Colors.white,
                elevation: 0,
              ),
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                ),
              ),
            ),
            home: DemoPage(),
          );
        },
      ),
    );
  }
}
