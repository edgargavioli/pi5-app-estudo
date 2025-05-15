import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pi5_ms_mobile/src/components/card_widget.dart';

class EditProvaPage extends StatefulWidget {
  const EditProvaPage({super.key});

  @override
  State<EditProvaPage> createState() => _EditProvaPageState();
}

class _EditProvaPageState extends State<EditProvaPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController dataProvaController = TextEditingController();
  final TextEditingController dataInicioInscricaoController =
      TextEditingController();
  final TextEditingController dataFimInscricaoController =
      TextEditingController();
  final TextEditingController materiaController = TextEditingController();

  List<String> materias = ['Matéria 1'];

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

  Future<void> selecionarData(TextEditingController controller) async {
    DateTime? data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (data != null) {
      final formato = DateFormat('dd/MM/yyyy');
      controller.text = formato.format(data);
    }
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
          'Editar Prova',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            campoTexto('Nome da prova', nomeController),
            const SizedBox(height: 12),
            campoTextoData('Quando vai acontecer', dataProvaController),
            const SizedBox(height: 12),

            // Período de inscrição com "De: Até:"
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Período de inscrição',
                style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: dataInicioInscricaoController,
                    readOnly: true,
                    onTap: () => selecionarData(dataInicioInscricaoController),
                    decoration: InputDecoration(
                      labelText: 'De:',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: dataFimInscricaoController,
                    readOnly: true,
                    onTap: () => selecionarData(dataFimInscricaoController),
                    decoration: InputDecoration(
                      labelText: 'Até:',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            TextField(
              controller: materiaController,
              decoration: InputDecoration(
                labelText: 'Adicionar matérias',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: adicionarMateria,
                ),
              ),
            ),

            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: materias.length,
                itemBuilder: (context, index) {
                  return CardWidget(
                    title: materias[index],
                    icon: Icons.book,
                    trailing: IconButton(
                      color: colorScheme.error,
                      icon: Icon(Icons.remove_circle, color: colorScheme.error),
                      onPressed: () => removerMateria(index),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: FloatingActionButton(
                  backgroundColor: colorScheme.primary,
                  onPressed: () {
                    // Salvar alterações
                  },
                  child: Icon(Icons.check, color: colorScheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget campoTexto(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget campoTextoData(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () => selecionarData(controller),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

// Tela de editar prova
