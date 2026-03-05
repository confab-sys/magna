import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/theme.dart';
import 'package:magna_coders/app/router.dart';

class MagnaApp extends StatelessWidget {
  const MagnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Magna Coders',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
    );
  }
}
