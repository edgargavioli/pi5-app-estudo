import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/presentation/HomePage.dart';
import 'package:pi5_ms_mobile/src/presentation/LoginPage.dart';
import 'package:pi5_ms_mobile/src/presentation/estudos/EstudosPage.dart';
import 'package:pi5_ms_mobile/src/presentation/materias/AdicionarMateriaPage.dart';
import 'package:pi5_ms_mobile/src/presentation/materias/MateriasListagemPage.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/ProvasListagemPage.dart';
import 'package:pi5_ms_mobile/src/shared/theme.dart';
import 'package:pi5_ms_mobile/src/shared/util.dart';
import 'package:pi5_ms_mobile/src/presentation/CronogramaPage.dart';
import 'package:pi5_ms_mobile/src/presentation/DesempenhoPage.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/EditProvaPage.dart';
import 'package:pi5_ms_mobile/src/presentation/user/UserProfilePageMain.dart';
import 'package:pi5_ms_mobile/src/presentation/user/UserProfilePageInfo.dart';
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
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginPage(),
            '/home': (context) => const HomePage(title: "PI5 MS Mobile"),
            '/provas': (context) => const ProvaslistagemPage(),
            '/login': (context) => const LoginPage(),
            '/cronograma': (context) => const CronogramaPage(),
            '/desempenho': (context) => const DesempenhoPage(),
            '/estudos': (context) => const EstudosPage(),
            '/editprova': (context) => const EditProvaPage(),
            '/perfil': (context) => const UserProfilePageMain(),
            '/perfilInfo': (context) => const UserProfilePageInfo(),
            '/materias':
                (context) => MateriasListagemPage(
                  provaId: ModalRoute.of(context)?.settings.arguments as int,
                ),
            '/materias/adicionar': (context) {
              final materias =
                  ModalRoute.of(context)?.settings.arguments as List<String>?;
              return AdicionarMateriaPage(materias: materias ?? []);
            },
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
