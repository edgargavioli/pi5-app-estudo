import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../shared/models/evento_model.dart';
import '../../shared/models/prova_model.dart';
import '../../shared/services/sessao_service.dart';
import '../../shared/services/prova_service.dart';
import '../../shared/services/materia_service.dart';
import 'criar_sessao_page.dart';
import 'cronometragem_page.dart';

class SessoesEstudoPage extends StatefulWidget {
  const SessoesEstudoPage({super.key});

  @override
  State<SessoesEstudoPage> createState() => _SessoesEstudoPageState();
}

class _SessoesEstudoPageState extends State<SessoesEstudoPage> {
  List<SessaoEstudo> _sessoes = [];
  List<Prova> _provas = [];
  List<Materia> _materias = [];
  bool _isLoading = true;
  String _filtroTexto = '';

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    
    try {
      final resultados = await Future.wait([
        SessaoService.listarSessoes(),
        ProvaService.listarProvas(),
        MateriaService.listarMaterias(),
      ]);
      
      if (mounted) {
        setState(() {
          _sessoes = resultados[0] as List<SessaoEstudo>;
          _provas = resultados[1] as List<Prova>;
          _materias = resultados[2] as List<Materia>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  List<SessaoEstudo> get _sessoesFiltradas {
    if (_filtroTexto.isEmpty) return _sessoes;
    
    return _sessoes.where((sessao) {
      final materia = _materias.firstWhere(
        (m) => m.id == sessao.materiaId,
        orElse: () => Materia(
          id: '', 
          nome: 'Desconhecida', 
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      final prova = sessao.provaId != null 
          ? _provas.firstWhere(
              (p) => p.id == sessao.provaId,
              orElse: () => Prova(
                id: '', 
                titulo: 'Prova Desconhecida', 
                data: DateTime.now(),
                horario: DateTime.now(), 
                local: '', 
                materiasIds: [],
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            )
          : null;
      
      final textoBusca = '${sessao.conteudo} ${materia.nome} ${prova?.titulo ?? ''}'
          .toLowerCase();
      
      return textoBusca.contains(_filtroTexto.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
        title: Text(
          'Sessões de Estudo',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
            onPressed: _carregarDados,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "sessoes_estudo_add_fab",
        backgroundColor: colorScheme.primary,
        onPressed: () => _abrirFormularioSessao(),
        child: Icon(Icons.add, color: colorScheme.onPrimary),
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar sessões...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => setState(() => _filtroTexto = value),
            ),
          ),
          
          // Estatísticas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildEstatistica(
                    'Total', 
                    _sessoes.length.toString(),
                    Icons.library_books,
                    colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEstatistica(
                    'Não Iniciadas', 
                    _sessoes.where((s) => s.tempoInicio == null).length.toString(),
                    Icons.schedule,
                    Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEstatistica(
                    'Em Andamento', 
                    _sessoes.where((s) => s.tempoInicio != null && s.tempoFim == null).length.toString(),
                    Icons.play_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEstatistica(
                    'Finalizadas', 
                    _sessoes.where((s) => s.tempoFim != null).length.toString(),
                    Icons.check_circle,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Lista de sessões
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _sessoesFiltradas.isEmpty
                    ? _buildEstadoVazio()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _sessoesFiltradas.length,
                        itemBuilder: (context, index) {
                          final sessao = _sessoesFiltradas[index];
                          return _buildCardSessao(sessao);
                        },
                      ),
          ),
        ],
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
          Icon(icone, color: cor, size: 24),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _filtroTexto.isEmpty 
                ? 'Nenhuma sessão de estudo criada'
                : 'Nenhuma sessão encontrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filtroTexto.isEmpty
                ? 'Toque no botão + para criar sua primeira sessão'
                : 'Tente buscar por outros termos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSessao(SessaoEstudo sessao) {
    final materia = _materias.firstWhere(
      (m) => m.id == sessao.materiaId,
      orElse: () => Materia(
        id: '', 
        nome: 'Matéria Desconhecida', 
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    
    final prova = sessao.provaId != null 
        ? _provas.firstWhere(
            (p) => p.id == sessao.provaId,
            orElse: () => Prova(
              id: '', 
              titulo: 'Prova Desconhecida', 
              data: DateTime.now(),
              horario: DateTime.now(), 
              local: '', 
              materiasIds: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          )
        : null;
    
    final dataFormatada = sessao.tempoInicio != null 
        ? DateFormat('dd/MM/yyyy HH:mm').format(sessao.tempoInicio!)
        : 'Não iniciada';
    final duracao = sessao.tempoFim != null && sessao.tempoInicio != null
        ? sessao.tempoFim!.difference(sessao.tempoInicio!)
        : null;
    final sessaoNaoIniciada = sessao.tempoInicio == null;
    final sessaoEmAndamento = sessao.tempoInicio != null && sessao.tempoFim == null;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        materia.nome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (prova != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.assignment,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Prova: ${prova.titulo}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
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
            
            const SizedBox(height: 12),
            
            // Conteúdo
            Text(
              sessao.conteudo,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
            // Tópicos
            if (sessao.topicos.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: sessao.topicos.take(3).map((topico) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      topico,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (sessao.topicos.length > 3) ...[
                const SizedBox(height: 4),
                Text(
                  '+${sessao.topicos.length - 3} tópicos',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
            
            // Botão de cronômetro (mais visível para sessões em andamento ou não iniciadas)
            if (sessaoNaoIniciada || sessaoEmAndamento) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _abrirCronometragem(sessao),
                  icon: Icon(
                    sessaoNaoIniciada ? Icons.play_arrow : Icons.timer,
                    size: 20,
                  ),
                  label: Text(
                    sessaoNaoIniciada ? 'Iniciar Cronômetro' : 'Abrir Cronômetro',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sessaoNaoIniciada 
                        ? Theme.of(context).colorScheme.primary
                        : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Informações da sessão
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  dataFormatada,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (duracao != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.timer,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatarDuracao(duracao),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const Spacer(),
                // Ações
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  onSelected: (value) => _executarAcao(value, sessao),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    if (sessao.tempoFim == null && sessao.tempoInicio != null)
                      const PopupMenuItem(
                        value: 'finalizar',
                        child: Row(
                          children: [
                            Icon(Icons.stop, size: 16),
                            SizedBox(width: 8),
                            Text('Finalizar'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'excluir',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Excluir', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  void _executarAcao(String acao, SessaoEstudo sessao) {
    switch (acao) {
      case 'editar':
        _abrirFormularioSessao(sessao: sessao);
        break;
      case 'finalizar':
        _finalizarSessao(sessao);
        break;
      case 'excluir':
        _confirmarExclusao(sessao);
        break;
    }
  }

  Future<void> _abrirFormularioSessao({SessaoEstudo? sessao}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CriarSessaoPage(
          sessao: sessao,
        ),
      ),
    );
    
    if (resultado == true) {
      _carregarDados();
    }
  }

  Future<void> _abrirCronometragem(SessaoEstudo sessao) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CronometragemPage(
          sessao: sessao,
          materias: _materias,
        ),
      ),
    );
    
    if (resultado == true) {
      _carregarDados();
    }
  }

  Future<void> _finalizarSessao(SessaoEstudo sessao) async {
    try {
      final sessaoAtualizada = SessaoEstudo(
        id: sessao.id,
        materiaId: sessao.materiaId,
        provaId: sessao.provaId,
        eventoId: sessao.eventoId,
        conteudo: sessao.conteudo,
        topicos: sessao.topicos,
        tempoInicio: sessao.tempoInicio,
        tempoFim: DateTime.now(),
        createdAt: sessao.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await SessaoService.atualizarSessao(sessao.id, sessaoAtualizada);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sessão finalizada com sucesso!')),
        );
        _carregarDados();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao finalizar sessão: $e')),
        );
      }
    }
  }

  Future<void> _confirmarExclusao(SessaoEstudo sessao) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir esta sessão de estudo? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    
    if (confirmou == true) {
      await _excluirSessao(sessao);
    }
  }

  Future<void> _excluirSessao(SessaoEstudo sessao) async {
    try {
      await SessaoService.deletarSessao(sessao.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sessão excluída com sucesso!')),
        );
        _carregarDados();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir sessão: $e')),
        );
      }
    }
  }
} 