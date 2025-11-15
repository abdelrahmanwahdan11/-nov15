
import 'package:flutter/material.dart';

import '../../core/localization/localization_extensions.dart';
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final conversations = List.generate(
      8,
      (index) => {
        'name': 'Passenger ${index + 1}',
        'message': 'Hey, I will be ready in 5 minutes.',
        'time': '1${index}:15',
      },
    );
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('chats'))),
      body: ListView.separated(
        itemCount: conversations.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (_, index) {
          final convo = conversations[index];
          return ListTile(
            leading: CircleAvatar(child: Text(convo['name']![0])),
            title: Text(convo['name']!),
            subtitle: Text(convo['message']!),
            trailing: Text(convo['time']!),
            onTap: () {
              Navigator.of(context).pushNamed('/chat-detail', arguments: convo);
            },
          );
        },
      ),
    );
  }
}
