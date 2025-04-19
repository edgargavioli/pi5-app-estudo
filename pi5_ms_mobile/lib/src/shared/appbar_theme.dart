import 'package:flutter/material.dart';

class AppBarThemeConfig {
  static AppBarTheme lightTheme(BuildContext context) => AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 2,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );

  static AppBarTheme darkTheme(BuildContext context) => AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 2,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );
}