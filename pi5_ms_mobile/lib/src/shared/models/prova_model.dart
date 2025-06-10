class Prova {
  final String id;
  final String titulo;
  final String? descricao;
  final DateTime data;
  final DateTime horario;
  final String local;
  final List<String> materiasIds;
  final Map<String, dynamic>? filtros;
  final int? totalQuestoes;
  final int? acertos;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Materia> materias;

  String get materiaId => materiasIds.isNotEmpty ? materiasIds.first : '';
  Materia? get materia => materias.isNotEmpty ? materias.first : null;
  
  // Calcular percentual de acerto
  int? get percentualAcerto {
    if (totalQuestoes != null && acertos != null && totalQuestoes! > 0) {
      return ((acertos! / totalQuestoes!) * 100).round();
    }
    return null;
  }
  
  // Verificar se a prova foi realizada
  bool get foiRealizada => acertos != null;

  Prova({
    required this.id,
    required this.titulo,
    this.descricao,
    required this.data,
    required this.horario,
    required this.local,
    required this.materiasIds,
    this.filtros,
    this.totalQuestoes,
    this.acertos,
    required this.createdAt,
    required this.updatedAt,
    this.materias = const [],
  });

  factory Prova.fromJson(Map<String, dynamic> json) {
    List<String> materiasIds = [];
    if (json['materiasIds'] != null) {
      materiasIds = List<String>.from(json['materiasIds']);
    } else if (json['materiaId'] != null) {
      materiasIds = [json['materiaId'] as String];
    }

    List<Materia> materias = [];
    if (json['materias'] != null && json['materias'] is List) {
      materias = (json['materias'] as List)
          .map((materiaJson) => Materia.fromJson(materiaJson as Map<String, dynamic>))
          .toList();
    } else if (json['materia'] != null) {
      materias = [Materia.fromJson(json['materia'] as Map<String, dynamic>)];
    }

    return Prova(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String?,
      data: DateTime.parse(json['data'] as String),
      horario: DateTime.parse(json['horario'] as String),
      local: json['local'] as String,
      materiasIds: materiasIds,
      filtros: json['filtros'] != null 
          ? Map<String, dynamic>.from(json['filtros'] as Map)
          : null,
      totalQuestoes: json['totalQuestoes'] as int?,
      acertos: json['acertos'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      materias: materias,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'data': data.toIso8601String(),
      'horario': horario.toIso8601String(),
      'local': local,
      'materiasIds': materiasIds,
      'filtros': filtros,
      'totalQuestoes': totalQuestoes,
      'acertos': acertos,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'data': data.toIso8601String(),
      'horario': horario.toIso8601String(),
      'local': local,
      'materiaId': materiasIds.isNotEmpty ? materiasIds.first : null,
      'filtros': filtros,
      'totalQuestoes': totalQuestoes,
      'acertos': acertos,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Materia {
  final String id;
  final String nome;
  final String? disciplina;
  final String? descricao;
  final DateTime createdAt;
  final DateTime updatedAt;

  Materia({
    required this.id,
    required this.nome,
    this.disciplina,
    this.descricao,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      id: json['id'] as String,
      nome: json['nome'] as String,
      disciplina: json['disciplina'] as String?,
      descricao: json['descricao'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'disciplina': disciplina,
      'descricao': descricao,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'nome': nome,
      'disciplina': disciplina ?? 'Geral',
    };
  }

  String get categoria => disciplina ?? descricao ?? 'Geral';
} 