import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/card_widget.dart';
import 'package:pi5_ms_mobile/src/components/input_widget.dart';
import 'package:pi5_ms_mobile/src/components/scaffold_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      body: Center(
        child: Column(
          children: [
            Text("Teste do input"),
            const SizedBox(height: 20),
            Center(
              child: InputWidget(
                labelText: "Nome",
                hintText: "Digite seu nome",
                controller: TextEditingController(),
              ),
            ),
            const SizedBox(height: 20),
            Text("Teste Card"),
            CardWidget(icon: Icon(Icons.home), width: 80.0, height: 45.0),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
      currentPage: _selectedIndex,
    );
  }
}
