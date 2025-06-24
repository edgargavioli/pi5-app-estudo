class Materia {
  final String id;
  final String nome;
  final String? descricao;
  final String? disciplina;
  final String? cor;
  final DateTime createdAt;
  final DateTime updatedAt;

  Materia({
    required this.id,
    required this.nome,
    this.descricao,
    this.disciplina,
    this.cor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      id: json['id'] as String,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
      disciplina: json['disciplina'] as String?,
      cor: json['cor'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'disciplina': disciplina,
      'cor': cor,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, Object?> toCreateJson() {
    return {
      'nome': nome,
      'descricao': descricao,
      'disciplina': disciplina,
      'cor': cor,
    };
  }

  String get categoria => disciplina ?? descricao ?? 'Geral';
}
