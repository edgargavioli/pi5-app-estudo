import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onSubmitted;
  final Function(String)? onChanged;
  final String? hintText;
  final VoidCallback? onFilterPressed;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onSubmitted,
    this.onChanged,
    this.hintText,
    this.onFilterPressed,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_updateHasText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateHasText);
    super.dispose();
  }

  void _updateHasText() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

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
        controller: widget.controller,
        onSubmitted: widget.onSubmitted,
        onChanged: widget.onChanged,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          prefixIcon: GestureDetector(
            onTap: widget.onFilterPressed ?? () {
              // Se não houver callback específico, usar o que já existe
              print("Filtro pressionado");
            },
            child: Icon(
              Icons.filter_list,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          suffixIcon: _hasText
              ? GestureDetector(
                  onTap: () {
                    widget.controller.clear();
                    widget.onChanged?.call('');
                    widget.onSubmitted?.call('');
                  },
                  child: Icon(
                    Icons.clear,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                )
              : Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          hintText: widget.hintText ?? 'Pesquisar...',
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
