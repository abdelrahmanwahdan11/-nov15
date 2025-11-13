import 'package:flutter/material.dart';

import '../utils/models.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction});

  final TransactionItem transaction;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(Icons.receipt_long, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(transaction.location),
      subtitle: Text('${transaction.dateTime.hour.toString().padLeft(2, '0')}:${transaction.dateTime.minute.toString().padLeft(2, '0')}'),
      trailing: Text('\$${transaction.amount.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
