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
    this.height = 65.0,
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
        style:
            style ??
            TextStyle(
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
            decoration?.copyWith(
              labelText: decoration?.labelText ?? labelText,
              hintText: decoration?.hintText ?? hintText,
              floatingLabelBehavior:
                  decoration?.floatingLabelBehavior ??
                  FloatingLabelBehavior.always,
              suffixIcon: decoration?.suffixIcon ?? suffixIcon,
              hintStyle:
                  decoration?.hintStyle ??
                  TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
              labelStyle:
                  decoration?.labelStyle ??
                  TextStyle(
                    color: colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
              border:
                  decoration?.border ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
              enabledBorder:
                  decoration?.enabledBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
              focusedBorder:
                  decoration?.focusedBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2.0,
                    ),
                  ),
              errorBorder:
                  decoration?.errorBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 2.0,
                    ),
                  ),
              focusedErrorBorder:
                  decoration?.focusedErrorBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 2.0,
                    ),
                  ),
              filled: decoration?.filled ?? true,
              fillColor: decoration?.fillColor ?? colorScheme.surfaceContainer,
              contentPadding:
                  decoration?.contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ) ??
            InputDecoration(
              labelText: labelText,
              hintText: hintText,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: suffixIcon,
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              labelStyle: TextStyle(
                color: colorScheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: colorScheme.outline, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: colorScheme.error, width: 2.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: colorScheme.error, width: 2.0),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainer,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
            ),
      ),
    );
  }
}
