import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/scaffold_widget.dart';
import 'package:pi5_ms_mobile/src/presentation/auth/login_page.dart';
import 'package:pi5_ms_mobile/src/shared/theme.dart';
import 'package:pi5_ms_mobile/src/shared/util.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
  bool _isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Roboto", "Poppins");

    MaterialTheme theme = MaterialTheme(textTheme);

    return ValueListenableBuilder(
      valueListenable: _themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US'), Locale('pt', 'BR')],
          title: "PI5 MS Mobile",
          themeMode: themeMode,
          theme: theme.light(),
          darkTheme: theme.dark(),
          initialRoute: _isAuthenticated ? '/home' : '/',
          routes: {
            '/': (context) => LoginPage(onLogin: _onLogin),
            '/home': (context) => ScaffoldWidget(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  void _onLogin() {
    setState(() {
      _isAuthenticated = true;
    });
  }
}
