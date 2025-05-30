import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Widget? trailing;
  final double? height;
  final double? width;

  const CardWidget({
    super.key,
    required this.title,
    this.icon = Icons.list,
    this.onTap,
    this.onLongPress,
    this.color,
    this.trailing,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 73,
      width: width ?? double.infinity,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(
            color: color ?? Theme.of(context).colorScheme.outline,
            width: 0.5,
          ),
        ),
        color: color ?? Theme.of(context).colorScheme.surface,
        child: ListTile(
          leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          onTap: onTap,
          onLongPress: onLongPress,
          trailing: trailing,
        ),
      ),
    );
  }
}
