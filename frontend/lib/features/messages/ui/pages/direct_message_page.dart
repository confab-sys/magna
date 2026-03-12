import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magna_coders/core/auth/token_storage.dart';
import 'package:magna_coders/features/messages/data/repositories/messages_repository_impl.dart';
import 'package:magna_coders/features/messages/domain/entities/conversation_entity.dart';
import 'package:magna_coders/features/messages/ui/controllers/conversation_controller.dart';
import 'package:magna_coders/features/messages/ui/widgets/conversation_app_bar.dart';
import 'package:magna_coders/features/messages/ui/widgets/date_separator.dart';
import 'package:magna_coders/features/messages/ui/widgets/empty_conversation_state.dart';
import 'package:magna_coders/features/messages/ui/widgets/message_bubble.dart';
import 'package:magna_coders/features/messages/ui/widgets/message_input_bar.dart';
import 'package:magna_coders/features/messages/ui/widgets/typing_indicator.dart';
import 'package:magna_coders/shared/widgets/app_loader.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:magna_coders/app/bootstrap.dart';

/// Direct one‑to‑one chat screen used when starting a message
/// from a builder's profile card.
class DirectMessagePage extends StatefulWidget {
  final String builderId;
  final String? builderName;
  final String? builderAvatarUrl;
  final String? conversationId;

  const DirectMessagePage({
    super.key,
    required this.builderId,
    this.builderName,
    this.builderAvatarUrl,
    this.conversationId,
  });

  @override
  State<DirectMessagePage> createState() => _DirectMessagePageState();
}

class _DirectMessagePageState extends State<DirectMessagePage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  final _messagesRepository = MessagesRepositoryImpl();
  ConversationController? _conversationController;
  ConversationEntity? _conversation;
  String? _currentUserId;
  bool _isCreating = true;
  String? _error;
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _initConversation();
  }

  Future<void> _initConversation() async {
    try {
      final userId = await TokenStorage.readUserId();
      _currentUserId = userId ?? 'current-user';

      final ConversationEntity conversation;

      if (widget.conversationId != null) {
        conversation = await _messagesRepository.getConversationById(
          widget.conversationId!,
        );
      } else {
        // Reuse existing DM if it exists; otherwise create it.
        conversation = await _messagesRepository.getOrCreateDirectConversation(
          otherUserId: widget.builderId,
        );
      }

      if (!mounted) return;

      _conversation = conversation;
      _conversationController = ConversationController(
        conversationId: conversation.id,
        currentUserId: _currentUserId!,
      )..addListener(_onConversationChanged);

      await _conversationController!.loadMessages();
      _connectWebSocket();
      setState(() {
        _isCreating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to start conversation';
        _isCreating = false;
      });
    }
  }

  void _connectWebSocket() {
    if (_conversation == null || _currentUserId == null) return;
    _channel?.sink.close();

    final base = ApiConfig.realtimeBase;
    if (base == null || base.isEmpty) return;

    TokenStorage.readAccessToken().then((token) {
      if (!mounted) return;
      if (token == null || token.isNotEmpty == false) return;

      final uri = Uri.parse('$base/ws/${_conversation!.id}?token=$token');
      final channel = WebSocketChannel.connect(uri);
      _channel = channel;

      channel.stream.listen((event) async {
        if (_conversationController != null) {
          await _conversationController!.loadMessages();
        }
      });

      try {
        channel.sink.add(
          jsonEncode({
            'type': 'join',
            'conversationId': _conversation!.id,
          }),
        );
      } catch (_) {}
    });
  }

  Future<void> _archiveConversation({required bool archive}) async {
    if (_conversation == null) return;
    try {
      await _messagesRepository.updateConversationPreferences(
        conversationId: _conversation!.id,
        isArchived: archive,
      );
      if (!mounted) return;
      context.pop(); // close sheet/menu
      context.pop(); // back to inbox
    } catch (_) {
      // no-op for now
    }
  }

  void _showConversationActions() {
    final isArchived = _conversation?.isArchived ?? false;
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
                leading: Icon(
                  isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
                ),
                title: Text(isArchived ? 'Unarchive' : 'Archive'),
                onTap: () => _archiveConversation(archive: !isArchived),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete conversation'),
                onTap: () => _archiveConversation(archive: true),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _conversationController?.removeListener(_onConversationChanged);
    _conversationController?.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  void _onConversationChanged() {
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
    if (_conversationController == null) return;
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    final toSend = text;
    _inputController.clear();
    await _conversationController!.sendMessage(toSend);
  }

  void _handleDeleteMessage(message) {
    if (_conversationController == null) return;
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
                  await _conversationController!.deleteMessage(message);
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
    final title = widget.builderName ?? 'Direct message';
    final avatarUrl = widget.builderAvatarUrl;

    if (_isCreating) {
      return Scaffold(
        appBar: ConversationAppBar(
          title: title,
          subtitle: 'Starting chat…',
          avatarUrl: avatarUrl,
          onBack: () => context.pop(),
          onMore: _showConversationActions,
        ),
        body: const Center(child: AppLoader()),
      );
    }

    if (_error != null || _conversationController == null) {
      return Scaffold(
        appBar: ConversationAppBar(
          title: title,
          avatarUrl: avatarUrl,
          onBack: () => context.pop(),
          onMore: _showConversationActions,
        ),
        body: const EmptyConversationState(),
      );
    }

    final state = _conversationController!.state;

    return Scaffold(
      appBar: ConversationAppBar(
        title: title,
        subtitle: 'Direct chat',
        avatarUrl: avatarUrl,
        onBack: () => context.pop(),
        onMore: _showConversationActions,
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

                        final previous =
                            index > 0 ? state.messages[index - 1] : null;
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

