import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/card_widget.dart';
import 'package:pi5_ms_mobile/src/components/gauge_chart_widget.dart';
import 'package:pi5_ms_mobile/src/components/scaffold_widget.dart';
import 'package:pi5_ms_mobile/src/components/search_widget.dart';

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

    return ScaffoldWidget(
      currentPage: 1,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_selectedIndex != null)
            FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              onPressed: () {
                print("deletar prova");
              },
              child: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: () {
              print("adicionar prova");
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
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DashboardGaugesSyncfusion(),
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
                          print("pagina da prova ${index + 1}");
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
