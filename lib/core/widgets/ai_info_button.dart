import 'package:flutter/material.dart';

import '../localization/localization_extensions.dart';

class AIInfoButton extends StatelessWidget {
  const AIInfoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.smart_toy_outlined),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.translate('ai_placeholder')),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      tooltip: context.l10n.translate('ai_placeholder'),
    );
  }
}
