import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff3a608f),
      surfaceTint: Color(0xff3a608f),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffd3e3ff),
      onPrimaryContainer: Color(0xff1f4876),
      secondary: Color(0xff3a608f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffd3e4ff),
      onSecondaryContainer: Color(0xff1e4876),
      tertiary: Color(0xff1d6586),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffc4e7ff),
      onTertiaryContainer: Color(0xff004c69),
      error: Color(0xff904a43),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad5),
      onErrorContainer: Color(0xff73342d),
      surface: Color(0xfff8f9ff),
      onSurface: Color(0xff191c20),
      onSurfaceVariant: Color(0xff43474e),
      outline: Color(0xff73777f),
      outlineVariant: Color(0xffc3c6cf),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3035),
      inversePrimary: Color(0xffa4c9fe),
      primaryFixed: Color(0xffd3e3ff),
      onPrimaryFixed: Color(0xff001c39),
      primaryFixedDim: Color(0xffa4c9fe),
      onPrimaryFixedVariant: Color(0xff1f4876),
      secondaryFixed: Color(0xffd3e4ff),
      onSecondaryFixed: Color(0xff001c38),
      secondaryFixedDim: Color(0xffa3c9fe),
      onSecondaryFixedVariant: Color(0xff1e4876),
      tertiaryFixed: Color(0xffc4e7ff),
      onTertiaryFixed: Color(0xff001e2c),
      tertiaryFixedDim: Color(0xff90cef4),
      onTertiaryFixedVariant: Color(0xff004c69),
      surfaceDim: Color(0xffd9dae0),
      surfaceBright: Color(0xfff8f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff2f3fa),
      surfaceContainer: Color(0xffededf4),
      surfaceContainerHigh: Color(0xffe7e8ee),
      surfaceContainerHighest: Color(0xffe1e2e9),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff053764),
      surfaceTint: Color(0xff3a608f),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff496f9f),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff043764),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff496f9f),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003b52),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff317495),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff5e231e),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffa25850),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff8f9ff),
      onSurface: Color(0xff0f1116),
      onSurfaceVariant: Color(0xff32363d),
      outline: Color(0xff4f535a),
      outlineVariant: Color(0xff696d75),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3035),
      inversePrimary: Color(0xffa4c9fe),
      primaryFixed: Color(0xff496f9f),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff2f5685),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff496f9f),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff2f5685),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff317495),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff0a5b7c),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc5c6cc),
      surfaceBright: Color(0xfff8f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff2f3fa),
      surfaceContainer: Color(0xffe7e8ee),
      surfaceContainerHigh: Color(0xffdbdce3),
      surfaceContainerHighest: Color(0xffd0d1d8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff002d55),
      surfaceTint: Color(0xff3a608f),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff224a78),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff002d54),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff214b78),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003044),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff004f6c),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff511a15),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff76362f),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff8f9ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff282c33),
      outlineVariant: Color(0xff454951),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3035),
      inversePrimary: Color(0xffa4c9fe),
      primaryFixed: Color(0xff224a78),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff003360),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff214b78),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff00345f),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff004f6c),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff00374d),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb7b8bf),
      surfaceBright: Color(0xfff8f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff0f7),
      surfaceContainer: Color(0xffe1e2e9),
      surfaceContainerHigh: Color(0xffd3d4da),
      surfaceContainerHighest: Color(0xffc5c6cc),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffa4c9fe),
      surfaceTint: Color(0xffa4c9fe),
      onPrimary: Color(0xff00315c),
      primaryContainer: Color(0xff1f4876),
      onPrimaryContainer: Color(0xffd3e3ff),
      secondary: Color(0xffa3c9fe),
      onSecondary: Color(0xff00315c),
      secondaryContainer: Color(0xff1e4876),
      onSecondaryContainer: Color(0xffd3e4ff),
      tertiary: Color(0xff90cef4),
      onTertiary: Color(0xff00344a),
      tertiaryContainer: Color(0xff004c69),
      onTertiaryContainer: Color(0xffc4e7ff),
      error: Color(0xffffb4ab),
      onError: Color(0xff561e19),
      errorContainer: Color(0xff73342d),
      onErrorContainer: Color(0xffffdad5),
      surface: Color(0xff111318),
      onSurface: Color(0xffe1e2e9),
      onSurfaceVariant: Color(0xffc3c6cf),
      outline: Color(0xff8d9199),
      outlineVariant: Color(0xff43474e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe1e2e9),
      inversePrimary: Color(0xff3a608f),
      primaryFixed: Color(0xffd3e3ff),
      onPrimaryFixed: Color(0xff001c39),
      primaryFixedDim: Color(0xffa4c9fe),
      onPrimaryFixedVariant: Color(0xff1f4876),
      secondaryFixed: Color(0xffd3e4ff),
      onSecondaryFixed: Color(0xff001c38),
      secondaryFixedDim: Color(0xffa3c9fe),
      onSecondaryFixedVariant: Color(0xff1e4876),
      tertiaryFixed: Color(0xffc4e7ff),
      onTertiaryFixed: Color(0xff001e2c),
      tertiaryFixedDim: Color(0xff90cef4),
      onTertiaryFixedVariant: Color(0xff004c69),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff37393e),
      surfaceContainerLowest: Color(0xff0c0e13),
      surfaceContainerLow: Color(0xff191c20),
      surfaceContainer: Color(0xff1d2024),
      surfaceContainerHigh: Color(0xff272a2f),
      surfaceContainerHighest: Color(0xff32353a),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffc9deff),
      surfaceTint: Color(0xffa4c9fe),
      onPrimary: Color(0xff00264a),
      primaryContainer: Color(0xff6e93c5),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffc9deff),
      onSecondary: Color(0xff002649),
      secondaryContainer: Color(0xff6e93c5),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffb6e2ff),
      onTertiary: Color(0xff00293b),
      tertiaryContainer: Color(0xff5998bb),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff48130f),
      errorContainer: Color(0xffcc7b72),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff111318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd9dce5),
      outline: Color(0xffaeb2ba),
      outlineVariant: Color(0xff8d9099),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe1e2e9),
      inversePrimary: Color(0xff214977),
      primaryFixed: Color(0xffd3e3ff),
      onPrimaryFixed: Color(0xff001227),
      primaryFixedDim: Color(0xffa4c9fe),
      onPrimaryFixedVariant: Color(0xff053764),
      secondaryFixed: Color(0xffd3e4ff),
      onSecondaryFixed: Color(0xff001227),
      secondaryFixedDim: Color(0xffa3c9fe),
      onSecondaryFixedVariant: Color(0xff043764),
      tertiaryFixed: Color(0xffc4e7ff),
      onTertiaryFixed: Color(0xff00131e),
      tertiaryFixedDim: Color(0xff90cef4),
      onTertiaryFixedVariant: Color(0xff003b52),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff42444a),
      surfaceContainerLowest: Color(0xff05070b),
      surfaceContainerLow: Color(0xff1b1e22),
      surfaceContainer: Color(0xff25282d),
      surfaceContainerHigh: Color(0xff303338),
      surfaceContainerHighest: Color(0xff3b3e43),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffe9f0ff),
      surfaceTint: Color(0xffa4c9fe),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffa0c5fa),
      onPrimaryContainer: Color(0xff000c1d),
      secondary: Color(0xffe9f0ff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xff9fc5fa),
      onSecondaryContainer: Color(0xff000c1d),
      tertiary: Color(0xffe1f2ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff8ccaef),
      onTertiaryContainer: Color(0xff000d15),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220000),
      surface: Color(0xff111318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffedf0f9),
      outlineVariant: Color(0xffbfc2cb),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe1e2e9),
      inversePrimary: Color(0xff214977),
      primaryFixed: Color(0xffd3e3ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffa4c9fe),
      onPrimaryFixedVariant: Color(0xff001227),
      secondaryFixed: Color(0xffd3e4ff),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffa3c9fe),
      onSecondaryFixedVariant: Color(0xff001227),
      tertiaryFixed: Color(0xffc4e7ff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xff90cef4),
      onTertiaryFixedVariant: Color(0xff00131e),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff4e5055),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1d2024),
      surfaceContainer: Color(0xff2e3035),
      surfaceContainerHigh: Color(0xff393b41),
      surfaceContainerHighest: Color(0xff44474c),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(
          color: colorScheme.primary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withOpacity(0.8),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: colorScheme.outline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.7),
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
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  /// Custom Color 1
  static const customColor1 = ExtendedColor(
    seed: Color(0xffffc800),
    value: Color(0xffffc800),
    light: ColorFamily(
      color: Color(0xff745b0b),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdf92),
      onColorContainer: Color(0xff594400),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff745b0b),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdf92),
      onColorContainer: Color(0xff594400),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff745b0b),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdf92),
      onColorContainer: Color(0xff594400),
    ),
    dark: ColorFamily(
      color: Color(0xffe5c36c),
      onColor: Color(0xff3e2e00),
      colorContainer: Color(0xff594400),
      onColorContainer: Color(0xffffdf92),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffe5c36c),
      onColor: Color(0xff3e2e00),
      colorContainer: Color(0xff594400),
      onColorContainer: Color(0xffffdf92),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffe5c36c),
      onColor: Color(0xff3e2e00),
      colorContainer: Color(0xff594400),
      onColorContainer: Color(0xffffdf92),
    ),
  );

  /// Custom Color 2
  static const customColor2 = ExtendedColor(
    seed: Color(0xffff9500),
    value: Color(0xffff9500),
    light: ColorFamily(
      color: Color(0xff86521a),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdcbf),
      onColorContainer: Color(0xff6a3b02),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff86521a),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdcbf),
      onColorContainer: Color(0xff6a3b02),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff86521a),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdcbf),
      onColorContainer: Color(0xff6a3b02),
    ),
    dark: ColorFamily(
      color: Color(0xfffeb876),
      onColor: Color(0xff4b2800),
      colorContainer: Color(0xff6a3b02),
      onColorContainer: Color(0xffffdcbf),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xfffeb876),
      onColor: Color(0xff4b2800),
      colorContainer: Color(0xff6a3b02),
      onColorContainer: Color(0xffffdcbf),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xfffeb876),
      onColor: Color(0xff4b2800),
      colorContainer: Color(0xff6a3b02),
      onColorContainer: Color(0xffffdcbf),
    ),
  );


  List<ExtendedColor> get extendedColors => [
    customColor1,
    customColor2,
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
