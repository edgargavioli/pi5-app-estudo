import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/shared/themes/theme_provider.dart';
import 'package:pi5_ms_mobile/theme_app.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return MaterialApp(
          title: "pi5_ms_mobile",
          home: Builder(
            builder: (innerContext) {
              final brightness = MediaQuery.platformBrightnessOf(innerContext);
              return ChangeNotifierProvider(
                create: (_) => ThemeProvider(brightness, innerContext),
                child: const ThemedApp(),
              );
            }
          ),
        );
      },
    );
  }
}