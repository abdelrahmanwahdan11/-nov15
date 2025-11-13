import 'dart:async';

import 'package:flutter/material.dart';

import '../../controllers/app_controller.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/routing/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    Timer(const Duration(seconds: 2), () {
      final appController = AppController.instance;
      if (!appController.hasSeenOnboarding.value) {
        Navigator.of(context).pushReplacementNamed(RouteNames.onboarding);
      } else if (appController.isLoggedIn.value || appController.isGuest.value) {
        Navigator.of(context).pushReplacementNamed(RouteNames.home);
      } else {
        Navigator.of(context).pushReplacementNamed(RouteNames.login);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_taxi, size: 72, color: Colors.orange),
              const SizedBox(height: 16),
              Text(l10n.translate('app_name'), style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}
