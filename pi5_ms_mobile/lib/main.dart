import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/routes/app_routes.dart';
import 'package:pi5_ms_mobile/src/shared/theme.dart';
import 'package:pi5_ms_mobile/src/shared/util.dart';
import 'package:pi5_ms_mobile/src/shared/services/cronometro_service.dart';
import 'package:pi5_ms_mobile/src/shared/services/auth_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔐 INICIALIZAR SERVIÇOS CRÍTICOS
  try {
    print('🚀 Inicializando serviços...');

    // Inicializar AuthService (verificar tokens salvos)
    await AuthService().initialize();
    print('✅ AuthService inicializado');

    // Inicializar CronometroService
    await CronometroService().inicializar();
    print('✅ CronometroService inicializado');

    print('🎯 Todos os serviços inicializados com sucesso!');
  } catch (e) {
    print('❌ Erro ao inicializar serviços: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.system);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 💾 SALVAR ESTADOS QUANDO APP VAI PARA SEGUNDO PLANO
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      CronometroService().salvarEstadoAgora();
      // AuthService já persiste automaticamente
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar fontes locais que agora estão configuradas no pubspec.yaml
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
          initialRoute: AppRoutes.initial,
          routes: AppRoutes.routes,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
