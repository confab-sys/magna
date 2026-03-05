import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magna_coders/app/app.dart';
import 'package:magna_coders/app/bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.init();
  runApp(
    const ProviderScope(
      child: MagnaApp(),
    ),
  );
}
