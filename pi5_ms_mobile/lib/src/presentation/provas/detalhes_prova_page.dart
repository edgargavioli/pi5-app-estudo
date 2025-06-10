import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../shared/models/prova_model.dart';
import '../../shared/models/evento_model.dart';
import '../../shared/services/sessao_service.dart';
import '../../shared/services/prova_service.dart';
import '../estudos/sessoes_estudo_page.dart';
import '../estudos/criar_sessao_page.dart';

class DetalhesProvaPage extends StatefulWidget {
  final Prova prova;

  const DetalhesProvaPage({super.key, required this.prova});

  @override
  State<DetalhesProvaPage> createState() => _DetalhesProvaPageState();
}

class _DetalhesProvaPageState extends State<DetalhesProvaPage> {
  List<SessaoEstudo> _sessoesProva = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarSessoes();
  }

  Future<void> _carregarSessoes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Primeiro tentar o método específico por prova
      List<SessaoEstudo> sessoes;
      try {
        sessoes = await SessaoService.listarSessoesPorProva(widget.prova.id);
      } catch (e) {
        // Se falhar, buscar todas e filtrar manualmente
        print('Erro ao buscar sessões por prova, tentando filtro manual: $e');
        final todasSessoes = await SessaoService.listarSessoes();
        sessoes = todasSessoes.where((sessao) => sessao.provaId == widget.prova.id).toList();
      }
      
      // Filtro adicional de segurança para garantir que só sessões desta prova apareçam
      final sessoesFiltradas = sessoes.where((sessao) => 
        sessao.provaId != null && sessao.provaId == widget.prova.id
      ).toList();
      
      // Debug: imprimir informações sobre o filtro
      print('=== DEBUG SESSÕES ===');
      print('Prova ID: ${widget.prova.id}');
      print('Total sessões encontradas: ${sessoes.length}');
      print('Sessões após filtro: ${sessoesFiltradas.length}');
      print('IDs das sessões filtradas: ${sessoesFiltradas.map((s) => '${s.id} (provaId: ${s.provaId})').join(', ')}');
      print('====================');
      
      if (mounted) {
        setState(() {
          _sessoesProva = sessoesFiltradas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _finalizarProva() async {
    if (widget.prova.totalQuestoes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta prova não possui total de questões definido. Configure primeiro o número de questões.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final resultado = await showDialog<Map<String, int>>(
      context: context,
      builder: (context) => _FinalizarProvaDialog(
        totalQuestoes: widget.prova.totalQuestoes!,
      ),
    );

    if (resultado != null) {
      try {
        final questoesAcertadas = resultado['acertadas']!;
        final totalQuestoes = widget.prova.totalQuestoes!;
        final percentual = ((questoesAcertadas / totalQuestoes) * 100).round();

        final provaAtualizada = Prova(
          id: widget.prova.id,
          titulo: widget.prova.titulo,
          descricao: widget.prova.descricao,
          data: widget.prova.data,
          horario: widget.prova.horario,
          local: widget.prova.local,
          materiasIds: widget.prova.materiasIds,
          filtros: widget.prova.filtros,
          totalQuestoes: widget.prova.totalQuestoes,
          acertos: questoesAcertadas,
          createdAt: widget.prova.createdAt,
          updatedAt: DateTime.now(),
          materias: widget.prova.materias,
        );

        await ProvaService.atualizarProva(widget.prova.id, provaAtualizada);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Prova finalizada! Resultado: $questoesAcertadas/$totalQuestoes ($percentual%)'),
              backgroundColor: percentual >= 70 ? Colors.green : percentual >= 50 ? Colors.orange : Colors.red,
            ),
          );
          Navigator.pop(context, true); // Retorna true para indicar que houve mudança
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao finalizar prova: $e')),
          );
        }
      }
    }
  }

  String _formatarDuracao(Duration duracao) {
    final horas = duracao.inHours;
    final minutos = duracao.inMinutes.remainder(60);
    
    if (horas > 0) {
      return '${horas}h ${minutos}min';
    } else {
      return '${minutos}min';
    }
  }

  Duration _calcularTempoTotalEstudo() {
    Duration total = Duration.zero;
    for (final sessao in _sessoesProva) {
      if (sessao.tempoInicio != null && sessao.tempoFim != null) {
        total += sessao.tempoFim!.difference(sessao.tempoInicio!);
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.prova.titulo),
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
            
            // Estatísticas das sessões
            _buildEstatisticasSessoes(theme),
            
            const SizedBox(height: 16),
            
            // Botões de ação
            _buildBotoesAcao(theme),
            
            const SizedBox(height: 16),
            
            // Lista de sessões de estudo
            _buildListaSessoes(theme),
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
            _buildInfoRow('Data:', DateFormat('dd/MM/yyyy').format(widget.prova.data)),
            _buildInfoRow('Horário:', DateFormat('HH:mm').format(widget.prova.horario)),
            _buildInfoRow('Local:', widget.prova.local),
            if (widget.prova.totalQuestoes != null)
              _buildInfoRow('Total de Questões:', widget.prova.totalQuestoes.toString()),
            if (widget.prova.foiRealizada && widget.prova.percentualAcerto != null)
              _buildInfoRow('Resultado:', '${widget.prova.acertos}/${widget.prova.totalQuestoes} (${widget.prova.percentualAcerto}%)'),
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
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildEstatisticasSessoes(ThemeData theme) {
    final tempoTotal = _calcularTempoTotalEstudo();
    final sessoesFinalizadas = _sessoesProva.where((s) => s.tempoFim != null).length;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Estatísticas de Estudo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildEstatistica(
                    'Sessões',
                    _sessoesProva.length.toString(),
                    Icons.book,
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEstatistica(
                    'Finalizadas',
                    sessoesFinalizadas.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEstatistica(
                    'Tempo Total',
                    _formatarDuracao(tempoTotal),
                    Icons.timer,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstatistica(String titulo, String valor, IconData icone, Color cor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icone, color: cor, size: 20),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 10,
              color: cor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBotoesAcao(ThemeData theme) {
    return Column(
      children: [
        // Botão principal para criar sessão de estudo
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              print('=== CRIANDO SESSÃO ===');
              print('Prova ID sendo passado: ${widget.prova.id}');
              print('Prova título: ${widget.prova.titulo}');
              print('======================');
              
              final resultado = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => CriarSessaoPage(
                    provaId: widget.prova.id,
                    // Garantir que o provaId seja pré-selecionado
                  ),
                ),
              );
              
              if (resultado == true) {
                print('Sessão criada com sucesso, recarregando...');
                _carregarSessoes(); // Recarregar sessões
              }
            },
            icon: const Icon(Icons.school),
            label: const Text('Nova Sessão de Estudo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        Row(
          children: [
            // Botão para gerenciar todas as sessões
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SessoesEstudoPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.manage_search, size: 20),
                label: const Text('Gerenciar Sessões'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Botão para finalizar prova
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.prova.foiRealizada ? null : _finalizarProva,
                icon: Icon(
                  widget.prova.foiRealizada ? Icons.check_circle : Icons.flag,
                  size: 20,
                ),
                label: Text(
                  widget.prova.foiRealizada ? 'Finalizada' : 'Finalizar Prova',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.prova.foiRealizada ? Colors.grey : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListaSessoes(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sessões desta Prova (${_sessoesProva.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Center(
            child: Column(
              children: [
                Text('Erro ao carregar sessões: $_error'),
                ElevatedButton(
                  onPressed: _carregarSessoes,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          )
        else if (_sessoesProva.isEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma sessão para esta prova',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crie uma sessão de estudo específica para esta prova usando o botão "Nova Sessão de Estudo" acima',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...List.generate(_sessoesProva.length, (index) {
            final sessao = _sessoesProva[index];
            return _buildCardSessao(sessao, theme);
          }),
      ],
    );
  }

  Widget _buildCardSessao(SessaoEstudo sessao, ThemeData theme) {
    final sessaoFinalizada = sessao.tempoFim != null;
    final sessaoEmAndamento = sessao.tempoInicio != null && sessao.tempoFim == null;
    final sessaoNaoIniciada = sessao.tempoInicio == null;

    Duration? duracao;
    if (sessao.tempoInicio != null && sessao.tempoFim != null) {
      duracao = sessao.tempoFim!.difference(sessao.tempoInicio!);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    sessao.conteudo,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: sessaoNaoIniciada
                        ? Colors.grey.withOpacity(0.1)
                        : sessaoEmAndamento
                            ? Colors.green.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    sessaoNaoIniciada 
                        ? 'Não iniciada'
                        : sessaoEmAndamento 
                            ? 'Em andamento' 
                            : 'Finalizada',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: sessaoNaoIniciada
                          ? Colors.grey
                          : sessaoEmAndamento 
                              ? Colors.green 
                              : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            
            if (sessao.topicos.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: sessao.topicos.take(3).map((topico) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    topico,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                    ),
                  ),
                )).toList(),
              ),
            ],
            
            if (duracao != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    'Duração: ${_formatarDuracao(duracao)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FinalizarProvaDialog extends StatefulWidget {
  final int totalQuestoes;

  const _FinalizarProvaDialog({required this.totalQuestoes});

  @override
  State<_FinalizarProvaDialog> createState() => _FinalizarProvaDialogState();
}

class _FinalizarProvaDialogState extends State<_FinalizarProvaDialog> {
  final _controller = TextEditingController();
  int? _questoesAcertadas;

  @override
  Widget build(BuildContext context) {
    final percentual = _questoesAcertadas != null 
        ? ((_questoesAcertadas! / widget.totalQuestoes) * 100).round()
        : 0;

    return AlertDialog(
      title: const Text('Finalizar Prova'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Total de questões: ${widget.totalQuestoes}'),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Questões acertadas',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final acertadas = int.tryParse(value);
              setState(() {
                _questoesAcertadas = acertadas;
              });
            },
          ),
          if (_questoesAcertadas != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: percentual >= 70 
                    ? Colors.green.withOpacity(0.1)
                    : percentual >= 50 
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: percentual >= 70 
                      ? Colors.green
                      : percentual >= 50 
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
              child: Text(
                'Aproveitamento: $percentual%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: percentual >= 70 
                      ? Colors.green
                      : percentual >= 50 
                          ? Colors.orange
                          : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _questoesAcertadas != null && 
                     _questoesAcertadas! >= 0 && 
                     _questoesAcertadas! <= widget.totalQuestoes
              ? () => Navigator.pop(context, {'acertadas': _questoesAcertadas!})
              : null,
          child: const Text('Finalizar'),
        ),
      ],
    );
  }
} 