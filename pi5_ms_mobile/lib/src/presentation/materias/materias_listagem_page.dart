import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/card_widget.dart';
import 'package:pi5_ms_mobile/src/components/gauge_chart_widget.dart';
import 'package:pi5_ms_mobile/src/components/search_widget.dart';
import 'package:pi5_ms_mobile/src/presentation/estudos/estudos_page.dart';
import 'package:pi5_ms_mobile/src/presentation/materias/adicionar_materia_page.dart';

class MateriasListagemPage extends StatefulWidget {
  final String title;
  final int provaId;

  const MateriasListagemPage({
    super.key,
    required this.title,
    required this.provaId,
  });

  @override
  State<MateriasListagemPage> createState() => _MateriasListagemPageState();
}

class _MateriasListagemPageState extends State<MateriasListagemPage> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedIndex;

  final List<Map<String, dynamic>> _materias = [
    {'id': 1, 'nome': 'Matemática', 'provaId': 1},
    {'id': 2, 'nome': 'Português', 'provaId': 2},
    {'id': 3, 'nome': 'História', 'provaId': 1},
    {'id': 4, 'nome': 'Geografia', 'provaId': 3},
    {'id': 5, 'nome': 'Ciências', 'provaId': 2},
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double padding = screenWidth * 0.01;

    final List<Map<String, dynamic>> filteredMaterias =
        _materias
            .where((materia) => materia['provaId'] == widget.provaId)
            .toList();

    final List<String> materiasNames =
        filteredMaterias.map((materia) => materia['nome'] as String).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Volta para a página anterior
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DashboardGaugesSyncfusion(
              gauges: [
                GaugeData(
                  label: "Tempo",
                  valueText: "00h00m",
                  value: 0,
                  color: Theme.of(context).colorScheme.primary,
                ),
                GaugeData(
                  label: "Desempenho",
                  valueText: "10%",
                  value: 10,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 10),
            SearchBarWidget(
              controller: _searchController,
              onSubmitted: (value) {
                print("Pesquisando por: $value");
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredMaterias.length,
                itemBuilder: (context, index) {
                  return CardWidget(
                    title: filteredMaterias[index]['nome'],
                    icon: Icons.book,
                    color:
                        _selectedIndex == index
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EstudosPage()),
                      );
                    },
                    onLongPress: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AdicionarMateriaPage(
                    materias:
                        filteredMaterias.isNotEmpty
                            ? materiasNames
                            : <String>[],
                  ),
            ),
          );
        },
        icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
        label: Text(
          "Adicionar Matéria",
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
