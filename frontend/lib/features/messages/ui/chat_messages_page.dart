import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/messages/data/chat_repository.dart';
import 'package:magna_coders/features/messages/domain/message.dart';
import 'package:magna_coders/shared/widgets/app_loader.dart';
import 'package:magna_coders/shared/widgets/app_text_field.dart';

class ChatMessagesPage extends StatefulWidget {
  final String conversationId;

  const ChatMessagesPage({super.key, required this.conversationId});

  @override
  State<ChatMessagesPage> createState() => _ChatMessagesPageState();
}

class _ChatMessagesPageState extends State<ChatMessagesPage> {
  final _repository = ChatRepository();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  bool _loading = true;
  List<Message> _messages = [];
  String? _currentUserId; // Would come from auth provider

  @override
  void initState() {
    super.initState();
    _loadMessages();
    // In a real app, we'd get this from a provider
    // For now we'll fetch it or mock it.
    // _currentUserId = ref.read(authProvider).user?.id;
  }

  Future<void> _loadMessages() async {
    setState(() => _loading = true);
    final messages = await _repository.getMessages(widget.conversationId);
    if (mounted) {
      setState(() {
        _messages = messages;
        _loading = false;
      });
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    // Optimistic update
    // We would add a local message here
    
    final success = await _repository.sendMessage(widget.conversationId, text);
    if (success) {
      _loadMessages();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const AppLoader()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      // final isMe = message.senderId == _currentUserId;
                      // For now, assume all even messages are me for UI testing if ID missing
                      final isMe = index % 2 == 0; 
                      return _MessageBubble(message: message, isMe: isMe);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _messageController,
                    label: 'Type a message...',
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(PhosphorIcons.paperPlaneRight(), color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
          border: isMe ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          message.content,
          style: AppTypography.bodyMedium.copyWith(
            color: isMe ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
