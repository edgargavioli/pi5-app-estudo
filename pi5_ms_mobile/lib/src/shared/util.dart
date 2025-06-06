import 'package:flutter/material.dart';

TextTheme createTextTheme(
    BuildContext context, String bodyFontString, String displayFontString) {
  TextTheme baseTextTheme = Theme.of(context).textTheme;
  
  // Usar apenas fontes locais para evitar problemas com GoogleFonts no Flutter Web
  TextTheme bodyTextTheme = _createLocalTextTheme(baseTextTheme, bodyFontString);
  TextTheme displayTextTheme = _createLocalTextTheme(baseTextTheme, displayFontString);
  
  TextTheme textTheme = displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
  );
  return textTheme;
}

TextTheme _createLocalTextTheme(TextTheme baseTheme, String fontFamily) {
  return baseTheme.copyWith(
    displayLarge: baseTheme.displayLarge?.copyWith(fontFamily: fontFamily),
    displayMedium: baseTheme.displayMedium?.copyWith(fontFamily: fontFamily),
    displaySmall: baseTheme.displaySmall?.copyWith(fontFamily: fontFamily),
    headlineLarge: baseTheme.headlineLarge?.copyWith(fontFamily: fontFamily),
    headlineMedium: baseTheme.headlineMedium?.copyWith(fontFamily: fontFamily),
    headlineSmall: baseTheme.headlineSmall?.copyWith(fontFamily: fontFamily),
    titleLarge: baseTheme.titleLarge?.copyWith(fontFamily: fontFamily),
    titleMedium: baseTheme.titleMedium?.copyWith(fontFamily: fontFamily),
    titleSmall: baseTheme.titleSmall?.copyWith(fontFamily: fontFamily),
    bodyLarge: baseTheme.bodyLarge?.copyWith(fontFamily: fontFamily),
    bodyMedium: baseTheme.bodyMedium?.copyWith(fontFamily: fontFamily),
    bodySmall: baseTheme.bodySmall?.copyWith(fontFamily: fontFamily),
    labelLarge: baseTheme.labelLarge?.copyWith(fontFamily: fontFamily),
    labelMedium: baseTheme.labelMedium?.copyWith(fontFamily: fontFamily),
    labelSmall: baseTheme.labelSmall?.copyWith(fontFamily: fontFamily),
  );
}
