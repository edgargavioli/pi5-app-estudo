import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/card_widget.dart';
import 'package:pi5_ms_mobile/src/components/gauge_chart_widget.dart';
import 'package:pi5_ms_mobile/src/components/scaffold_widget.dart';
import 'package:pi5_ms_mobile/src/components/search_widget.dart';

class MateriasListagemPage extends StatefulWidget {
  final int provaId;

  const MateriasListagemPage({super.key, required this.provaId});

  @override
  _MateriasListagemPageState createState() => _MateriasListagemPageState();
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

    return ScaffoldWidget(
      currentPage: 3,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/materias/adicionar',
                arguments:
                    filteredMaterias.isNotEmpty ? materiasNames : <String>[],
              );
            },
            icon: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            label: Text(
              "Adicionar Matéria",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
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
                      label: "Desenpenho",
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
                          print(
                            "Abrir detalhes da matéria: ${filteredMaterias[index]}",
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
          if (_selectedIndex != null)
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = null;
                });
              },
              child: Container(color: Colors.transparent),
            ),
        ],
      ),
    );
  }
}
