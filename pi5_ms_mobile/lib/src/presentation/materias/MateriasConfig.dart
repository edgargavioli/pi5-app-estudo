import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/card_widget.dart';

class ConfigMateriaPage extends StatefulWidget {
  final List<String> materias;

  const ConfigMateriaPage({super.key, required this.materias});

  @override
  _ConfigMateriaPageState createState() => _ConfigMateriaPageState();
}

class _ConfigMateriaPageState extends State<ConfigMateriaPage> {
  final List<String> _materias = ['História', 'Matemática', 'Português'];
  final List<String> _materiasNaoUsadas = ['Geografia', 'Física'];
  late List<String> _materiasAdicionadas;
  String? _materiaSelecionada;
  String _filtroSelecionado = 'Todas as Provas';

  @override
  void initState() {
    super.initState();
    _materiasAdicionadas = ['Geografia', 'História'];
    _materiaSelecionada = _materias.first;
  }

  void _adicionarMateriaNaoUsada() {
    if (_materiaSelecionada != null &&
        !_materiasNaoUsadas.contains(_materiaSelecionada!) &&
        !_materiasAdicionadas.contains(_materiaSelecionada!)) {
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

  void _removerMateriaNaoUsada(String materiaNaoUsada) {
    setState(() {
      _materiasNaoUsadas.remove(materiaNaoUsada);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredMaterias = _materiasAdicionadas.where((materia) {
      if (_filtroSelecionado == 'Todas as Provas') {
        return true;
      } else if (_filtroSelecionado == 'Apenas principais') {
        return materia.contains('Matéria') || materia.contains('Português');
      } else if (_filtroSelecionado == 'Apenas secundárias') {
        return !(materia.contains('Matéria') || materia.contains('História'));
      }
      return true;
    }).toList();

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
                "Configurações - Matérias",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: theme.colorScheme.outline),
            const SizedBox(height: 12),

            // Dropdown de seleção de matéria
            DropdownButtonFormField<String>(
              value: _materiaSelecionada,
              items: _materias
                  .map((materia) => DropdownMenuItem(
                        value: materia,
                        child: Text(materia),
                      ))
                  .toList()
                ..add(
                  DropdownMenuItem(
                    value: "nova_materia",
                    child: Text(
                      "Adicionar nova matéria...",
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
              onChanged: (value) {
                if (value == "nova_materia") {
                  showDialog(
                    context: context,
                    builder: (context) {
                      String novaMateria = "";
                      return AlertDialog(
                        title: const Text("Adicionar nova matéria"),
                        content: TextField(
                          onChanged: (text) => novaMateria = text,
                          decoration: const InputDecoration(
                            labelText: "Nome da matéria",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
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
                  setState(() => _materiaSelecionada = value);
                }
              },
              decoration: InputDecoration(
                labelText: "Criar matéria",
                border: const OutlineInputBorder(),
                labelStyle: theme.textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 12),

            // Botão adicionar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: _adicionarMateriaNaoUsada,
                child: Text(
                  "Adicionar matéria",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Filtro e matérias por vestibular
            Center(
              child: Text(
                "Matérias por vestibular",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: theme.colorScheme.outline),
            const SizedBox(height: 12),

            // Filtro de matérias (Dropdown)
            DropdownButtonFormField<String>(
              value: _filtroSelecionado,
              onChanged: (value) {
                setState(() => _filtroSelecionado = value!);
              },
              decoration: InputDecoration(
                labelText: 'Filtrar matérias',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Todas as Provas',
                  child: Text('Todas as Provas'),
                ),
                DropdownMenuItem(
                  value: 'Apenas principais',
                  child: Text('Prova Português'),
                ),
                DropdownMenuItem(
                  value: 'Apenas secundárias',
                  child: Text('Prova História'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de matérias por vestibular
            Expanded(
              child: ListView.builder(
                itemCount: filteredMaterias.length,
                itemBuilder: (context, index) {
                  final materia = filteredMaterias[index];
                  return CardWidget(
                    title: materia,
                    icon: Icons.book,
                    trailing: IconButton(
                      icon: Icon(
                        Icons.remove_circle,
                        color: theme.colorScheme.error,
                      ),
                      onPressed: () => _removerMateria(materia),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Matérias não utilizadas
            Center(
              child: Text(
                "Matérias por não utilizadas",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: theme.colorScheme.outline),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: _materiasNaoUsadas.length,
                itemBuilder: (context, index) {
                  final materiaNaoUsada = _materiasNaoUsadas[index];
                  return CardWidget(
                    title: materiaNaoUsada,
                    icon: Icons.book,
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: theme.colorScheme.error,
                      ),
                      onPressed: () =>
                          _removerMateriaNaoUsada(materiaNaoUsada),
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
        onPressed: () {
          Navigator.pop(context, _materiasAdicionadas);
        },
        child: Icon(Icons.check, color: theme.colorScheme.onPrimary),
      ),
    );
  }
}
