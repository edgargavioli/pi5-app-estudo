import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/presentation/HomePage.dart';
import 'package:pi5_ms_mobile/src/presentation/LoginPage.dart';
import 'package:pi5_ms_mobile/src/presentation/ProvasPage.dart';
import 'package:pi5_ms_mobile/src/shared/theme.dart';
import 'package:pi5_ms_mobile/src/shared/util.dart';
import 'package:pi5_ms_mobile/src/presentation/CronogramaPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.system);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Roboto", "Poppins");

    MaterialTheme theme = MaterialTheme(textTheme);

    return ValueListenableBuilder(
      valueListenable: _themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: "PI5 MS Mobile",
          themeMode: themeMode,
          theme: theme.light(),
          darkTheme: theme.dark(),
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginPage(),
            '/home': (context) => const HomePage(title: "PI5 MS Mobile"),
            '/provas': (context) => const ProvasPage(),
            '/login': (context) => const LoginPage(),
            '/cronograma': (context) => const CronogramaPage(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
