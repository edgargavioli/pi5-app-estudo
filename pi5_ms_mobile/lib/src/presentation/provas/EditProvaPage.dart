import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditProvaPage extends StatefulWidget {
  const EditProvaPage({super.key});

  @override
  _EditProvaPageState createState() => _EditProvaPageState();
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Editar Prova',
          style: TextStyle(color: Colors.black),
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
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
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
                    decoration: const InputDecoration(
                      labelText: 'De:',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: dataFimInscricaoController,
                    readOnly: true,
                    onTap: () => selecionarData(dataFimInscricaoController),
                    decoration: const InputDecoration(
                      labelText: 'Até:',
                      border: OutlineInputBorder(),
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
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.article),
                      title: Text(materias[index]),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => removerMateria(index),
                      ),
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
                  backgroundColor: const Color(0xFFD7E8FF),
                  onPressed: () {},
                  child: const Icon(Icons.check, color: Colors.black),
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
