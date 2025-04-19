import 'package:flutter/material.dart';

class ButtonThemeConfig {
  static ButtonTheme btnThemeDefault({
    required BuildContext context,
    double minWidth = 303,
    double height = 40,
    double radius = 8,
    ButtonTextTheme textTheme = ButtonTextTheme.primary,
    Color? buttonColor,
    required Widget child,
  }) =>
      ButtonTheme(
        buttonColor: buttonColor ?? Theme.of(context).colorScheme.primary,
        textTheme: textTheme,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        minWidth: minWidth,
        height: height,
        child: child,
      );
}