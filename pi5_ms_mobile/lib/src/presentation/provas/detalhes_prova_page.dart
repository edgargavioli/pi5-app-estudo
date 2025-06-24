import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../shared/models/prova_model.dart';
import '../../shared/widgets/custom_snackbar.dart';
import '../estudos/estudos_prova_page.dart';

class DetalhesProvaPage extends StatelessWidget {
  final Prova prova;

  const DetalhesProvaPage({super.key, required this.prova});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(prova.titulo),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card com informações da prova
            _buildCardInfoProva(theme),

            const SizedBox(height: 16),

            // Botão de ação principal
            _buildBotaoAcaoPrincipal(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInfoProva(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.article, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Informações da Prova',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Data:', DateFormat('dd/MM/yyyy').format(prova.data)),
            _buildInfoRow(
              'Horário:',
              DateFormat('HH:mm').format(prova.horario),
            ),
            _buildInfoRow('Local:', prova.local),
            if (prova.materias.isNotEmpty) _buildMateriasRow(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildMateriasRow(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              'Matérias:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  prova.materias.map((materia) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        materia.nome,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoAcaoPrincipal(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Verificar se a prova tem matérias associadas
          if (prova.materias.isEmpty && prova.materiasIds.isEmpty) {
            CustomSnackBar.showWarning(
              context,
              'Esta prova não possui matérias associadas. Adicione matérias primeiro.',
            );
            return;
          }

          // Navegar para a página de estudos da prova
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EstudosProvaPage(prova: prova),
            ),
          );
        },
        icon: const Icon(Icons.play_circle_filled),
        label: const Text('Iniciar Estudos'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
