import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/app_controller.dart';
import 'core/localization/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/theme/theme_config.dart';
import 'features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppController.instance.init();
  runApp(const DriverApp());
}

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppController.instance;
    return ValueListenableBuilder<Locale>(
      valueListenable: controller.locale,
      builder: (_, locale, __) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: controller.themeMode,
          builder: (_, themeMode, __) {
            return ValueListenableBuilder<Color>(
              valueListenable: controller.primaryColor,
              builder: (_, primaryColor, __) {
                final isRtl = locale.languageCode == 'ar';
                return Directionality(
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  child: MaterialApp(
                    navigatorKey: AppRouter.navigatorKey,
                    title: 'Driver Pro',
                    theme: ThemeConfig.lightTheme(primaryColor),
                    darkTheme: ThemeConfig.darkTheme(primaryColor),
                    themeMode: themeMode,
                    locale: locale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    onGenerateRoute: AppRouter.onGenerateRoute,
                    home: const SplashScreen(),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
