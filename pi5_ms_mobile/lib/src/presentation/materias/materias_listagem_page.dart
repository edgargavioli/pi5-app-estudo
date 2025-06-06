import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/gauge_chart_widget.dart';
import 'package:pi5_ms_mobile/src/presentation/materias/materias_config_page.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/editar_prova_page.dart';
import '../estudos/sessoes_estudo_page.dart';
import '../../shared/models/prova_model.dart';
import '../../shared/services/materia_service.dart';
import '../../shared/services/prova_service.dart';

class MateriasListagemPage extends StatefulWidget {
  final String title;
  final String provaId; // Mudado para String (UUID)

  const MateriasListagemPage({
    super.key,
    required this.title,
    required this.provaId,
  });

  @override
  State<MateriasListagemPage> createState() => _MateriasListagemPageState();
}

class _MateriasListagemPageState extends State<MateriasListagemPage> {
  final TextEditingController _searchController = TextEditingController();
  Prova? _prova;
  List<Materia> _materias = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    // Adicionar listener para pesquisa em tempo real
    _searchController.addListener(_filtrarConteudo);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filtrarConteudo);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Buscar a prova específica
      final prova = await ProvaService.buscarPorId(widget.provaId);
      
      // Buscar todas as matérias associadas à prova
      List<Materia> materias = [];
      if (prova.materias.isNotEmpty) {
        // Se a prova já veio com as matérias
        materias = prova.materias;
      } else if (prova.materiasIds.isNotEmpty) {
        // Se só temos os IDs, buscar cada matéria
        for (String materiaId in prova.materiasIds) {
          try {
            final materia = await MateriaService.buscarPorId(materiaId);
            materias.add(materia);
          } catch (e) {
            print('Erro ao carregar matéria $materiaId: $e');
          }
        }
      }
      
      if (mounted) {
        setState(() {
          _prova = prova;
          _materias = materias;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Erro ao carregar dados: $e';
        });
      }
    }
  }

  void _filtrarConteudo() {
    // Implementar filtro em tempo real se necessário
    // Por enquanto, já que é apenas uma matéria, não há muito o que filtrar
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_prova != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProvaPage(prova: _prova!),
                  ),
                );
                
                if (result == true) {
                  _carregarDados(); // Recarregar os dados se houve edição
                }
              },
              tooltip: 'Editar prova',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget(theme)
              : _buildContent(theme, screenSize),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "materias_listagem_fab",
        backgroundColor: theme.colorScheme.primary,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ConfigMateriaPage(),
            ),
          );
          
          if (result != null) {
            _carregarDados();
          }
        },
        icon: Icon(Icons.settings, color: theme.colorScheme.onPrimary),
        label: Text(
          "Configurar Matérias",
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar dados',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarDados,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, Size screenSize) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gauges com informações da prova
          if (_prova != null) ...[
            DashboardGaugesSyncfusion(
              gauges: [
                GaugeData(
                  label: "Prova",
                  valueText: _prova!.titulo.length > 10 
                      ? '${_prova!.titulo.substring(0, 10)}...' 
                      : _prova!.titulo,
                  value: 100,
                  color: theme.colorScheme.primary,
                ),
                GaugeData(
                  label: "Matérias",
                  valueText: "${_materias.length}",
                  value: _materias.length.toDouble(),
                  color: theme.colorScheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Card com informações detalhadas da prova
            _buildProvaInfoCard(theme),
            const SizedBox(height: 24),
          ],

          // Seção de ações
          if (_materias.isNotEmpty) ...[
            Text(
              'Matérias da Prova (${_materias.length})',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Lista de matérias associadas
            ...List.generate(_materias.length, (index) {
              final materia = _materias[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 1,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.book,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    materia.nome,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    materia.categoria,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Removido o botão de gerenciar sessões de estudo para não ter ambiguidade
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // Removido o botão geral de "Gerenciar Sessões de Estudo" para não ter ambiguidade
          ] else
            _buildSemMateriaWidget(theme),
        ],
      ),
    );
  }

  Widget _buildProvaInfoCard(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _prova!.titulo,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            
            if (_prova!.descricao != null) ...[
              const SizedBox(height: 12),
              Text(
                _prova!.descricao!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Informações de data, hora e local
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  Icons.calendar_today,
                  '${_prova!.data.day.toString().padLeft(2, '0')}/${_prova!.data.month.toString().padLeft(2, '0')}/${_prova!.data.year}',
                  theme,
                ),
                _buildInfoChip(
                  Icons.access_time,
                  '${_prova!.horario.hour.toString().padLeft(2, '0')}:${_prova!.horario.minute.toString().padLeft(2, '0')}',
                  theme,
                ),
                _buildInfoChip(
                  Icons.location_on,
                  _prova!.local,
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemMateriaWidget(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma matéria associada',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Esta prova não possui matérias específicas associadas. Use o botão de configurações para gerenciar as matérias.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
