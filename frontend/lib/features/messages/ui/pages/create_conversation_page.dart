import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/messages/ui/controllers/create_conversation_controller.dart';
import 'package:magna_coders/shared/widgets/app_text_field.dart';

class CreateConversationPage extends StatefulWidget {
  const CreateConversationPage({super.key});

  @override
  State<CreateConversationPage> createState() => _CreateConversationPageState();
}

class _CreateConversationPageState extends State<CreateConversationPage> {
  late final CreateConversationController _controller;
  final TextEditingController _membersController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isGroup = false;

  @override
  void initState() {
    super.initState();
    _controller = CreateConversationController()..addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    _membersController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleCreate() async {
    final membersRaw = _membersController.text.trim();
    final memberUserIds = membersRaw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final conversation = await _controller.createConversation(
      conversationType: _isGroup ? 'group' : 'direct',
      name: _isGroup ? _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null : null,
      description: null,
      memberUserIds: memberUserIds,
    );

    if (conversation != null && mounted) {
      context.go('/messages/conversation/${conversation.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New conversation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Members',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            AppTextField(
              controller: _membersController,
              label: 'User IDs (comma separated)',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Switch(
                  value: _isGroup,
                  onChanged: (value) {
                    setState(() {
                      _isGroup = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Text('Group conversation'),
              ],
            ),
            if (_isGroup) ...[
              const SizedBox(height: 8),
              AppTextField(
                controller: _nameController,
                label: 'Group name (optional)',
              ),
            ],
            const SizedBox(height: 24),
            if (state.status == CreateConversationStatus.error &&
                state.errorMessage != null) ...[
              Text(
                state.errorMessage!,
                style: AppTypography.bodySmall.copyWith(color: Colors.red),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.status == CreateConversationStatus.submitting
                    ? null
                    : _handleCreate,
                child: Text(
                  state.status == CreateConversationStatus.submitting
                      ? 'Creating...'
                      : 'Create conversation',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

