import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/scaffold_widget.dart';

class ProvasPage extends StatefulWidget {
  const ProvasPage({super.key});

  @override
  State<ProvasPage> createState() => _ProvasPageState();
}

class _ProvasPageState extends State<ProvasPage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      body: Center(
        child: Text("Provas", style: Theme.of(context).textTheme.headlineSmall),
      ),
      currentPage: 1,
    );
  }
}
