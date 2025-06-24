import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final RoundedRectangleBorder? shape;
  final bool isLoading;
  final double? height;
  final double? width;

  const ButtonWidget({
    super.key,
    required this.text,
    this.textStyle,
    required this.onPressed,
    this.shape,
    this.padding,
    this.color,
    this.textColor,
    this.isLoading = false,
    this.height,
    this.width,
  });
  @override
  Widget build(BuildContext context) {
    final colorSelected = color ?? Theme.of(context).colorScheme.primary;
    final textColorSelected =
        textColor ?? Theme.of(context).colorScheme.onPrimary;

    return SizedBox(
      height: height ?? 56.0,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorSelected,
          foregroundColor: textColorSelected,
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          shape:
              shape ??
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          elevation: 2.0,
          shadowColor: colorSelected.withValues(alpha: 0.3),
        ),
        onPressed: isLoading ? null : onPressed,
        child:
            isLoading
                ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      textColorSelected,
                    ),
                  ),
                )
                : Text(
                  text,
                  style:
                      textStyle ??
                      TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColorSelected,
                      ),
                ),
      ),
    );
  }
}
