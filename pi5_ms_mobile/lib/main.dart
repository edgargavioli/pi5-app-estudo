import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/presentation/HomePage.dart';
import 'package:pi5_ms_mobile/src/shared/appBar_theme.dart';
import 'package:pi5_ms_mobile/src/shared/theme.dart';
import 'package:pi5_ms_mobile/src/shared/util.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    TextTheme textTheme = createTextTheme(context, "Roboto", "Poppins");

    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      title: "PI5 MS Mobile",
      theme: brightness == Brightness.light ? theme.light().copyWith(appBarTheme: AppBarThemeConfig.lightTheme) : theme.dark().copyWith(appBarTheme: AppBarThemeConfig.darkTheme),
      debugShowCheckedModeBanner: false,
      home: const HomePage(
        title: "PI5 MS Mobile",
      ),
    );
  }
}