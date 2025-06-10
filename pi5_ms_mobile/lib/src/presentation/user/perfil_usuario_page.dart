import 'package:flutter/material.dart';
import '../../components/card_widget.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/gamificacao_service.dart';
import '../../shared/services/user_service.dart';
import '../../shared/models/user_model.dart';

class PerfilUsuarioPage extends StatefulWidget {
  const PerfilUsuarioPage({super.key});

  @override
  State<PerfilUsuarioPage> createState() => _PerfilUsuarioPageState();
}

class _PerfilUsuarioPageState extends State<PerfilUsuarioPage> {
  Map<String, dynamic> _estatisticasGamificacao = {};
  bool _carregandoGamificacao = true;
  bool _carregandoUsuario = true;
  bool _editando = false;
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _cursoController;
  late TextEditingController _instituicaoController;
  late TextEditingController _semestreController;
  UserModel? _usuario;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _emailController = TextEditingController();
    _cursoController = TextEditingController();
    _instituicaoController = TextEditingController();
    _semestreController = TextEditingController();
    _carregarDados();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cursoController.dispose();
    _instituicaoController.dispose();
    _semestreController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _carregandoGamificacao = true;
      _carregandoUsuario = true;
    });

    try {
      // Carregar dados do usuário
      final authService = AuthService();
      final userId = authService.currentUser?.id;
      if (userId != null) {
        final usuario = await UserService.obterUsuario(userId);
        if (mounted) {
          setState(() {
            _usuario = usuario;
            _nomeController.text = usuario.nome ?? '';
            _emailController.text = usuario.email ?? '';
            _cursoController.text = usuario.curso ?? '';
            _instituicaoController.text = usuario.instituicao ?? '';
            _semestreController.text = usuario.semestre?.toString() ?? '';
            _carregandoUsuario = false;
          });
        }
      }

      // Carregar estatísticas
      final stats = await GamificacaoService.obterEstatisticasCompletas();
      if (mounted) {
        setState(() {
          _estatisticasGamificacao = stats;
          _carregandoGamificacao = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _carregandoGamificacao = false;
          _carregandoUsuario = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
      }
    }
  }

  Future<void> _salvarPerfil() async {
    if (_usuario == null) return;

    setState(() => _carregandoUsuario = true);
    try {
      final usuarioAtualizado = UserModel(
        id: _usuario!.id,
        nome: _nomeController.text,
        email: _emailController.text,
        curso: _cursoController.text,
        instituicao: _instituicaoController.text,
        semestre: int.tryParse(_semestreController.text),
        createdAt: _usuario!.createdAt,
        updatedAt: DateTime.now(),
      );

      final resultado = await UserService.atualizarUsuario(usuarioAtualizado);

      if (mounted) {
        setState(() {
          _usuario = resultado;
          _editando = false;
          _carregandoUsuario = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregandoUsuario = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar perfil: $e')));
      }
    }
  }

  Widget _buildProfileHeader() {
    return Stack(
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    _usuario?.nome?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _usuario?.nome ?? 'Usuário',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _usuario?.email ?? 'email@exemplo.com',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(_editando ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() => _editando = !_editando);
              if (!_editando) {
                // Restaurar valores originais se cancelar edição
                _nomeController.text = _usuario?.nome ?? '';
                _emailController.text = _usuario?.email ?? '';
                _cursoController.text = _usuario?.curso ?? '';
                _instituicaoController.text = _usuario?.instituicao ?? '';
                _semestreController.text = _usuario?.semestre?.toString() ?? '';
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nomeController,
              enabled: _editando,
              decoration: const InputDecoration(
                labelText: 'Nome',
                icon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              enabled: _editando,
              decoration: const InputDecoration(
                labelText: 'Email',
                icon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cursoController,
              enabled: _editando,
              decoration: const InputDecoration(
                labelText: 'Curso',
                icon: Icon(Icons.school),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _instituicaoController,
              enabled: _editando,
              decoration: const InputDecoration(
                labelText: 'Instituição',
                icon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _semestreController,
              enabled: _editando,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Semestre',
                icon: Icon(Icons.calendar_today),
              ),
            ),
            if (_editando) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvarPerfil,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Salvar Alterações'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Perfil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Divider(
                thickness: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(height: 4),
              if (_carregandoUsuario || _carregandoGamificacao)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _carregarDados,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _buildProfileHeader(),
                          const SizedBox(height: 16),
                          _buildProfileForm(),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              _buildStatBox(
                                Icons.local_fire_department,
                                '${_estatisticasGamificacao['sessoesFinalizadas'] ?? 0}',
                                'Sessões\nFinalizadas',
                              ),
                              const SizedBox(width: 12),
                              _buildStatBox(
                                Icons.flash_on,
                                '${_estatisticasGamificacao['nivel'] ?? 1}',
                                'Nível\nAtual',
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Suas Estatísticas',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildStatRow(
                                    'Total de Sessões',
                                    '${_estatisticasGamificacao['totalSessoes'] ?? 0}',
                                    Icons.school,
                                  ),
                                  _buildStatRow(
                                    'Tempo Total de Estudo',
                                    _estatisticasGamificacao['tempoTotalFormatado'] ??
                                        '0min',
                                    Icons.timer,
                                  ),
                                  _buildStatRow(
                                    'Provas Realizadas',
                                    '${_estatisticasGamificacao['provasRealizadas'] ?? 0}',
                                    Icons.quiz,
                                  ),
                                  _buildStatRow(
                                    'Desempenho Médio',
                                    '${(_estatisticasGamificacao['desempenhoMedio'] ?? 0.0).toStringAsFixed(1)}%',
                                    Icons.trending_up,
                                  ),
                                  _buildStatRow(
                                    'XP Total',
                                    '${_estatisticasGamificacao['xpTotal'] ?? 0}',
                                    Icons.star,
                                  ),
                                  _buildStatRow(
                                    'XP para Próximo Nível',
                                    '${_estatisticasGamificacao['xpParaProximoNivel'] ?? 0}',
                                    Icons.trending_up,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
