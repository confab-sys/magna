import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magna_coders/core/auth/token_storage.dart';
import 'package:magna_coders/features/messages/ui/controllers/conversation_controller.dart';
import 'package:magna_coders/features/messages/ui/widgets/conversation_app_bar.dart';
import 'package:magna_coders/features/messages/ui/widgets/date_separator.dart';
import 'package:magna_coders/features/messages/ui/widgets/empty_conversation_state.dart';
import 'package:magna_coders/features/messages/ui/widgets/message_bubble.dart';
import 'package:magna_coders/features/messages/ui/widgets/message_input_bar.dart';
import 'package:magna_coders/features/messages/ui/widgets/typing_indicator.dart';
import 'package:magna_coders/shared/widgets/app_loader.dart';

class ConversationPage extends StatefulWidget {
  final String conversationId;

  const ConversationPage({
    super.key,
    required this.conversationId,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late final ConversationController _controller;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    final userId = await TokenStorage.readUserId();
    _currentUserId = userId ?? 'current-user';
    if (!mounted) return;
    _controller = ConversationController(
      conversationId: widget.conversationId,
      currentUserId: _currentUserId!,
    )..addListener(_onChanged);
    _controller.loadMessages();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent,
          );
        }
      });
    }
  }

  Future<void> _handleSend() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    final toSend = text;
    _inputController.clear();
    await _controller.sendMessage(toSend);
  }

  void _handleDeleteMessage(message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete message'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _controller.deleteMessage(message);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final state = _controller.state;

    return Scaffold(
      appBar: ConversationAppBar(
        title: 'Conversation',
        subtitle: 'Members',
        onBack: () => context.pop(),
      ),
      body: Column(
        children: [
          Expanded(
            child: Builder(
              builder: (context) {
                switch (state.status) {
                  case ConversationStatus.loading:
                    return const AppLoader();
                  case ConversationStatus.error:
                    return const EmptyConversationState();
                  case ConversationStatus.empty:
                    return const EmptyConversationState();
                  case ConversationStatus.loaded:
                  case ConversationStatus.sending:
                  case ConversationStatus.idle:
                    if (state.messages.isEmpty) {
                      return const EmptyConversationState();
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        final items = <Widget>[];

                        final previous = index > 0 ? state.messages[index - 1] : null;
                        if (previous == null ||
                            previous.createdAt.day != message.createdAt.day ||
                            previous.createdAt.month != message.createdAt.month ||
                            previous.createdAt.year != message.createdAt.year) {
                          items.add(DateSeparator(date: message.createdAt));
                        }

                        items.add(
                          MessageBubble(
                            message: message,
                            onLongPress: message.isOwnMessage
                                ? () => _handleDeleteMessage(message)
                                : null,
                          ),
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: items,
                        );
                      },
                    );
                }
              },
            ),
          ),
          const TypingIndicator(isTyping: false),
          MessageInputBar(
            controller: _inputController,
            onSend: _handleSend,
          ),
        ],
      ),
    );
  }
}

