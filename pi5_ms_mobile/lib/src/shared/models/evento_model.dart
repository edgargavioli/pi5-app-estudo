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
      taxaInscricao:
          json['taxaInscricao'] != null
              ? double.parse(json['taxaInscricao'].toString())
              : null,
      dataLimiteInscricao:
          json['dataLimiteInscricao'] != null
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

  Map<String, Object?> toCreateJson() {
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
  SESSAO_ESTUDO,
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
      case TipoEvento.SESSAO_ESTUDO:
        return 'Sessão de Estudo';
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
  final bool isAgendada;
  final bool? cumpriuPrazo;
  final DateTime? horarioAgendado;
  final int? metaTempo; // Meta de tempo em minutos
  final int questoesAcertadas;
  final int totalQuestoes;
  final bool finalizada;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Calcular percentual de acerto
  double get percentualAcerto {
    if (totalQuestoes > 0) {
      return (questoesAcertadas / totalQuestoes) * 100;
    }
    return 0.0;
  }

  // Calcular progresso da meta de tempo
  double get progressoMeta {
    if (!isAgendada ||
        metaTempo == null ||
        tempoInicio == null ||
        tempoFim == null) {
      return 0.0;
    }

    final tempoRealMinutos = tempoFim!.difference(tempoInicio!).inMinutes;
    final progresso = (tempoRealMinutos / metaTempo!) * 100;
    return progresso.clamp(0.0, 100.0);
  }

  // Verificar se pode ser iniciada (para sessões agendadas)
  bool get podeSerIniciada {
    if (!isAgendada || horarioAgendado == null) {
      return true; // Sessões livres podem ser iniciadas a qualquer momento
    }

    final agora = DateTime.now();
    final tolerancia = const Duration(minutes: 30);
    final horarioLimite = horarioAgendado!.add(tolerancia);

    return agora.isAfter(horarioAgendado!) && agora.isBefore(horarioLimite);
  }

  SessaoEstudo({
    required this.id,
    required this.materiaId,
    this.provaId,
    this.eventoId,
    required this.conteudo,
    required this.topicos,
    this.tempoInicio,
    this.tempoFim,
    this.isAgendada = false,
    this.cumpriuPrazo,
    this.horarioAgendado,
    this.metaTempo,
    this.questoesAcertadas = 0,
    this.totalQuestoes = 0,
    this.finalizada = false,
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
      tempoInicio:
          json['tempoInicio'] != null
              ? DateTime.parse(json['tempoInicio'] as String)
              : null,
      tempoFim:
          json['tempoFim'] != null
              ? DateTime.parse(json['tempoFim'] as String)
              : null,
      isAgendada: json['isAgendada'] as bool? ?? false,
      cumpriuPrazo: json['cumpriuPrazo'] as bool?,
      horarioAgendado:
          json['horarioAgendado'] != null
              ? DateTime.parse(json['horarioAgendado'] as String)
              : null,
      metaTempo: json['metaTempo'] as int?,
      questoesAcertadas: json['questoesAcertadas'] as int? ?? 0,
      totalQuestoes: json['totalQuestoes'] as int? ?? 0,
      finalizada: json['finalizada'] as bool? ?? false,
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
      'isAgendada': isAgendada,
      'cumpriuPrazo': cumpriuPrazo,
      'horarioAgendado': horarioAgendado?.toIso8601String(),
      'metaTempo': metaTempo,
      'questoesAcertadas': questoesAcertadas,
      'totalQuestoes': totalQuestoes,
      'finalizada': finalizada,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, Object?> toCreateJson() {
    final json = <String, Object?>{
      'materiaId': materiaId,
      'conteudo': conteudo,
      'topicos': topicos,
      'isAgendada': isAgendada,
      'questoesAcertadas': questoesAcertadas,
      'totalQuestoes': totalQuestoes,
      'finalizada': finalizada,
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

    if (cumpriuPrazo != null) {
      json['cumpriuPrazo'] = cumpriuPrazo;
    }

    if (horarioAgendado != null) {
      json['horarioAgendado'] = horarioAgendado!.toIso8601String();
    }

    if (metaTempo != null) {
      json['metaTempo'] = metaTempo;
    }

    return json;
  }
}
