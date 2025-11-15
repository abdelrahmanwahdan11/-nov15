import 'dart:async';

import 'package:flutter/material.dart';

class AuthController {
  AuthController._();

  static final AuthController instance = AuthController._();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();

  Stream<bool> get authStateStream => _authStateController.stream;

  Future<bool> login(String emailOrPhone, String password) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    isLoading.value = false;
    final success = emailOrPhone.isNotEmpty && password.length >= 6;
    _authStateController.add(success);
    return success;
  }

  Future<bool> register(Map<String, String> payload) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    isLoading.value = false;
    final success = payload.values.every((element) => element.isNotEmpty) &&
        payload['password'] == payload['confirmPassword'];
    _authStateController.add(success);
    return success;
  }

  double passwordStrength(String password) {
    double strength = 0;
    if (password.length >= 6) strength += 0.3;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) strength += 0.3;
    return strength.clamp(0, 1);
  }

  void dispose() {
    _authStateController.close();
  }
}
