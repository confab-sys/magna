import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/features/magna_ai/data/models/ai_quick_action_model.dart';
import 'package:magna_coders/features/magna_ai/ui/controllers/magna_ai_controller.dart';
import 'package:magna_coders/features/magna_ai/ui/widgets/magna_ai_chat_area.dart';
import 'package:magna_coders/features/magna_ai/ui/widgets/magna_ai_conversation_panel.dart';
import 'package:magna_coders/features/magna_ai/ui/widgets/magna_ai_greeting.dart';
import 'package:magna_coders/features/magna_ai/ui/widgets/magna_ai_header.dart';
import 'package:magna_coders/features/magna_ai/ui/widgets/magna_ai_input_bar.dart';
import 'package:magna_coders/features/magna_ai/ui/widgets/magna_ai_quick_actions.dart';
import 'package:magna_coders/features/magna_ai/ui/widgets/magna_ai_quick_actions.dart' as qa_widgets;

class MagnaAiPage extends StatefulWidget {
  const MagnaAiPage({super.key});

  @override
  State<MagnaAiPage> createState() => _MagnaAiPageState();
}

class _MagnaAiPageState extends State<MagnaAiPage> {
  final MagnaAiController _controller = MagnaAiController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onStateChanged);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _handleQuickAction(AIQuickAction action) {
    // 1. Create new conversation if needed or select active
    // 2. Pre-fill input or send directly
    // For now, let's start a new conversation and pre-fill input logic
    _controller.createNewConversation();
    // Ideally we pass this prompt to input bar, but controller manages sending.
    // Let's auto-send for now as a "seed"
    _controller.sendMessage(action.prompt);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final showPanel = isDesktop; // Always show on desktop

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: !isDesktop
          ? Drawer(
              child: MagnaAiConversationPanel(
                conversations: _controller.conversations,
                activeId: _controller.activeConversationId,
                onSelect: (id) {
                  _controller.selectConversation(id);
                  Navigator.pop(context); // Close drawer
                },
                onNewChat: () {
                  _controller.createNewConversation();
                  Navigator.pop(context);
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (showPanel)
            MagnaAiConversationPanel(
              conversations: _controller.conversations,
              activeId: _controller.activeConversationId,
              onSelect: _controller.selectConversation,
              onNewChat: _controller.createNewConversation,
            ),
          Expanded(
            child: Column(
              children: [
                MagnaAiHeader(
                  showPanelToggle: !isDesktop,
                  onPanelToggle: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: _controller.hasActiveConversation
                      ? MagnaAiChatArea(
                          messages: _controller.activeMessages,
                          isSending: _controller.isSending,
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              const MagnaAiGreeting(),
                              qa_widgets.MagnaAiQuickActions(
                                onActionTap: _handleQuickAction,
                              ),
                            ],
                          ),
                        ),
                ),
                MagnaAiInputBar(
                  onSend: _controller.sendMessage,
                  isSending: _controller.isSending,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
