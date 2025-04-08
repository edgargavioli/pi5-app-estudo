import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/presentation/HomePage.dart';
import 'package:pi5_ms_mobile/src/shared/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemedApp extends StatelessWidget {
  const ThemedApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).themeData;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: theme,
      home: const HomePage(),
    );
  }
}
