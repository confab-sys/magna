import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(message!),
            ),
          if (action != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: action!,
            ),
        ],
      ),
    );
  }
}
