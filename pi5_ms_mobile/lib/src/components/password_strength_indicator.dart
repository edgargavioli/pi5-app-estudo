import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/shared/services/validation_service.dart';

/// 🔒 WIDGET PARA EXIBIR A FORÇA DA SENHA
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showDetails;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final strength = ValidationService.getPasswordStrength(password);

    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // Barra de progresso da força da senha
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: strength.percentage,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(strength.color),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              strength.description,
              style: TextStyle(
                fontSize: 12,
                color: strength.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        if (showDetails && strength != PasswordStrength.veryStrong) ...[
          const SizedBox(height: 8),
          _buildRequirements(),
        ],
      ],
    );
  }

  Widget _buildRequirements() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sua senha deve conter:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirement('Pelo menos 8 caracteres', password.length >= 8),
          _buildRequirement(
            'Uma letra maiúscula (A-Z)',
            RegExp(r'[A-Z]').hasMatch(password),
          ),
          _buildRequirement(
            'Uma letra minúscula (a-z)',
            RegExp(r'[a-z]').hasMatch(password),
          ),
          _buildRequirement(
            'Um número (0-9)',
            RegExp(r'\d').hasMatch(password),
          ),
          _buildRequirement(
            'Um caractere especial (!@#\$%^&*...)',
            RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isMet ? Colors.green : Colors.grey[600],
                decoration: isMet ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
