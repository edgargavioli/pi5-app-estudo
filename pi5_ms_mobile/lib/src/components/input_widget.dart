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
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: style,
        textAlign: textAlign,
        maxLength: maxLength,
        maxLines: maxLines,
        minLines: minLines,
        expands: expands,
        readOnly: readOnly,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTap: onTap,
        decoration:
            decoration ??
            InputDecoration(
              labelText: labelText,
              hintText: hintText,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
      ),
    );
  }
}
