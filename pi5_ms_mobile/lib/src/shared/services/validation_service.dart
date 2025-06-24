import 'package:flutter/material.dart';

/// 🛡️ SERVIÇO DE VALIDAÇÃO PARA FORMULÁRIOS
class ValidationService {
  /// 📧 VALIDAR EMAIL
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, insira um email válido';
    }

    return null;
  }

  /// 🔐 VALIDAR SENHA
  static String? validatePassword(String? value, {bool isRegistration = true}) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }

    // Para login, apenas verificar se não está vazio
    if (!isRegistration) {
      return null;
    }

    // Para registro, aplicar todas as validações
    final errors = <String>[];

    if (value.length < 8) {
      errors.add('pelo menos 8 caracteres');
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      errors.add('uma letra maiúscula');
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      errors.add('uma letra minúscula');
    }

    if (!RegExp(r'\d').hasMatch(value)) {
      errors.add('um número');
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      errors.add('um caractere especial');
    }

    if (errors.isNotEmpty) {
      return 'A senha deve conter: ${errors.join(', ')}';
    }

    return null;
  }

  /// 👤 VALIDAR NOME
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }

    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }

    if (value.trim().length > 50) {
      return 'Nome deve ter no máximo 50 caracteres';
    }

    // Verificar se contém apenas letras, espaços e alguns caracteres especiais
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\s'.-]+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Nome deve conter apenas letras';
    }

    return null;
  }

  /// 🔄 VALIDAR CONFIRMAÇÃO DE SENHA
  static String? validatePasswordConfirmation(
    String? value,
    String? originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }

    if (value != originalPassword) {
      return 'As senhas não conferem';
    }

    return null;
  }

  /// 📱 VALIDAR TELEFONE (OPCIONAL)
  static String? validatePhone(String? value, {bool isRequired = false}) {
    if (!isRequired && (value == null || value.isEmpty)) {
      return null;
    }

    if (isRequired && (value == null || value.isEmpty)) {
      return 'Telefone é obrigatório';
    }

    // Remove formatação para validação
    final cleanPhone = value!.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.length < 10 || cleanPhone.length > 11) {
      return 'Telefone deve ter 10 ou 11 dígitos';
    }

    return null;
  }

  /// 🎂 VALIDAR DATA DE NASCIMENTO (OPCIONAL)
  static String? validateBirthDate(DateTime? value, {bool isRequired = false}) {
    if (!isRequired && value == null) {
      return null;
    }

    if (isRequired && value == null) {
      return 'Data de nascimento é obrigatória';
    }

    final now = DateTime.now();
    final age = now.year - value!.year;

    if (value.isAfter(now)) {
      return 'Data de nascimento não pode ser no futuro';
    }

    if (age < 13) {
      return 'Você deve ter pelo menos 13 anos';
    }

    if (age > 120) {
      return 'Data de nascimento inválida';
    }

    return null;
  }

  /// 🔒 VERIFICAR FORÇA DA SENHA
  static PasswordStrength getPasswordStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength.empty;
    }

    int score = 0;

    // Comprimento
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Complexidade
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    // Padrões comuns (penalizar)
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) {
      score--; // caracteres repetidos
    }
    if (RegExp(r'123|abc|qwe', caseSensitive: false).hasMatch(password)) {
      score--; // sequências
    }

    switch (score) {
      case 0:
      case 1:
        return PasswordStrength.weak;
      case 2:
      case 3:
        return PasswordStrength.medium;
      case 4:
      case 5:
        return PasswordStrength.strong;
      default:
        return PasswordStrength.veryStrong;
    }
  }

  /// 📋 VALIDAR FORMULÁRIO COMPLETO DE REGISTRO
  static Map<String, String?> validateRegistrationForm({
    required String? name,
    required String? email,
    required String? password,
    required String? confirmPassword,
    String? phone,
  }) {
    return {
      'name': validateName(name),
      'email': validateEmail(email),
      'password': validatePassword(password, isRegistration: true),
      'confirmPassword': validatePasswordConfirmation(
        confirmPassword,
        password,
      ),
      if (phone != null && phone.isNotEmpty) 'phone': validatePhone(phone),
    };
  }

  /// 🔑 VALIDAR FORMULÁRIO DE LOGIN
  static Map<String, String?> validateLoginForm({
    required String? email,
    required String? password,
  }) {
    return {
      'email': validateEmail(email),
      'password': validatePassword(password, isRegistration: false),
    };
  }
}

/// 🔒 ENUM PARA FORÇA DA SENHA
enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
  veryStrong;

  /// Obter cor para exibição visual
  Color get color {
    switch (this) {
      case PasswordStrength.empty:
        return Colors.grey;
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.blue;
      case PasswordStrength.veryStrong:
        return Colors.green;
    }
  }

  /// Obter texto descritivo
  String get description {
    switch (this) {
      case PasswordStrength.empty:
        return '';
      case PasswordStrength.weak:
        return 'Fraca';
      case PasswordStrength.medium:
        return 'Média';
      case PasswordStrength.strong:
        return 'Forte';
      case PasswordStrength.veryStrong:
        return 'Muito Forte';
    }
  }

  /// Obter porcentagem para barra de progresso
  double get percentage {
    switch (this) {
      case PasswordStrength.empty:
        return 0.0;
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.medium:
        return 0.5;
      case PasswordStrength.strong:
        return 0.75;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }
}
