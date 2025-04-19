import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final RoundedRectangleBorder? shape;

  const ButtonWidget({
    super.key,
    required this.text,
    this.textStyle,
    required this.onPressed,
    this.shape,
    this.padding,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorSelected = color ?? Theme.of(context).colorScheme.primary;
    final textColorSelected = textColor ?? Theme.of(context).colorScheme.onPrimary;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorSelected,
        foregroundColor: textColorSelected,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: shape ?? RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: textStyle ?? Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}