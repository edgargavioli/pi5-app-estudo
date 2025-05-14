import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/scaffold_widget.dart';
import 'package:pi5_ms_mobile/src/presentation/cronograma/cronograma_page.dart';
import 'package:pi5_ms_mobile/src/presentation/desempenho/desempenho_page.dart';
import 'package:pi5_ms_mobile/src/presentation/estudos/estudos_page.dart';
import 'package:pi5_ms_mobile/src/presentation/historico/historico_page.dart';
import 'package:pi5_ms_mobile/src/presentation/materias/adicionar_materia_page.dart';
import 'package:pi5_ms_mobile/src/presentation/materias/materias_listagem_page.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/adicionar_prova_page.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/editar_prova_page.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/provas_listagem_page.dart';
import 'package:pi5_ms_mobile/src/presentation/user/perfil_usuario_page_info.dart';
import 'package:pi5_ms_mobile/src/presentation/user/perfil_usuario_page.dart';

final Map<String, Widget Function(BuildContext)> routes = {
  '/home': (context) => ScaffoldWidget(),
  '/provas': (context) => const ProvaslistagemPage(),
  '/cronograma': (context) => const CronogramaPage(),
  '/desempenho': (context) => const DesempenhoPage(),
  '/estudos': (context) => const EstudosPage(),
  '/editprova': (context) => const EditProvaPage(),
  '/historico': (context) => const HistoricoPage(),
  '/addprova': (context) => const AdicionarProvaPage(),
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
};
