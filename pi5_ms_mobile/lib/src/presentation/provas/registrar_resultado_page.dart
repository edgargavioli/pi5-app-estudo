import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/models/prova_model.dart';
import '../../shared/services/prova_service.dart';

class RegistrarResultadoPage extends StatefulWidget {
  final Prova prova;

  const RegistrarResultadoPage({super.key, required this.prova});

  @override
  State<RegistrarResultadoPage> createState() => _RegistrarResultadoPageState();
}

class _RegistrarResultadoPageState extends State<RegistrarResultadoPage> {
  final TextEditingController acertosController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Se já tem acertos registrados, preencher o campo
    if (widget.prova.acertos != null) {
      acertosController.text = widget.prova.acertos.toString();
    }
  }

  Future<void> _registrarResultado() async {
    if (!_validarCampos()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final acertos = int.parse(acertosController.text);

      final provaAtualizada = await ProvaService.registrarResultado(
        widget.prova.id,
        acertos,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Resultado registrado! Você acertou ${provaAtualizada.percentualAcerto}% da prova.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(
          context,
        ).pop(provaAtualizada); // Retorna a prova atualizada
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar resultado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validarCampos() {
    if (acertosController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira o número de acertos')),
      );
      return false;
    }

    final acertos = int.tryParse(acertosController.text);
    if (acertos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um número válido')),
      );
      return false;
    }

    if (acertos < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O número de acertos não pode ser negativo'),
        ),
      );
      return false;
    }

    if (widget.prova.totalQuestoes != null &&
        acertos > widget.prova.totalQuestoes!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'O número de acertos não pode ser maior que o total de questões (${widget.prova.totalQuestoes})',
          ),
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Resultado'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações da prova
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.quiz,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.prova.titulo,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (widget.prova.materia != null) ...[
                      Row(
                        children: [
                          Icon(Icons.school, color: Colors.grey[600], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.prova.materia!.nome,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    if (widget.prova.totalQuestoes != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.format_list_numbered,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Total de questões: ${widget.prova.totalQuestoes}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    if (widget.prova.foiRealizada) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Resultado já registrado: ${widget.prova.acertos}/${widget.prova.totalQuestoes} (${widget.prova.percentualAcerto}%)',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Formulário de resultado
            Text(
              widget.prova.foiRealizada
                  ? 'Atualizar Resultado'
                  : 'Registrar Resultado',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: acertosController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Número de acertos',
                hintText:
                    widget.prova.totalQuestoes != null
                        ? 'De 0 a ${widget.prova.totalQuestoes}'
                        : 'Ex: 8, 15, 20...',
                suffixIcon: const Icon(Icons.check_circle_outline),
                border: const OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),

            const SizedBox(height: 24),

            // Botão de salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registrarResultado,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text(
                          widget.prova.foiRealizada
                              ? 'Atualizar Resultado'
                              : 'Registrar Resultado',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 16),

            // Informações adicionais
            if (widget.prova.totalQuestoes == null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta prova não possui número total de questões definido. O percentual de acerto não será calculado.',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 12,
                        ),
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
}
