
import 'package:flutter/material.dart';

import '../../core/localization/localization_extensions.dart';
class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key, this.conversation});

  final Map<String, String>? conversation;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messages.addAll([
      {'fromMe': false, 'text': 'Hello driver!'},
      {'fromMe': true, 'text': 'Hi, on my way.'},
    ]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.conversation?['name'] ?? 'Passenger';
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final message = _messages[index];
                final alignment = message['fromMe'] ? Alignment.centerRight : Alignment.centerLeft;
                final color = message['fromMe']
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                    : Theme.of(context).cardColor;
                return Align(
                  alignment: alignment,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message['text'] as String,
                      style: TextStyle(
                        color: message['fromMe'] ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: context.l10n.translate('search_data')),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final text = _messageController.text.trim();
                    if (text.isEmpty) return;
                    setState(() {
                      _messages.add({'fromMe': true, 'text': text});
                      _messageController.clear();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
