import 'package:flutter/material.dart';
import '../../presentation/shared/xp_ganho_feedback_page.dart';

class XpFeedbackHelper {
  /// Mostra a tela de feedback de XP ganho após finalizar uma sessão
  static Future<void> mostrarFeedbackXP({
    required BuildContext context,
    required Map<String, int> estatisticas,
    required bool isAgendada,
    required bool? cumpriuPrazo,
  }) async {
    // Garantir que todos os valores são inteiros válidos
    final xpGanho = (estatisticas['xpGanho'] ?? 0).toInt();
    final xpTotal = (estatisticas['xpTotal'] ?? 0).toInt();
    final nivel = (estatisticas['nivel'] ?? 1).toInt();

    // Determinar tipo de feedback
    bool isBonus = isAgendada && cumpriuPrazo == true;
    bool isPenalidade = isAgendada && cumpriuPrazo == false;

    // Determinar motivo
    String motivoXP;
    if (isBonus) {
      motivoXP = 'Sessão agendada cumprida no prazo (+50% XP)';
    } else if (isPenalidade) {
      motivoXP = 'Sessão agendada fora do prazo (-20% XP)';
    } else if (isAgendada) {
      motivoXP = 'Sessão de estudo agendada';
    } else {
      motivoXP = 'Sessão de estudo espontânea';
    }

    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => XpGanhoFeedbackPage(
              xpGanho: xpGanho,
              xpTotal: xpTotal,
              nivel: nivel,
              motivoXP: motivoXP,
              isBonus: isBonus,
              isPenalidade: isPenalidade,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
