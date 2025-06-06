/// 👤 MODELO DE USUÁRIO PARA AUTENTICAÇÃO
class AuthUser {
  final String id;
  final String? nome;
  final String? email;
  final bool isEmailVerified;
  final DateTime? lastLogin;

  AuthUser({
    required this.id,
    this.nome,
    this.email,
    this.isEmailVerified = false,
    this.lastLogin,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    try {
      return AuthUser(
        id: json['id']?.toString() ?? '',
        nome: json['nome']?.toString(),
        email: json['email']?.toString(),
        isEmailVerified: json['isEmailVerified'] as bool? ?? false,
        lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin'] as String) : null,
      );
    } catch (e) {
      print('❌ Erro ao converter JSON para AuthUser: $e');
      print('📦 JSON recebido: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'isEmailVerified': isEmailVerified,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
} 