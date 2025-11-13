
import 'package:flutter/material.dart';

import '../../core/localization/localization_extensions.dart';
class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final documents = [
      {'title': 'Driver License', 'status': 'uploaded'},
      {'title': 'Vehicle Insurance', 'status': 'pending'},
      {'title': 'Vehicle Registration', 'status': 'expired'},
    ];
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('documents_title'))),
      body: ListView.builder(
        itemCount: documents.length,
        padding: const EdgeInsets.all(24),
        itemBuilder: (_, index) {
          final doc = documents[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              title: Text(doc['title']!),
              subtitle: Text('${l10n.translate('status')}: ${doc['status']}'),
              trailing: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('${l10n.translate('upload')} ${doc['title']}'),
                      content: const Text('Upload dialog placeholder.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.translate('close'))),
                      ],
                    ),
                  );
                },
                child: Text(l10n.translate('upload')),
              ),
            ),
          );
        },
      ),
    );
  }
}
