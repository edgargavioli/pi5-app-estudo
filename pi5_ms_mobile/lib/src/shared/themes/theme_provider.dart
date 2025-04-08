import 'package:flutter/material.dart';
import 'theme.dart';
import 'util.dart';

class ThemeProvider with ChangeNotifier {
  late ThemeData _themeData;

  ThemeProvider(Brightness brightness, BuildContext context) {
    final textTheme = createTextTheme(context, "Roboto", "Poppins");
    final theme = MaterialTheme(textTheme);
    _themeData = brightness == Brightness.light ? theme.light() : theme.dark();
  }

  ThemeData get themeData => _themeData;
}
