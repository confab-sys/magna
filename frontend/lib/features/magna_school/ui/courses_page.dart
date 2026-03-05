import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/shared/widgets/empty_state.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Magna School')),
      body: const EmptyState(
        title: 'No Courses',
        message: 'No courses available yet',
      ),
    );
  }
}
