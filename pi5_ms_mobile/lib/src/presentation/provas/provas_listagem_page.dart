import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/card_widget.dart';
import 'package:pi5_ms_mobile/src/components/gauge_chart_widget.dart';
import 'package:pi5_ms_mobile/src/components/search_widget.dart';
import 'package:pi5_ms_mobile/src/presentation/materias/materias_listagem_page.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/adicionar_prova_page.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/editar_prova_page.dart';

class ProvaslistagemPage extends StatefulWidget {
  const ProvaslistagemPage({super.key});

  @override
  State<ProvaslistagemPage> createState() => _ProvaslistagemPageState();
}

class _ProvaslistagemPageState extends State<ProvaslistagemPage> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double padding = screenWidth * 0.01;

    return Center(
      child: Stack(
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
                      value: 0.5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    GaugeData(
                      label: "Nivel",
                      valueText: "150xp",
                      value: 50,
                      color: Colors.amberAccent,
                    ),
                    GaugeData(
                      label: "Desempenho",
                      valueText: "0%",
                      value: 0,
                      color: Theme.of(context).colorScheme.primary,
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
                    itemCount: 5, // Número de itens na lista
                    itemBuilder: (context, index) {
                      return CardWidget(
                        title: "Prova ${index + 1}",
                        icon: Icons.article,
                        color:
                            _selectedIndex == index
                                ? Theme.of(context).colorScheme.primaryContainer
                                : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => MateriasListagemPage(
                                    provaId: index,
                                    title: "Prova ${index + 1}",
                                  ),
                            ),
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
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_selectedIndex != null) ...[
                  FloatingActionButton(
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                    onPressed: () {
                      print("Deletar prova");
                    },
                    child: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProvaPage(),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                FloatingActionButton.extended(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdicionarProvaPage(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  label: Text(
                    "Adicionar Prova",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
