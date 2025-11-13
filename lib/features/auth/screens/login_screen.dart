import 'package:flutter/material.dart';

import '../../../controllers/app_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await AuthController.instance
        .login(_emailController.text.trim(), _passwordController.text.trim());
    if (success) {
      await AppController.instance.setLoggedIn(true, guest: false);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(RouteNames.home);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.translate('invalid_credentials'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text(l10n.translate('login'), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: l10n.translate('email_or_phone')),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.translate('required');
                    }
                    if (!value.contains('@') && value.length < 8) {
                      return l10n.translate('enter_valid_email_phone');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: l10n.translate('password'),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return l10n.translate('password_too_short');
                    }
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(RouteNames.forgotPassword);
                    },
                    child: Text(l10n.translate('forgot_password')),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(label: l10n.translate('login'), onPressed: _login),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: l10n.translate('continue_guest'),
                  onPressed: () async {
                    await AppController.instance.setLoggedIn(true, guest: true);
                    if (!mounted) return;
                    Navigator.of(context).pushReplacementNamed(RouteNames.home);
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(RouteNames.register);
                  },
                  child: Text(l10n.translate('register')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
