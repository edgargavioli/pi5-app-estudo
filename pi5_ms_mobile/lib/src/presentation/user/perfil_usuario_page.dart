import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'dart:typed_data';
import '../../shared/services/auth_service.dart';
import '../../shared/services/gamificacao_backend_service.dart';
import '../../shared/services/user_service.dart';
import '../../shared/services/prova_service.dart';
import '../../shared/models/user_model.dart';
import '../../shared/models/prova_model.dart';
import '../../shared/widgets/custom_snackbar.dart';
import 'dart:math';

class PerfilUsuarioPage extends StatefulWidget {
  const PerfilUsuarioPage({super.key});

  @override
  State<PerfilUsuarioPage> createState() => _PerfilUsuarioPageState();
}

class _PerfilUsuarioPageState extends State<PerfilUsuarioPage>
    with WidgetsBindingObserver {
  Map<String, dynamic> _estatisticasGamificacao = {};
  bool _carregandoGamificacao = true;
  bool _carregandoUsuario = true;
  bool _editando = false;
  bool _salvando = false;
  bool _carregandoFoto = false;
  late TextEditingController _nomeController;
  late TextEditingController _emailController;

  UserModel? _usuario;
  final ImagePicker _picker = ImagePicker();
  String? _novaFotoBase64;
  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _emailController = TextEditingController();
    WidgetsBinding.instance.addObserver(this);
    _carregarDados();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Recarregar dados quando o app volta ao foco
      _carregarDados();
    }
  }

  /// Calcular XP que falta para o próximo nível
  int _calcularXPParaProximoNivel(int nivelAtual, int xpTotal) {
    if (nivelAtual >= 100) return 0;

    // Calcular XP necessário para o próximo nível
    const baseXP = 100;
    const multiplier = 1.5;
    final xpParaProximoNivel = (baseXP * pow(multiplier, nivelAtual)).floor();

    // Calcular XP atual no nível
    int xpGasto = 0;
    for (int i = 1; i < nivelAtual; i++) {
      xpGasto += (baseXP * pow(multiplier, i - 1)).floor();
    }
    final xpAtualNoNivel = xpTotal - xpGasto;

    // Retornar XP que falta
    return xpParaProximoNivel - xpAtualNoNivel;
  }

  /// Selecionar e compactar imagem de perfil
  Future<void> _selecionarFotoPerfil() async {
    // Mostrar modal com opções de câmera ou galeria
    final ImageSource? source = await _mostrarOpcoesImagem();

    if (source == null) return;

    try {
      setState(() => _carregandoFoto = true);

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 70,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();

        // Compactar ainda mais a imagem
        final compressedBytes = await _compressImage(bytes);

        // Converter para base64
        final base64String = base64Encode(compressedBytes);

        setState(() {
          _novaFotoBase64 = base64String;
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Erro ao selecionar imagem: $e';

        // Tratar erros específicos
        if (e.toString().contains('permission')) {
          errorMessage =
              'Permissão negada para acessar ${source == ImageSource.camera ? 'câmera' : 'galeria'}';
        } else if (e.toString().contains('camera')) {
          errorMessage =
              'Erro ao acessar a câmera. Verifique se o dispositivo possui câmera.';
        }

        CustomSnackBar.showError(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _carregandoFoto = false);
      }
    }
  }

  /// Mostrar modal com opções de imagem (câmera ou galeria)
  Future<ImageSource?> _mostrarOpcoesImagem() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle do modal
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Título
              Text(
                'Escolher foto de perfil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),

              // Opção câmera
              _buildOpcaoImagem(
                icon: Icons.camera_alt,
                titulo: 'Tirar foto',
                subtitulo: 'Usar câmera do dispositivo',
                onTap: () => Navigator.pop(context, ImageSource.camera),
                color: colorScheme.primary,
              ),

              const SizedBox(height: 12),

              // Opção galeria
              _buildOpcaoImagem(
                icon: Icons.photo_library,
                titulo: 'Escolher da galeria',
                subtitulo: 'Selecionar foto existente',
                onTap: () => Navigator.pop(context, ImageSource.gallery),
                color: colorScheme.tertiary,
              ),

              // Opção remover foto (se existir)
              if (_usuario?.imageBase64?.isNotEmpty == true ||
                  _novaFotoBase64 != null) ...[
                const SizedBox(height: 12),
                _buildOpcaoImagem(
                  icon: Icons.delete_outline,
                  titulo: 'Remover foto',
                  subtitulo: 'Usar avatar padrão',
                  onTap: () {
                    setState(() {
                      _novaFotoBase64 = " ";
                    });
                    Navigator.pop(context);
                  },
                  color: colorScheme.error,
                ),
              ],

              const SizedBox(height: 12),

              // Botão cancelar
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Espaçamento para safe area
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  /// Widget para opção de imagem no modal
  Widget _buildOpcaoImagem({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  /// Compactar imagem para reduzir tamanho
  Future<Uint8List> _compressImage(Uint8List bytes) async {
    // Decodificar imagem
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return bytes;

    // Redimensionar para no máximo 300x300 mantendo proporção
    img.Image resized = img.copyResize(
      image,
      width: 300,
      height: 300,
      interpolation: img.Interpolation.linear,
    );

    // Comprimir como JPEG com qualidade 60
    return Uint8List.fromList(img.encodeJpg(resized, quality: 60));
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

      print('🔍 Debug - UserID: $userId');

      if (userId != null) {
        final usuario = await UserService.obterUsuario(userId);
        print(
          '🔍 Debug - Usuario carregado: ${usuario.nome}, ${usuario.email}',
        );

        if (mounted) {
          setState(() {
            _usuario = usuario;
            _nomeController.text = usuario.nome ?? '';
            _emailController.text = usuario.email ?? '';
            _carregandoUsuario = false;
          });
        }
      } else {
        print('🔍 Debug - UserID é null');
        if (mounted) {
          setState(() => _carregandoUsuario = false);
          CustomSnackBar.showError(context, 'Usuário não encontrado');
        }
      } // Carregar estatísticas do backend (completas)
      final stats =
          await GamificacaoBackendService.obterEstatisticasCompletas();
      print('🔍 Debug - Estatísticas carregadas: $stats');

      // Carregar provas para calcular provas realizadas
      final provas = await ProvaService.listarProvas();
      final provasRealizadas =
          provas.where((prova) => prova.status == StatusProva.CONCLUIDA).length;
      print('🔍 Debug - Provas realizadas calculadas: $provasRealizadas');

      if (mounted) {
        setState(() {
          _estatisticasGamificacao = stats ?? {};
          // Adicionar provas realizadas às estatísticas
          _estatisticasGamificacao['provasRealizadas'] = provasRealizadas;
          _carregandoGamificacao = false;
        });
      }
    } catch (e) {
      print('🔍 Debug - Erro ao carregar dados: $e');
      if (mounted) {
        setState(() {
          _carregandoGamificacao = false;
          _carregandoUsuario = false;
        });
        CustomSnackBar.showError(context, 'Erro ao carregar dados: $e');
      }
    }
  }

  Future<void> _salvarPerfil() async {
    if (_usuario == null) return;

    setState(() => _salvando = true);

    try {
      final usuarioAtualizado = UserModel(
        id: _usuario!.id,
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        points: _usuario!.points,
        isEmailVerified: _usuario!.isEmailVerified,
        lastLogin: _usuario!.lastLogin,
        createdAt: _usuario!.createdAt,
        updatedAt: DateTime.now(),
        imageBase64: _novaFotoBase64 ?? _usuario!.imageBase64,
      );

      print('🔄 Salvando usuário: ${usuarioAtualizado.toJson()}');

      final resultado = await UserService.atualizarUsuario(usuarioAtualizado);

      if (mounted) {
        setState(() {
          _usuario = resultado;
          _editando = false;
          _novaFotoBase64 = null;
          _salvando = false;
        });
        CustomSnackBar.showSuccess(context, 'Perfil atualizado com sucesso!');
      }
    } catch (e) {
      print('❌ Erro ao salvar perfil: $e');
      if (mounted) {
        setState(() => _salvando = false);
        CustomSnackBar.showError(context, 'Erro ao atualizar perfil: $e');
      }
    }
  }

  Widget _buildProfileHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar com botão de edição
            Stack(
              children: [
                GestureDetector(
                  onTap: _editando ? _selecionarFotoPerfil : null,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: _getProfileImage(),
                      child:
                          _getProfileImage() == null
                              ? Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white.withOpacity(0.8),
                              )
                              : null,
                    ),
                  ),
                ),
                if (_editando)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child:
                          _carregandoFoto
                              ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                              : IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: _selecionarFotoPerfil,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20), // Nome e email
            Text(
              _usuario?.nome ?? 'Usuário',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _usuario?.email ?? 'email@exemplo.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),

            const SizedBox(height: 8),

            // Mostrar XP do usuário se disponível
            if (_usuario?.points != null && _usuario!.points > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber.shade300),
                    const SizedBox(width: 6),
                    Text(
                      '${_usuario!.points} XP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(
              height: 20,
            ), // Informações adicionais - simplificadas
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _usuario?.isEmailVerified == true
                        ? 'Email Verificado'
                        : 'Estudante',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Obter imagem de perfil
  ImageProvider? _getProfileImage() {
    // Priorizar nova foto selecionada
    if (_novaFotoBase64 != null) {
      // Se é string vazia, significa que foi removida
      if (_novaFotoBase64!.isEmpty) {
        return null;
      }

      try {
        final bytes = base64Decode(_novaFotoBase64!);
        return MemoryImage(bytes);
      } catch (e) {
        print("");
      }
    }

    // Usar foto existente do usuário
    if (_usuario?.imageBase64?.isNotEmpty == true) {
      try {
        final bytes = base64Decode(_usuario!.imageBase64!);
        return MemoryImage(bytes);
      } catch (e) {
        print('Erro ao decodificar foto do usuário: $e');
      }
    }

    return null;
  }

  Widget _buildProfileForm() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header da seção
            Row(
              children: [
                Icon(Icons.edit_note, color: colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _editando ? 'Editando Perfil' : 'Informações Pessoais',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_editando ? Icons.close : Icons.edit),
                  color: colorScheme.primary,
                  tooltip: _editando ? 'Cancelar edição' : 'Editar perfil',
                  onPressed: () {
                    setState(() => _editando = !_editando);
                    if (!_editando) {
                      // Restaurar valores originais se cancelar edição
                      _nomeController.text = _usuario?.nome ?? '';
                      _emailController.text = _usuario?.email ?? '';
                      _novaFotoBase64 = null;
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Campos do formulário
            _buildModernTextField(
              controller: _nomeController,
              label: 'Nome Completo',
              icon: Icons.person_outline,
              enabled: _editando,
            ),

            const SizedBox(height: 16),
            _buildModernTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              enabled: _editando,
              keyboardType: TextInputType.emailAddress,
            ),

            if (_editando) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _salvando ? null : _salvarPerfil,
                  icon:
                      _salvando
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Icon(Icons.save_outlined),
                  label: Text(_salvando ? 'Salvando...' : 'Salvar Alterações'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Campo de texto moderno
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color:
            enabled
                ? colorScheme.surface
                : colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              enabled
                  ? colorScheme.outline.withOpacity(0.5)
                  : colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        style: TextStyle(
          color: enabled ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: enabled ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          labelStyle: TextStyle(
            color: enabled ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card de estatísticas moderno
  Widget _buildModernStatsCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surfaceContainerHighest.withOpacity(0.3),
              colorScheme.surface,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Suas Estatísticas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Grid de estatísticas principais
              Row(
                children: [
                  _buildStatBox(
                    Icons.local_fire_department,
                    '${_estatisticasGamificacao['sessoesFinalizadas'] ?? 0}',
                    'Sessões\nFinalizadas',
                    Colors.orange,
                  ),
                  const SizedBox(width: 16),
                  _buildStatBox(
                    Icons.flash_on,
                    '${_estatisticasGamificacao['nivel'] ?? 1}',
                    'Nível\nAtual',
                    colorScheme.primary,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  _buildStatBox(
                    Icons.star,
                    '${_estatisticasGamificacao['xpTotal'] ?? 0}',
                    'XP\nTotal',
                    Colors.amber,
                  ),
                  const SizedBox(width: 16),
                  _buildStatBox(
                    Icons.trending_up,
                    '${(_estatisticasGamificacao['desempenhoMedio'] ?? 0.0).toStringAsFixed(1)}%',
                    'Desempenho\nMédio',
                    colorScheme.tertiary,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Lista de estatísticas detalhadas
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildDetailedStatRow(
                      'Total de Sessões',
                      '${_estatisticasGamificacao['totalSessoes'] ?? 0}',
                      Icons.school_outlined,
                    ),
                    _buildDetailedStatRow(
                      'Tempo Total de Estudo',
                      _estatisticasGamificacao['tempoTotalFormatado'] ?? '0min',
                      Icons.timer_outlined,
                    ),
                    _buildDetailedStatRow(
                      'Provas Realizadas',
                      '${_estatisticasGamificacao['provasRealizadas'] ?? 0}',
                      Icons.quiz_outlined,
                    ),
                    _buildDetailedStatRow(
                      'XP para Próximo Nível',
                      '${_calcularXPParaProximoNivel(_estatisticasGamificacao['nivel'] ?? 1, _estatisticasGamificacao['xpTotal'] ?? 0)}',
                      Icons.trending_up_outlined,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Linha de estatística detalhada
  Widget _buildDetailedStatRow(
    String label,
    String value,
    IconData icon, {
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border:
            isLast
                ? null
                : Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
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
                          const SizedBox(height: 20),
                          _buildProfileForm(),
                          const SizedBox(height: 24),
                          _buildModernStatsCard(),
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
}
