import 'package:flutter/material.dart';

/// Utilitário para criar diálogos modernos e harmônicos em todo o app
class ModernDialog {
  /// Cria um diálogo de confirmação moderno
  static Widget buildConfirmDialog({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    String? infoText,
    Color? infoColor,
    required String cancelText,
    required String confirmText,
    required Color confirmColor,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone animado
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.5 + (value * 0.5),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: iconColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(icon, size: 32, color: iconColor),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Título
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Conteúdo principal
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            // Informação adicional se fornecida
            if (infoText != null && infoColor != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: infoColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: infoColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        infoText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: infoColor.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Text(
                      cancelText,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: isDestructive ? 2 : 1,
                    ),
                    child: Text(
                      confirmText,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Cria um diálogo de loading moderno
  static Widget buildLoadingDialog({
    required BuildContext context,
    required String message,
    Color? accentColor,
  }) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surface,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(width: 20),
            Flexible(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostra um diálogo de confirmação e retorna o resultado
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    String? infoText,
    Color? infoColor,
    String cancelText = 'Cancelar',
    String confirmText = 'Confirmar',
    Color? confirmColor,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final finalConfirmColor =
        confirmColor ??
        (isDestructive ? Colors.red : theme.colorScheme.primary);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => buildConfirmDialog(
            context: context,
            icon: icon,
            iconColor: iconColor,
            title: title,
            content: content,
            infoText: infoText,
            infoColor: infoColor,
            cancelText: cancelText,
            confirmText: confirmText,
            confirmColor: finalConfirmColor,
            isDestructive: isDestructive,
          ),
    );
  }

  /// Mostra um diálogo de loading
  static void showLoadingDialog({
    required BuildContext context,
    required String message,
    Color? accentColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => buildLoadingDialog(
            context: context,
            message: message,
            accentColor: accentColor,
          ),
    );
  }
}
