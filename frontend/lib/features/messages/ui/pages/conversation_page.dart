import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void initState() {
    super.initState();
    // TODO: Inject real currentUserId from auth state when available.
    _controller = ConversationController(
      conversationId: widget.conversationId,
      currentUserId: 'current-user',
    )..addListener(_onChanged);
    _controller.loadMessages();
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

  @override
  Widget build(BuildContext context) {
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

                        items.add(MessageBubble(message: message));
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

