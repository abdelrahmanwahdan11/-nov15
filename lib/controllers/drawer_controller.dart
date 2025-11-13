import 'package:flutter/material.dart';

class AppDrawerController {
  AppDrawerController._();

  static final AppDrawerController instance = AppDrawerController._();

  final ValueNotifier<String> selectedItem = ValueNotifier('home');

  void select(String item) {
    selectedItem.value = item;
  }
}
