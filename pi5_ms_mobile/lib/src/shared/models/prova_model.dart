import 'materia_model.dart';

enum StatusProva { PENDENTE, CONCLUIDA, CANCELADA }

class Prova {
  final String id;
  final String titulo;
  final String? descricao;
  final DateTime data;
  final DateTime horario;
  final String local;
  final StatusProva status;
  final List<String> materiasIds;
  final Map<String, dynamic>? filtros;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Materia> materias;

  String get materiaId => materiasIds.isNotEmpty ? materiasIds.first : '';
  Materia? get materia => materias.isNotEmpty ? materias.first : null;
  Prova({
    required this.id,
    required this.titulo,
    this.descricao,
    required this.data,
    required this.horario,
    required this.local,
    this.status = StatusProva.PENDENTE,
    required this.materiasIds,
    this.filtros,
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
      materias =
          (json['materias'] as List)
              .map(
                (materiaJson) =>
                    Materia.fromJson(materiaJson as Map<String, dynamic>),
              )
              .toList();
    } else if (json['materia'] != null) {
      materias = [Materia.fromJson(json['materia'] as Map<String, dynamic>)];
    }

    // Converter status do string para enum
    StatusProva status = StatusProva.PENDENTE;
    if (json['status'] != null) {
      switch (json['status'] as String) {
        case 'PENDENTE':
          status = StatusProva.PENDENTE;
          break;
        case 'CONCLUIDA':
          status = StatusProva.CONCLUIDA;
          break;
        case 'CANCELADA':
          status = StatusProva.CANCELADA;
          break;
        default:
          status = StatusProva.PENDENTE;
      }
    }

    return Prova(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String?,
      data: DateTime.parse(json['data'] as String),
      horario: DateTime.parse(json['horario'] as String),
      local: json['local'] as String,
      status: status,
      materiasIds: materiasIds,
      filtros:
          json['filtros'] != null
              ? Map<String, dynamic>.from(json['filtros'] as Map)
              : null,
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
      'status': status.name,
      'materiasIds': materiasIds,
      'filtros': filtros,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, Object?> toCreateJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'data': data.toIso8601String(),
      'horario': horario.toIso8601String(),
      'local': local,
      'materiaId':
          materiasIds.isNotEmpty ? materiasIds.first : null, // Compatibilidade
      'materias': materiasIds.map((id) => {'id': id}).toList(), // Novo formato
      'filtros': filtros,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Prova copyWith({
    String? id,
    String? titulo,
    String? descricao,
    DateTime? data,
    DateTime? horario,
    String? local,
    StatusProva? status,
    List<String>? materiasIds,
    Map<String, dynamic>? filtros,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Materia>? materias,
  }) {
    return Prova(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      data: data ?? this.data,
      horario: horario ?? this.horario,
      local: local ?? this.local,
      status: status ?? this.status,
      materiasIds: materiasIds ?? this.materiasIds,
      filtros: filtros ?? this.filtros,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      materias: materias ?? this.materias,
    );
  }
}
