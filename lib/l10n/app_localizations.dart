import 'package:flutter/material.dart';

class AppLocalizations {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'logout': 'Log Out',
    },
    'ar': {
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'dark_mode': 'الوضع الداكن',
      'logout': 'تسجيل الخروج',
    },
  };

  static String translate(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    return _localizedValues[locale]?[key] ?? key;
  }
}
