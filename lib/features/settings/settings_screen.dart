
import 'package:flutter/material.dart';

import '../../controllers/app_controller.dart';

import '../../core/localization/localization_extensions.dart';
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppController.instance;
    final colorOptions = [
      const Color(0xFFFF8A3D),
      Colors.blue,
      Colors.green,
      Colors.purple,
    ];
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('settings_title'))),
      body: ValueListenableBuilder<Color>(
        valueListenable: controller.primaryColor,
        builder: (_, color, __) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              SwitchListTile(
                value: controller.themeMode.value == ThemeMode.dark,
                onChanged: (value) => controller.setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
                title: Text(l10n.translate('dark_mode')),
              ),
              ListTile(
                title: Text(l10n.translate('language')),
                trailing: DropdownButton<Locale>(
                  value: controller.locale.value,
                  onChanged: (value) {
                    if (value != null) controller.setLocale(value);
                  },
                  items: const [
                    DropdownMenuItem(value: Locale('en'), child: Text('English')),
                    DropdownMenuItem(value: Locale('ar'), child: Text('Arabic')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.translate('primary_color')),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: colorOptions.map((option) {
                  return GestureDetector(
                    onTap: () => controller.setPrimaryColor(option),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: option,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: option == color ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                value: true,
                onChanged: (_) {},
                title: Text(l10n.translate('notifications')),
              ),
            ],
          );
        },
      ),
    );
  }
}
