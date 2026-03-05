import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/messages/data/chat_repository.dart';
import 'package:magna_coders/features/messages/domain/conversation.dart';
import 'package:magna_coders/shared/widgets/app_loader.dart';
import 'package:magna_coders/shared/widgets/empty_state.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final _repository = ChatRepository();
  bool _loading = true;
  List<Conversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _loading = true);
    final conversations = await _repository.getConversations();
    if (mounted) {
      setState(() {
        _conversations = conversations;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: PhosphorIcon(PhosphorIcons.plus()),
            onPressed: () {
              // New conversation logic
            },
          ),
        ],
      ),
      body: _loading
          ? const AppLoader()
          : _conversations.isEmpty
              ? EmptyState(
                  title: 'No messages yet',
                  message: 'Start a conversation with other builders!',
                  action: ElevatedButton(
                    onPressed: _loadConversations,
                    child: const Text('Refresh'),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  child: ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final convo = _conversations[index];
                      return _ConversationTile(conversation: convo);
                    },
                  ),
                ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Text(
          (conversation.name ?? 'Unknown')[0].toUpperCase(),
          style: AppTypography.h3.copyWith(color: AppColors.primary, fontSize: 16),
        ),
      ),
      title: Text(
        conversation.name ?? 'Unknown',
        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        conversation.lastMessage ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.bodySmall,
      ),
      onTap: () {
        context.push('/chat/${conversation.id}');
      },
    );
  }
}
