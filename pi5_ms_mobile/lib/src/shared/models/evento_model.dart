class Evento {
  final String id;
  final String titulo;
  final String? descricao;
  final TipoEvento tipo;
  final DateTime data;
  final DateTime horario;
  final String local;
  final String? materiaId;
  final String? urlInscricao;
  final double? taxaInscricao;
  final DateTime? dataLimiteInscricao;
  final DateTime createdAt;
  final DateTime updatedAt;

  Evento({
    required this.id,
    required this.titulo,
    this.descricao,
    required this.tipo,
    required this.data,
    required this.horario,
    required this.local,
    this.materiaId,
    this.urlInscricao,
    this.taxaInscricao,
    this.dataLimiteInscricao,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String?,
      tipo: TipoEvento.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => TipoEvento.PROVA_SIMULADA,
      ),
      data: DateTime.parse(json['data'] as String),
      horario: DateTime.parse(json['horario'] as String),
      local: json['local'] as String,
      materiaId: json['materiaId'] as String?,
      urlInscricao: json['urlInscricao'] as String?,
      taxaInscricao: json['taxaInscricao'] != null
          ? double.parse(json['taxaInscricao'].toString())
          : null,
      dataLimiteInscricao: json['dataLimiteInscricao'] != null
          ? DateTime.parse(json['dataLimiteInscricao'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'tipo': tipo.name,
      'data': data.toIso8601String(),
      'horario': horario.toIso8601String(),
      'local': local,
      'materiaId': materiaId,
      'urlInscricao': urlInscricao,
      'taxaInscricao': taxaInscricao,
      'dataLimiteInscricao': dataLimiteInscricao?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'tipo': tipo.name,
      'data': data.toIso8601String(),
      'horario': horario.toIso8601String(),
      'local': local,
      'materiaId': materiaId,
      'urlInscricao': urlInscricao,
      'taxaInscricao': taxaInscricao,
      'dataLimiteInscricao': dataLimiteInscricao?.toIso8601String(),
    };
  }
}

enum TipoEvento {
  VESTIBULAR,
  CONCURSO_PUBLICO,
  ENEM,
  CERTIFICACAO,
  PROVA_SIMULADA,
}

extension TipoEventoExtension on TipoEvento {
  String get displayName {
    switch (this) {
      case TipoEvento.VESTIBULAR:
        return 'Vestibular';
      case TipoEvento.CONCURSO_PUBLICO:
        return 'Concurso Público';
      case TipoEvento.ENEM:
        return 'ENEM';
      case TipoEvento.CERTIFICACAO:
        return 'Certificação';
      case TipoEvento.PROVA_SIMULADA:
        return 'Prova Simulada';
    }
  }
}

class SessaoEstudo {
  final String id;
  final String materiaId;
  final String? provaId;
  final String? eventoId;
  final String conteudo;
  final List<String> topicos;
  final DateTime? tempoInicio;
  final DateTime? tempoFim;
  final DateTime createdAt;
  final DateTime updatedAt;

  SessaoEstudo({
    required this.id,
    required this.materiaId,
    this.provaId,
    this.eventoId,
    required this.conteudo,
    required this.topicos,
    this.tempoInicio,
    this.tempoFim,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SessaoEstudo.fromJson(Map<String, dynamic> json) {
    return SessaoEstudo(
      id: json['id'] as String,
      materiaId: json['materiaId'] as String,
      provaId: json['provaId'] as String?,
      eventoId: json['eventoId'] as String?,
      conteudo: json['conteudo'] as String,
      topicos: List<String>.from(json['topicos'] as List),
      tempoInicio: json['tempoInicio'] != null
          ? DateTime.parse(json['tempoInicio'] as String)
          : null,
      tempoFim: json['tempoFim'] != null
          ? DateTime.parse(json['tempoFim'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materiaId': materiaId,
      'provaId': provaId,
      'eventoId': eventoId,
      'conteudo': conteudo,
      'topicos': topicos,
      'tempoInicio': tempoInicio?.toIso8601String(),
      'tempoFim': tempoFim?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    final json = <String, dynamic>{
      'materiaId': materiaId,
      'conteudo': conteudo,
      'topicos': topicos,
    };
    
    // Só incluir campos opcionais se não forem null
    if (provaId != null && provaId!.isNotEmpty) {
      json['provaId'] = provaId;
    }
    
    if (eventoId != null && eventoId!.isNotEmpty) {
      json['eventoId'] = eventoId;
    }
    
    if (tempoInicio != null) {
      json['tempoInicio'] = tempoInicio!.toIso8601String();
    }
    
    if (tempoFim != null) {
      json['tempoFim'] = tempoFim!.toIso8601String();
    }
    
    return json;
  }
} 