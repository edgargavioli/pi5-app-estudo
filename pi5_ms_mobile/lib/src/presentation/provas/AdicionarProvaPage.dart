import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/input_widget.dart';
import '../../components/card_widget.dart';
import '../../components/scaffold_widget.dart';

class AdicionarProvaPage extends StatefulWidget {
  const AdicionarProvaPage({super.key});

  @override
  State<AdicionarProvaPage> createState() => _AdicionarProvaPageState();
}

class _AdicionarProvaPageState extends State<AdicionarProvaPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController dataProvaController = TextEditingController();
  final TextEditingController dataInicioInscricaoController =
      TextEditingController();
  final TextEditingController dataFimInscricaoController =
      TextEditingController();
  final TextEditingController materiaController = TextEditingController();

  List<String> materias = [];

  Future<void> selecionarData(TextEditingController controller) async {
    DateTime? data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (data != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(data);
    }
  }

  void adicionarMateria() {
    if (materiaController.text.isNotEmpty) {
      setState(() {
        materias.add(materiaController.text);
        materiaController.clear();
      });
    }
  }

  void removerMateria(int index) {
    setState(() {
      materias.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      currentPage: 1,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Text(
                'Adicionar Prova',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 32),
              InputWidget(
                labelText: 'Nome da prova',
                controller: nomeController,
                width: double.infinity,
              ),
              const SizedBox(height: 12),
              InputWidget(
                labelText: 'Quando vai acontecer',
                controller: dataProvaController,
                readOnly: true,
                onTap: () => selecionarData(dataProvaController),
                width: double.infinity,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Período de inscrição',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: InputWidget(
                      labelText: 'De:',
                      controller: dataInicioInscricaoController,
                      readOnly: true,
                      onTap:
                          () => selecionarData(dataInicioInscricaoController),
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InputWidget(
                      labelText: 'Até:',
                      controller: dataFimInscricaoController,
                      readOnly: true,
                      onTap: () => selecionarData(dataFimInscricaoController),
                      width: double.infinity,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InputWidget(
                labelText: 'Adicionar matérias',
                controller: materiaController,
                width: double.infinity,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: adicionarMateria,
                ),
                onSubmitted: (_) => adicionarMateria(),
              ),
              const SizedBox(height: 12),
              ...materias.asMap().entries.map((entry) {
                int idx = entry.key;
                String materia = entry.value;
                return CardWidget(
                  title: materia,
                  icon: Icons.article,
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.remove_circle,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => removerMateria(idx),
                  ),
                );
              }).toList(),
              const SizedBox(height: 80), // Espaço para o botão flutuante
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.popAndPushNamed(context, '/provas');
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.check,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}
