import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('ja')); // ✅ 默认日语

  void setJa() => state = const Locale('ja');
  void setZh() => state = const Locale('zh');
  void setEn() => state = const Locale('en');

  void setLocale(Locale locale) => state = locale;
}

final localeProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController();
});
