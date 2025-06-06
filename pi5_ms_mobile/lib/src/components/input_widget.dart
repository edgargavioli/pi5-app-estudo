import 'package:flutter/material.dart';

class InputWidget extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final double width;
  final double height;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final GestureTapCallback? onTap;
  final InputDecoration? decoration;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  const InputWidget({
    super.key,
    required this.labelText,
    this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.width = 200.0,
    this.height = 50.0,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.readOnly = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.decoration,
    this.suffixIcon,
    this.validator,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: style ?? TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        textAlign: textAlign,
        maxLength: maxLength,
        maxLines: maxLines,
        minLines: minLines,
        expands: expands,
        readOnly: readOnly,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        onTap: onTap,
        validator: validator,
        textInputAction: textInputAction,
        decoration:
            decoration ??
            InputDecoration(
              labelText: labelText,
              hintText: hintText,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: suffixIcon,
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              labelStyle: TextStyle(
                color: colorScheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: colorScheme.outline,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.7),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainer,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
      ),
    );
  }
}
