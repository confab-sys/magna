import 'package:flutter/material.dart';
import 'package:magna_coders/shared/widgets/empty_state.dart';

class EmptyMessagesState extends StatelessWidget {
  final VoidCallback onRefresh;

  const EmptyMessagesState({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'No conversations yet',
      message: 'Start a new conversation to connect with other builders.',
      action: ElevatedButton(
        onPressed: onRefresh,
        child: const Text('Refresh'),
      ),
    );
  }
}

