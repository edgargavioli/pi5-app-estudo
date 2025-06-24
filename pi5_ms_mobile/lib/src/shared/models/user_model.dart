class UserModel {
  final String id;
  final String? nome;
  final String? email;
  final int points;
  final bool isEmailVerified;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageBase64;

  UserModel({
    required this.id,
    this.nome,
    this.email,
    this.points = 0,
    this.isEmailVerified = false,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
    this.imageBase64,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      nome: json['name'] as String?,
      email: json['email'] as String?,
      points: json['points'] as int? ?? 0,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      lastLogin:
          json['lastLogin'] != null
              ? DateTime.parse(json['lastLogin'] as String)
              : null,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
      imageBase64: json['imageBase64'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nome,
      'email': email,
      'points': points,
      'isEmailVerified': isEmailVerified,
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imageBase64': imageBase64,
    };
  }

  /// Cria uma cópia do usuário com campos opcionalmente atualizados
  UserModel copyWith({
    String? id,
    String? email,
    String? nome,
    int? points,
    bool? isEmailVerified,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageBase64,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nome: nome ?? this.nome,
      points: points ?? this.points,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageBase64: imageBase64 ?? this.imageBase64,
    );
  }
}
