import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onSubmitted;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          prefixIcon: GestureDetector(
            onTap: () {
              print("Filtro pressionado");
            },
            child: Icon(
              Icons.filter_list,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          suffixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          hintText: 'Pesquisar...',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
