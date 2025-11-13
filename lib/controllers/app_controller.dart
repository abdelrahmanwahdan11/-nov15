import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_colors.dart';

class AppController {
  AppController._internal();

  static final AppController instance = AppController._internal();

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);
  final ValueNotifier<Color> primaryColor = ValueNotifier(AppColors.lightPrimary);
  final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en'));
  final ValueNotifier<bool> isLoggedIn = ValueNotifier(false);
  final ValueNotifier<bool> isGuest = ValueNotifier(false);
  final ValueNotifier<bool> hasSeenOnboarding = ValueNotifier(false);

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    final storedTheme = _prefs!.getString('theme_mode');
    final storedColor = _prefs!.getString('primary_color_hex');
    final storedLocale = _prefs!.getString('locale_code');
    final storedLoggedIn = _prefs!.getBool('is_logged_in');
    final storedGuest = _prefs!.getBool('is_guest');
    final storedOnboarding = _prefs!.getBool('has_seen_onboarding');

    if (storedTheme != null) {
      themeMode.value = ThemeMode.values.firstWhere(
        (mode) => mode.name == storedTheme,
        orElse: () => ThemeMode.light,
      );
    }
    if (storedColor != null) {
      primaryColor.value = Color(int.parse(storedColor, radix: 16));
    }
    if (storedLocale != null) {
      locale.value = Locale(storedLocale);
    }
    if (storedLoggedIn != null) {
      isLoggedIn.value = storedLoggedIn;
    }
    if (storedGuest != null) {
      isGuest.value = storedGuest;
    }
    if (storedOnboarding != null) {
      hasSeenOnboarding.value = storedOnboarding;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _prefs?.setString('theme_mode', mode.name);
  }

  Future<void> setPrimaryColor(Color color) async {
    primaryColor.value = color;
    await _prefs?.setString('primary_color_hex', color.value.toRadixString(16));
  }

  Future<void> setLocale(Locale newLocale) async {
    locale.value = newLocale;
    await _prefs?.setString('locale_code', newLocale.languageCode);
  }

  Future<void> setLoggedIn(bool value, {bool guest = false}) async {
    isLoggedIn.value = value;
    isGuest.value = guest;
    await _prefs?.setBool('is_logged_in', value);
    await _prefs?.setBool('is_guest', guest);
  }

  Future<void> setOnboardingSeen() async {
    hasSeenOnboarding.value = true;
    await _prefs?.setBool('has_seen_onboarding', true);
  }

  bool get isRtl => locale.value.languageCode == 'ar';
}
