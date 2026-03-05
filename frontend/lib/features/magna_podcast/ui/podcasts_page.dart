import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/shared/widgets/empty_state.dart';

class PodcastsPage extends StatelessWidget {
  const PodcastsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Magna Podcast')),
      body: const EmptyState(
        title: 'No Episodes',
        message: 'No episodes yet',
      ),
    );
  }
}
