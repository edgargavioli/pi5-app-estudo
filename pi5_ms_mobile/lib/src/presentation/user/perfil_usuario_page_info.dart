import 'package:flutter/material.dart';
import '../../components/input_widget.dart';
import '../../components/button_widget.dart';

class UserProfilePageInfo extends StatefulWidget {
  const UserProfilePageInfo({super.key});

  @override
  State<UserProfilePageInfo> createState() => _UserProfilePageInfoState();
}

class _UserProfilePageInfoState extends State<UserProfilePageInfo> {
  final TextEditingController nomeController = TextEditingController(
    text: 'Edgar Gavioli',
  );
  final TextEditingController usuarioController = TextEditingController(
    text: '@edgar_gavioli',
  );
  final String email = 'edgargavioli@gmail.com';

  bool editandoNome = false;
  bool editandoUsuario = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: AssetImage('assets/avatar.png'),
                      ),
                      const SizedBox(height: 8),
                      ButtonWidget(
                        text: 'Alterar foto',
                        onPressed: () {
                          // Implementar troca de foto
                        },
                        color: Theme.of(context).colorScheme.surface,
                        textColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildEditableField(
                  icon: Icons.person,
                  label: 'Nome',
                  controller: nomeController,
                  editando: editandoNome,
                  onEdit: () => setState(() => editandoNome = true),
                  onSave: () => setState(() => editandoNome = false),
                ),
                const SizedBox(height: 12),
                _buildEditableField(
                  icon: Icons.account_circle,
                  label: 'Nome de usuário',
                  controller: usuarioController,
                  editando: editandoUsuario,
                  onEdit: () => setState(() => editandoUsuario = true),
                  onSave: () => setState(() => editandoUsuario = false),
                ),
                const SizedBox(height: 12),
                _buildInfoField(Icons.email, 'Email', email),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => _showChangePasswordDialog(context),
                    child: const Text(
                      'Alterar senha',
                      style: TextStyle(
                        color: Color(0xFF3B5B82),
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFD7E8FF),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.check, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool editando,
    required VoidCallback onEdit,
    required VoidCallback onSave,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child:
              editando
                  ? Row(
                    children: [
                      Expanded(
                        child: InputWidget(
                          labelText: label,
                          controller: controller,
                          width: double.infinity,
                          onSubmitted: (_) => onSave(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: onSave,
                      ),
                    ],
                  )
                  : GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        controller.text,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
        ),
        if (!editando)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.grey),
            onPressed: onEdit,
          ),
      ],
    );
  }

  Widget _buildInfoField(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController atualController = TextEditingController();
    final TextEditingController novaController = TextEditingController();
    final TextEditingController confirmarController = TextEditingController();
    bool obscureAtual = true;
    bool obscureNova = true;
    bool obscureConfirmar = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Alterar senha', textAlign: TextAlign.center),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputWidget(
                      labelText: 'Senha Atual',
                      controller: atualController,
                      obscureText: obscureAtual,
                      width: double.infinity,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureAtual
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed:
                            () => setState(() => obscureAtual = !obscureAtual),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InputWidget(
                      labelText: 'Nova Senha',
                      controller: novaController,
                      obscureText: obscureNova,
                      width: double.infinity,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNova ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed:
                            () => setState(() => obscureNova = !obscureNova),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InputWidget(
                      labelText: 'Confirmar Senha',
                      controller: confirmarController,
                      obscureText: obscureConfirmar,
                      width: double.infinity,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirmar
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed:
                            () => setState(
                              () => obscureConfirmar = !obscureConfirmar,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                ButtonWidget(
                  text: 'Cancelar',
                  color: Theme.of(context).colorScheme.surface,
                  textColor: Theme.of(context).colorScheme.error,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ButtonWidget(
                  text: 'Confirmar',
                  color: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  onPressed: () {
                    // Validar e salvar nova senha
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
