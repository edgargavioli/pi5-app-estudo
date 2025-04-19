import 'package:flutter/material.dart';

class AppBarThemeConfig {
  static AppBarTheme get lightTheme {
    return AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 2,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static AppBarTheme get darkTheme {
    return AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 2,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}