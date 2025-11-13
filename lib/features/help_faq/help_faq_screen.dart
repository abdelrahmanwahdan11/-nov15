
import 'package:flutter/material.dart';

import '../../core/localization/localization_extensions.dart';
class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {'q': 'How to accept rides?', 'a': 'Tap the accept button on the incoming ride card.'},
      {'q': 'How to change language?', 'a': 'Go to settings and select preferred language.'},
      {'q': 'Contact support', 'a': 'Use the contact button below.'},
    ];
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('help'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ...faqs.map((faq) => ExpansionTile(
                title: Text(faq['q']!),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(faq['a']!),
                  ),
                ],
              )),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(l10n.translate('contact_support')),
                  content: const Text('Email: support@driverpro.app'),
                  actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
                ),
              );
            },
            child: Text(l10n.translate('contact_support')),
          ),
        ],
      ),
    );
  }
}
