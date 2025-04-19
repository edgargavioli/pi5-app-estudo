import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget icon;
  final double iconSize;
  final Color? iconColor;
  final double spacing;
  final String title;
  final TextStyle? titleStyle;
  final double? width;
  final double? height;
  final Color? outlineColor;
  final double outlineWidth;

  const CardWidget({
    super.key,
    this.margin = const EdgeInsets.all(8.0),
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.padding = const EdgeInsets.all(8.0),
    required this.icon,
    this.iconSize = 24.0,
    this.iconColor,
    this.spacing = 8.0,
    this.title = '',
    this.titleStyle,
    this.width,
    this.height,
    this.outlineColor,
    this.outlineWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: outlineColor ?? Theme.of(context).colorScheme.outline,
          width: outlineWidth,
        ),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            IconTheme(
              data: IconThemeData(
                size: iconSize,
                color: iconColor ?? theme.iconTheme.color,
              ),
              child: icon,
            ),
            SizedBox(width: spacing),
            Text(
              title,
              style:
                  titleStyle ??
                  theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
