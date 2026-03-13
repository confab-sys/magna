import 'package:flutter/material.dart';
import 'package:magna_coders/features/magna_ai/domain/entities/ai_message_entity.dart';
import 'magna_ai_message_bubble.dart';

class MagnaAiChatArea extends StatelessWidget {
  final List<AIMessageEntity> messages;
  final bool isSending;

  const MagnaAiChatArea({
    super.key,
    required this.messages,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(child: Text("Start a conversation..."));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: messages.length + (isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()), // Or TypingIndicator
          );
        }
        return MagnaAiMessageBubble(message: messages[index]);
      },
    );
  }
}
