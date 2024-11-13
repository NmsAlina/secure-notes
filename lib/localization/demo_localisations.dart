import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DemoLocalization{
  final Locale locale;

  DemoLocalization(this.locale);

 static DemoLocalization of(BuildContext context) {
    return Localizations.of<DemoLocalization>(context, DemoLocalization)!;
  }

  Map<String, String>? _localizedValues;

  Future<void> load() async {
    try {
      String jsonStringValues =
          await rootBundle.loadString('lib/localization/languages/${locale.languageCode}.json');
      Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
      _localizedValues = mappedJson.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      print('Failed to load localization for ${locale.languageCode}: $e');
      // Handle error accordingly, e.g., set default values or fallback to another language
      _localizedValues = {};
    }
  }

  String? getTranslatedValue(String key) {
    if (_localizedValues == null) {
      // Handle this case based on app requirements, e.g., return a default value or throw an error
      return null;
    }
    return _localizedValues![key];
  }

  static const LocalizationsDelegate<DemoLocalization> delegate = _DemoLocalizationDelegate();
}

class _DemoLocalizationDelegate extends LocalizationsDelegate<DemoLocalization>{

  const _DemoLocalizationDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'et', 'uk'].contains(locale.languageCode);
  }

  @override
  Future<DemoLocalization> load(Locale locale) async {
    DemoLocalization localization = DemoLocalization(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(_DemoLocalizationDelegate old) => false;

}