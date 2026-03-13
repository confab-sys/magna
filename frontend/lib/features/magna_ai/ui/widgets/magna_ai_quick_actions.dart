import 'package:flutter/material.dart';
import 'package:magna_coders/features/magna_ai/data/models/ai_quick_action_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'magna_ai_quick_action_card.dart';

class MagnaAiQuickActions extends StatelessWidget {
  final Function(AIQuickAction) onActionTap;

  const MagnaAiQuickActions({
    super.key,
    required this.onActionTap,
  });

  static final List<AIQuickAction> actions = [
    AIQuickAction(
      id: 'debug',
      title: 'Debug Code',
      description: 'Paste an error or snippet to fix issues.',
      icon: PhosphorIcons.bug(),
      prompt: 'Help me debug this code issue:\n\n',
    ),
    AIQuickAction(
      id: 'jobs',
      title: 'Find Jobs',
      description: 'Discover opportunities matching your skills.',
      icon: PhosphorIcons.briefcase(),
      prompt: 'Find job opportunities relevant to my profile.',
    ),
    AIQuickAction(
      id: 'collab',
      title: 'Find Collaborators',
      description: 'Search for builders to team up with.',
      icon: PhosphorIcons.users(),
      prompt: 'I\'m looking for collaborators for my project. Can you help me find suitable builders?',
    ),
    AIQuickAction(
      id: 'design',
      title: 'Design Help',
      description: 'Get UI/UX suggestions for your app.',
      icon: PhosphorIcons.palette(),
      prompt: 'I need help with the design of my application. Here are my requirements:',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return MagnaAiQuickActionCard(
          icon: action.icon,
          title: action.title,
          description: action.description,
          onTap: () => onActionTap(action),
        );
      },
    );
  }
}

