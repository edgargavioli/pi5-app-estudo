import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/card_widget.dart';

class AdicionarMateriaPage extends StatefulWidget {
  final List<String> materias;

  const AdicionarMateriaPage({super.key, required this.materias});

  @override
  _AdicionarMateriaPageState createState() => _AdicionarMateriaPageState();
}

class _AdicionarMateriaPageState extends State<AdicionarMateriaPage> {
  final List<String> _materias = ['História', 'Matemática', 'Português'];
  late List<String> _materiasAdicionadas;
  String? _materiaSelecionada;

  @override
  void initState() {
    super.initState();
    _materiasAdicionadas = widget.materias;
    _materiaSelecionada = _materias.first;
  }

  void _adicionarMateria() {
    if (_materiaSelecionada != null &&
        !_materiasAdicionadas.contains(_materiaSelecionada)) {
      setState(() {
        _materiasAdicionadas.add(_materiaSelecionada!);
      });
    }
  }

  void _removerMateria(String materia) {
    setState(() {
      _materiasAdicionadas.remove(materia);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Gerencie suas matérias",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: theme.colorScheme.outline),
            const SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _materiaSelecionada,
                  items:
                      _materias
                          .map(
                            (materia) => DropdownMenuItem(
                              value: materia,
                              child: Text(materia),
                            ),
                          )
                          .toList()
                        ..add(
                          DropdownMenuItem(
                            value: "nova_materia",
                            child: Text(
                              "Adicionar nova matéria...",
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                  onChanged: (value) {
                    if (value == "nova_materia") {
                      // Exibe um diálogo para adicionar uma nova matéria
                      showDialog(
                        context: context,
                        builder: (context) {
                          String novaMateria = "";
                          return AlertDialog(
                            title: const Text("Adicionar nova matéria"),
                            content: TextField(
                              onChanged: (text) {
                                novaMateria = text;
                              },
                              decoration: const InputDecoration(
                                labelText: "Nome da matéria",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancelar"),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (novaMateria.isNotEmpty &&
                                      !_materias.contains(novaMateria)) {
                                    setState(() {
                                      _materias.add(novaMateria);
                                      _materiaSelecionada = novaMateria;
                                    });
                                  }
                                  Navigator.pop(context);
                                },
                                child: const Text("Adicionar"),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      setState(() {
                        _materiaSelecionada = value;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: "Selecione ou adicione uma matéria",
                    border: const OutlineInputBorder(),
                    labelStyle: theme.textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: _adicionarMateria,
                    child: Text(
                      "Adicionar matéria",
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _materiasAdicionadas.length,
                itemBuilder: (context, index) {
                  final materia = _materiasAdicionadas[index];
                  return CardWidget(
                    title: materia,
                    icon: Icons.book,
                    trailing: IconButton(
                      icon: Icon(
                        Icons.remove_circle,
                        color: theme.colorScheme.error,
                      ),
                      tooltip: 'Remover matéria',
                      onPressed: () => _removerMateria(materia),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        tooltip: 'Confirmar seleção de matérias',
        onPressed: () {
          // Lógica para confirmar as matérias selecionadas
          Navigator.pop(context, _materiasAdicionadas);
        },
        child: Icon(Icons.check, color: theme.colorScheme.onPrimary),
      ),
    );
  }
}
