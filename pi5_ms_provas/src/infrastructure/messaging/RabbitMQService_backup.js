import amqp from 'amqplib';
import { logger } from '../../application/utils/logger.js';

/**
 * RabbitMQ Service - PI5 MS Provas
 * Responsável por publicar eventos de sessões e provas
 */
class RabbitMQService {
  constructor() {
    this.connection = null;
    this.channel = null;
    this.isConnected = false;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 10;
    this.reconnectDelay = 5000;

    // Configurações do ambiente
    this.config = {
      url: process.env.RABBITMQ_URL || 'amqp://admin:admin123@localhost:5672/',
      exchange: process.env.RABBITMQ_EXCHANGE || 'pi5_events',
      serviceName: process.env.SERVICE_NAME || 'provas-service'
    };

    this.routingKeys = {
      // Eventos que Provas Service PUBLICA
      SESSAO_CRIADA: 'provas.sessao.criada',
      SESSAO_FINALIZADA: 'provas.sessao.finalizada',
      PROVA_FINALIZADA: 'provas.prova.finalizada',

      // Eventos CRUD genéricos - alinhados com as filas do consumer
      EVENT_CREATED: 'event.created',
      EVENT_UPDATED: 'event.updated',
      EVENT_DELETED: 'event.deleted',

      // Eventos de exames
      EXAM_CREATED: 'exam.created',
      EXAM_UPDATED: 'exam.updated',
      EXAM_DELETED: 'exam.deleted',

      // Eventos que Provas Service CONSOME (do User Service)
      PONTOS_ATUALIZADOS: 'user.pontos.atualizados',
      NIVEL_ALTERADO: 'user.nivel.alterado',
      CONQUISTA_DESBLOQUEADA: 'user.conquista.desbloqueada'
    };

    // Filas que este serviço consome e publica
    this.queues = {
      PROVAS_SYNC: `${this.config.serviceName}.sync.updates`,
      EVENT_CREATED: process.env.EVENT_QUEUE || 'event.created',
      EVENT_UPDATED: process.env.EVENT_UPDATED_QUEUE || 'event.updated',
      EVENT_DELETED: process.env.EVENT_DELETED_QUEUE || 'event.deleted',
      EXAM_CREATED: process.env.EXAM_QUEUE || 'exam.created',
      EXAM_UPDATED: process.env.EXAM_UPDATED_QUEUE || 'exam.updated',
      EXAM_DELETED: process.env.EXAM_DELETED_QUEUE || 'exam.deleted',
      SESSAO_CRIADA: process.env.SESSAO_CRIADA_QUEUE || 'sessao.criada',
      SESSAO_FINALIZADA: process.env.SESSAO_FINALIZADA_QUEUE || 'sessao.finalizada'
    };
  }

  /**
   * Conecta ao RabbitMQ com retry automático
   */
  async connect() {
    try {
      logger.info('Tentando conectar ao RabbitMQ...', {
        url: this.config.url.replace(/\/\/.*@/, '//***:***@'),
        attempt: this.reconnectAttempts + 1
      });

      this.connection = await amqp.connect(this.config.url);
      this.channel = await this.connection.createChannel();

      // Configurar tratamento de erros
      this.connection.on('error', this.handleConnectionError.bind(this));
      this.connection.on('close', this.handleConnectionClose.bind(this));
      this.channel.on('error', this.handleChannelError.bind(this));

      // Configurar exchange principal
      await this.channel.assertExchange(this.config.exchange, 'topic', {
        durable: true,
        autoDelete: false
      });

      // Configurar filas se necessário
      await this.setupQueues();

      this.isConnected = true;
      this.reconnectAttempts = 0;

      logger.info('✅ Conectado ao RabbitMQ com sucesso!', {
        exchange: this.config.exchange,
        serviceName: this.config.serviceName
      });

      return true;
    } catch (error) {
      logger.error('❌ Erro ao conectar ao RabbitMQ', {
        error: error.message,
        attempt: this.reconnectAttempts + 1
      });

      await this.handleReconnect();
      return false;
    }
  }

  /**
   * Configura filas necessárias (se houver)
   */
  async setupQueues() {
    // Configurar filas CRUD - removendo argumentos específicos que podem causar conflito
    for (const [queueName, queueKey] of Object.entries(this.queues)) {
      try {
        await this.channel.assertQueue(queueKey, {
          durable: true
          // Removidos argumentos específicos para evitar conflitos com filas existentes
        });
      } catch (error) {
        logger.warn(`⚠️ Erro ao configurar fila ${queueKey}, tentando sem argumentos`, {
          error: error.message
        });

        // Tentar criar fila básica sem argumentos adicionais
        await this.channel.assertQueue(queueKey, {
          durable: true
        });
      }
    }

    logger.info('🔧 Filas RabbitMQ configuradas', {
      queues: Object.values(this.queues)
    });
  }

  /**
   * Publica evento de sessão criada
   */
  async publishSessaoCriada(sessaoData) {
    const event = {
      data: {
        userId: sessaoData.userId || 'user-default', // TODO: Implementar autenticação
        sessaoId: sessaoData.id,
        materiaId: sessaoData.materiaId,
        provaId: sessaoData.provaId,
        tempoInicio: sessaoData.tempoInicio,
        conteudo: sessaoData.conteudo,
        topicos: sessaoData.topicos
      }
    };

    return this.publish(this.routingKeys.SESSAO_CRIADA, event);
  }

  /**
   * Publica evento de sessão finalizada
   */
  async publishSessaoFinalizada(sessaoData) {
    // Calcular tempo de estudo em minutos
    const tempoInicioMs = new Date(sessaoData.tempoInicio).getTime();
    const tempoFimMs = new Date(sessaoData.tempoFim).getTime();
    const tempoEstudoMinutos = Math.floor((tempoFimMs - tempoInicioMs) / (1000 * 60));

    const event = {
      data: {
        userId: sessaoData.userId || 'user-default', // TODO: Implementar autenticação
        sessaoId: sessaoData.id,
        materiaId: sessaoData.materiaId,
        provaId: sessaoData.provaId,
        tempoEstudo: tempoEstudoMinutos,
        tempoInicio: sessaoData.tempoInicio,
        tempoFim: sessaoData.tempoFim,
        conteudo: sessaoData.conteudo,
        questoesAcertadas: sessaoData.questoesAcertadas || 0,
        totalQuestoes: sessaoData.totalQuestoes || 0
      }
    };

    return this.publish(this.routingKeys.SESSAO_FINALIZADA, event);
  }

  /**
   * Publica evento de prova finalizada
   */
  async publishProvaFinalizada(provaData) {
    const event = {
      data: {
        userId: provaData.userId || 'user-default', // TODO: Implementar autenticação
        provaId: provaData.id,
        materiaId: provaData.materiaId,
        questoesAcertadas: provaData.questoesAcertadas,
        totalQuestoes: provaData.totalQuestoes,
        percentualAcerto: provaData.percentualAcerto,
        dataRealizacao: provaData.dataRealizacao || new Date().toISOString()
      }
    };

    return this.publish(this.routingKeys.PROVA_FINALIZADA, event);
  }

  /**
   * Publica evento de entidade criada
   */
  async publishEntityCreated(entityType, entityData, userId = null) {
    const event = {
      data: {
        entityType,
        entityId: entityData.id,
        entityData,
        userId: userId || entityData.userId || 'user-default',
        action: 'CREATED'
      }
    };

    return this.publish(this.routingKeys.EVENT_CREATED, event);
  }

  /**
   * Publica evento de entidade editada
   */
  async publishEntityUpdated(entityType, entityId, updatedData, previousData = null, userId = null) {
    const event = {
      data: {
        entityType,
        entityId,
        updatedData,
        previousData,
        userId: userId || updatedData.userId || 'user-default',
        action: 'UPDATED'
      }
    };

    return this.publish(this.routingKeys.EVENT_UPDATED, event);
  }

  /**
   * Publica evento de entidade deletada
   */
  async publishEntityDeleted(entityType, entityId, deletedData = null, userId = null) {
    const event = {
      data: {
        entityType,
        entityId,
        deletedData,
        userId: userId || deletedData?.userId || 'user-default',
        action: 'DELETED'
      }
    };

    return this.publish(this.routingKeys.EVENT_DELETED, event);
  }

  /**
   * Publica evento de exame criado
   */
  async publishExamCreated(examType, examData, userId = null) {
    const event = {
      data: {
        examType,
        examId: examData.id,
        examData: {
          name: examData.titulo,
          description: examData.descricao,
          date: examData.data || new Date().toISOString(),
        },
        userId: userId || examData.userId || 'user-default',
        action: 'CREATED'
      }
    };

    // Usar a fila diretamente, não o routing key
    return this.publish(this.queues.EXAM_CREATED, event);
  }

  /**
   * Publica evento de exame editado
   */
  async publishExamUpdated(examType, examId, updatedData, previousData = null, userId = null) {
    const event = {
      data: {
        examType,
        examId,
        updatedData,
        previousData,
        userId: userId || updatedData.userId || 'user-default',
        action: 'UPDATED'
      }
    };

    return this.publish(this.queues.EXAM_UPDATED, event);
  }

  /**
   * Publica evento de exame deletado
   */
  async publishExamDeleted(examType, examId, deletedData = null, userId = null) {
    const event = {
      data: {
        examType,
        examId,
        deletedData,
        userId: userId || deletedData?.userId || 'user-default',
        action: 'DELETED'
      }
    };

    return this.publish(this.routingKeys.EXAM_DELETED, event);
  }

  /**
   * Producer genérico para eventos CRUD
   * @param {string} action - 'created', 'updated' ou 'deleted'
   * @param {string} entityType - Tipo da entidade (ex: 'prova', 'sessao', 'questao')
   * @param {string} entityId - ID da entidade
   * @param {Object} data - Dados da entidade
   * @param {Object} options - Opções adicionais (userId, previousData, etc.)
   */
  async publishCrudEvent(action, entityType, entityId, data, options = {}) {
    const routingKeyMap = {
      created: this.routingKeys.EVENT_CREATED,
      updated: this.routingKeys.EVENT_UPDATED,
      deleted: this.routingKeys.EVENT_DELETED
    };

    const routingKey = routingKeyMap[action.toLowerCase()];
    if (!routingKey) {
      logger.error('❌ Ação CRUD inválida', { action, validActions: Object.keys(routingKeyMap) });
      return false;
    }

    const event = {
      data: {
        entityType,
        entityId,
        entityData: data,
        userId: options.userId || data?.userId || 'user-default',
        action: action.toUpperCase(),
        ...(action === 'updated' && options.previousData && { previousData: options.previousData }),
        ...(options.metadata && { metadata: options.metadata })
      }
    };

    return this.publish(routingKey, event);
  }

  /**
   * Producer genérico para eventos de exames
   * @param {string} action - 'created', 'updated' ou 'deleted'
   * @param {string} examType - Tipo do exame (ex: 'prova', 'simulado', 'teste')
   * @param {string} examId - ID do exame
   * @param {Object} data - Dados do exame
   * @param {Object} options - Opções adicionais (userId, previousData, etc.)
   */
  async publishExamEvent(action, examType, examId, data, options = {}) {
    const routingKeyMap = {
      created: this.routingKeys.EXAM_CREATED,
      updated: this.routingKeys.EXAM_UPDATED,
      deleted: this.routingKeys.EXAM_DELETED
    };

    const routingKey = routingKeyMap[action.toLowerCase()];
    if (!routingKey) {
      logger.error('❌ Ação de exame inválida', { action, validActions: Object.keys(routingKeyMap) });
      return false;
    }

    const event = {
      data: {
        examType,
        examId,
        examData: data,
        userId: options.userId || data?.userId || 'user-default',
        action: action.toUpperCase(),
        ...(action === 'updated' && options.previousData && { previousData: options.previousData }),
        ...(options.metadata && { metadata: options.metadata })
      }
    };

    return this.publish(routingKey, event);
  }

  /**
   * Método básico para publicar eventos
   */
  async publish(routingKey, data, options = {}) {
    if (!this.isConnected || !this.channel) {
      logger.error('❌ RabbitMQ não conectado para publicar evento', { routingKey });
      return false;
    }

    try {
      const message = {
        messageId: `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
        timestamp: new Date().toISOString(),
        source: this.config.serviceName,
        routingKey,
        data
      };

      const messageBuffer = Buffer.from(JSON.stringify(message));

      const published = await this.channel.publish(
        this.config.exchange,
        routingKey,
        messageBuffer,
        {
          persistent: true,
          timestamp: Date.now(),
          ...options
        }
      );

      if (published) {
        logger.info('📤 Evento publicado com sucesso', {
          routingKey,
          messageId: message.messageId,
          exchange: this.config.exchange
        });
      }

      return published;
    } catch (error) {
      logger.error('❌ Erro ao publicar evento', {
        routingKey,
        error: error.message
      });
      return false;
    }
  }  /**
   * Publica evento simples de notificação para evento criado
   */
  async publishEventoNotificacao(eventoData) {
    const event = {
      data: {
        ...eventoData,
        userId: eventoData.userId || 'user-default'
      }
    };

    return this.publish('notificacao.evento.criado', event);
  }

  /**
   * Publica evento simples de notificação para sessão criada
   */
  async publishSessaoNotificacao(sessaoData) {
    const event = {
      data: {
        ...sessaoData,
        userId: sessaoData.userId || 'user-default'
      }
    };

    return this.publish('notificacao.sessao.criada', event);
  }
            acoes: ['finalizar_preparacao', 'mentalizar_objetivos', 'postura_estudo']
          }
        });
      }

      // Lembrete no momento exato da sessão
      event.data.notificacoes.push({
        tipo: 'lembrete_inicio',
        dataEnvio: tempoInicio.toISOString(),
        titulo: `🚀 ${contextoSessao.emoji} AGORA: ${contextoSessao.titulo}!`,
        mensagem: `${contextoSessao.mensagemInicio} "${sessaoData.conteudo}"! 🎯\n\n${contextoSessao.ritualInicio}\n\n📚 Foco total em: ${sessaoData.topicos?.join(', ') || 'seus objetivos'}\n\n⏱️ Duração: ${duracao}\n\n${contextoSessao.motivacao}\n\n🧠 ${contextoSessao.tecnicaConcentracao}`,
        prioridade: 'critica',
        categoria: 'sessao_inicio',
        dados: {
          topicos: sessaoData.topicos,
          duracao: duracao,
          tecnicas: contextoSessao.tecnicasEstudo,
          pausas: contextoSessao.intervalos,
          meta: contextoSessao.metaSessao,
          acoes: ['iniciar_cronometro', 'aplicar_pomodoro', 'modo_foco_total', 'postura_correta']
        }
      });

      // Se a sessão for longa (>2h), adicionar lembrete de pausa
      if (sessaoData.tempoFim) {
        const fimSessao = new Date(sessaoData.tempoFim);
        const duracaoMs = fimSessao - tempoInicio;
        const duracaoHoras = duracaoMs / (1000 * 60 * 60);

        if (duracaoHoras > 2) {
          const metadeSessao = new Date(tempoInicio.getTime() + duracaoMs / 2);
          event.data.notificacoes.push({
            tipo: 'lembrete_pausa',
            dataEnvio: metadeSessao.toISOString(),
            titulo: `🧘‍♀️ ${contextoSessao.emoji} Hora da Pausa Revigorante!`,
            mensagem: `Você está no meio da sua sessão de ${contextoSessao.titulo.toLowerCase()}! 💪\n\n🎉 Parabéns pelo foco até aqui!\n\n⏸️ Faça uma pausa de 15-20 minutos:\n• Alongue-se 🤸‍♀️\n• Hidrate-se 💧\n• Respire ar puro 🌱\n• Descanse os olhos 👀\n\n${contextoSessao.dicaPausa}\n\nDepois volte com tudo! 🔥`,
            prioridade: 'media',
            categoria: 'pausa_sessao',
            dados: {
              progressoAtual: '50%',
              tempoRestante: this._calcularDuracaoSessao({ tempoInicio: metadeSessao, tempoFim: sessaoData.tempoFim }),
              proximosTopicos: sessaoData.topicos?.slice(Math.ceil(sessaoData.topicos.length / 2)) || [],
              acoes: ['alongar', 'hidratar', 'respirar', 'descansar_olhos']
            }
          });
        }
      }
    }

    return this.publish('notificacao.sessao.criada', event);
  }
  /**
   * Contexto personalizado para sessões baseado no conteúdo
   */
  _getSessaoContexto(sessaoData) {
    const conteudo = (sessaoData.conteudo || '').toLowerCase();
    const topicos = (sessaoData.topicos || []).join(' ').toLowerCase();
    const texto = `${conteudo} ${topicos}`;

    // Detectar contexto baseado no conteúdo com contextos muito mais ricos
    if (texto.includes('matemática') || texto.includes('cálculo') || texto.includes('álgebra') ||
      texto.includes('geometria') || texto.includes('trigonometria') || texto.includes('função') ||
      texto.includes('equação') || texto.includes('logaritmo') || texto.includes('matriz')) {
      return {
        emoji: '🔢',
        materia: 'Matemática',
        titulo: 'Sessão de Matemática',
        tipo: 'exata',
        dificuldade: 'alta',
        mensagemCriacao: 'Sua sessão de matemática',
        descricaoDetalhada: 'A matemática é a linguagem do universo! Cada problema resolvido é uma vitória.',
        dicaPreparacao: '💡 Tenha sempre papel, lápis, borracha e calculadora à mão!',
        lembretePreparacao: 'Prepare suas ferramentas matemáticas!',
        checklistPreparacao: '✅ Fórmulas importantes\n✅ Calculadora científica\n✅ Papel milimetrado\n✅ Régua e compasso',
        dicaUltimahora: 'Revise as fórmulas básicas antes de começar!',
        ultimoAviso: 'É hora de dominar os números!',
        fraseMotivacional: '"A matemática é o alfabeto com o qual Deus escreveu o universo" - Galileu',
        objetivosEspecificos: '• Resolver exercícios práticos\n• Memorizar fórmulas-chave\n• Entender conceitos fundamentais',
        boostFinal: 'Cada cálculo correto é um passo para o sucesso! 🧮',
        mensagemInicio: 'Vamos dominar os números!',
        ritualInicio: '🔢 Respire, organize suas fórmulas e vamos calcular!',
        motivacao: 'Cada problema resolvido é um passo para a excelência! 📐',
        tecnicaConcentracao: 'Use o método "ver-fazer-explicar": veja o exemplo, faça similar, explique o processo.',
        preparacao: 'Separe: calculadora, lápis, borracha e muita determinação! 🧮',
        ferramentas: ['Calculadora científica', 'Papel milimetrado', 'Régua', 'Compasso', 'Tabela de fórmulas'],
        tecnicasEstudo: ['Resolução progressiva', 'Mapas conceituais', 'Exercícios práticos'],
        intervalos: 'A cada 45 min: pausa de 10 min para evitar fadiga mental',
        metaSessao: 'Dominar conceitos e resolver exercícios com confiança',
        objetivo: 'Desenvolver raciocínio lógico-matemático',
        dicas: ['Sempre confira os cálculos', 'Desenhe quando possível', 'Use exemplos práticos'],
        dicaPausa: 'Faça um exercício físico leve - isso oxigena o cérebro para cálculos!',
        ambienteIdeal: 'Mesa organizada, boa iluminação, sem ruídos',
        estadoMentalIdeal: 'Calmo, focado e paciente',
        checklist: ['Materiais de escrita', 'Calculadora', 'Fórmulas', 'Exercícios selecionados']
      };
    }

    if (texto.includes('física') || texto.includes('mecânica') || texto.includes('eletricidade') ||
      texto.includes('óptica') || texto.includes('termodinâmica') || texto.includes('ondas') ||
      texto.includes('força') || texto.includes('energia') || texto.includes('movimento')) {
      return {
        emoji: '⚡',
        materia: 'Física',
        titulo: 'Sessão de Física',
        tipo: 'exata',
        dificuldade: 'alta',
        mensagemCriacao: 'Sua sessão de física',
        descricaoDetalhada: 'A física desvenda os segredos do universo! Cada lei compreendida expande nossa visão.',
        dicaPreparacao: '🔬 Prepare experimentos mentais e visualize os fenômenos!',
        lembretePreparacao: 'Prepare-se para desvendar as leis do universo!',
        checklistPreparacao: '✅ Tabela de fórmulas\n✅ Calculadora científica\n✅ Diagrama de forças\n✅ Constantes físicas',
        dicaUltimahora: 'Visualize os fenômenos em sua mente antes de aplicar fórmulas!',
        ultimoAviso: 'As leis da física te aguardam!',
        fraseMotivacional: '"A imaginação é mais importante que o conhecimento" - Einstein',
        objetivosEspecificos: '• Compreender fenômenos físicos\n• Aplicar leis e princípios\n• Resolver problemas práticos',
        boostFinal: 'Você está prestes a compreender o universo! 🌌',
        mensagemInicio: 'Hora de desvendar o universo!',
        ritualInicio: '⚡ Imagine os fenômenos, visualize as forças e aplique as leis!',
        motivacao: 'A física explica tudo ao nosso redor! Seja curioso(a)! 🌌',
        tecnicaConcentracao: 'Técnica "Fenômeno-Lei-Aplicação": observe o fenômeno, identifique a lei, aplique na prática.',
        preparacao: 'Tenha fórmulas, calculadora e imaginação prontas! 🚀',
        ferramentas: ['Tabela de constantes', 'Calculadora', 'Diagramas', 'Gráficos', 'Simuladores online'],
        tecnicasEstudo: ['Experimentos mentais', 'Diagramas de força', 'Analogias práticas'],
        intervalos: 'A cada 50 min: pausa ativa com movimento para internalizar conceitos de movimento',
        metaSessao: 'Compreender princípios físicos e aplicá-los corretamente',
        objetivo: 'Desenvolver pensamento científico e analítico',
        dicas: ['Sempre desenhe diagramas', 'Use analogias do cotidiano', 'Visualize antes de calcular'],
        dicaPausa: 'Observe a física ao seu redor durante a pausa - a gravidade, o movimento, a luz!',
        ambienteIdeal: 'Espaço para desenhar, boa ventilação, materiais visuais',
        estadoMentalIdeal: 'Curioso, questionador e observador',
        checklist: ['Fórmulas físicas', 'Constantes', 'Papel para diagramas', 'Calculadora científica']
      };
    }

    if (texto.includes('química') || texto.includes('orgânica') || texto.includes('reações') ||
      texto.includes('átomo') || texto.includes('molécula') || texto.includes('elemento') ||
      texto.includes('ligação') || texto.includes('pH') || texto.includes('equilíbrio')) {
      return {
        emoji: '🧪',
        materia: 'Química',
        titulo: 'Sessão de Química',
        tipo: 'exata',
        dificuldade: 'alta',
        mensagemCriacao: 'Sua sessão de química',
        descricaoDetalhada: 'A química é a arte de transformar! Cada reação é uma dança molecular fascinante.',
        dicaPreparacao: '⚗️ Visualize as moléculas e suas interações tridimensionais!',
        lembretePreparacao: 'Prepare o laboratório mental!',
        checklistPreparacao: '✅ Tabela periódica\n✅ Fórmulas estruturais\n✅ Calculadora\n✅ Papel para estruturas',
        dicaUltimahora: 'Relembre os grupos funcionais e tipos de reações!',
        ultimoAviso: 'As moléculas estão prontas para reagir!',
        fraseMotivacional: '"Na química, não há nada mais excitante que uma reação inesperada"',
        objetivosEspecificos: '• Entender estruturas moleculares\n• Prever reações químicas\n• Balancear equações',
        boostFinal: 'Você é o químico das suas transformações! ⚗️',
        mensagemInicio: 'Vamos criar algumas reações!',
        ritualInicio: '🧪 Organize sua tabela periódica e visualize as transformações!',
        motivacao: 'A química está em tudo! Transforme conhecimento em sucesso! ⚗️',
        tecnicaConcentracao: 'Método "Ver-Analisar-Prever": veja a estrutura, analise propriedades, preveja comportamento.',
        preparacao: 'Tabela periódica, fórmulas e muita concentração! 🔬',
        ferramentas: ['Tabela periódica', 'Modelos moleculares', 'Calculadora', 'Papel para estruturas'],
        tecnicasEstudo: ['Modelos tridimensionais', 'Mapas de reações', 'Flashcards de grupos funcionais'],
        intervalos: 'A cada 45 min: pausa para "reagir" com o ambiente - o ar que respiramos é química!',
        metaSessao: 'Dominar reações e compreender transformações moleculares',
        objetivo: 'Desenvolver visão molecular e capacidade de predição',
        dicas: ['Desenhe sempre as estruturas', 'Use modelos 3D mentais', 'Pense em analogias do dia a dia'],
        dicaPausa: 'Observe a química ao redor: a digestão, a fotossíntese, a oxidação!',
        ambienteIdeal: 'Mesa limpa e organizada como um laboratório, boa ventilação',
        estadoMentalIdeal: 'Organizado, metódico e criativo',
        checklist: ['Tabela periódica', 'Fórmulas de compostos', 'Papel para estruturas', 'Calculadora']
      };
    }

    if (texto.includes('história') || texto.includes('brasil') || texto.includes('mundo') ||
      texto.includes('guerra') || texto.includes('revolução') || texto.includes('império') ||
      texto.includes('república') || texto.includes('colônia') || texto.includes('civilização')) {
      return {
        emoji: '🏛️',
        materia: 'História',
        titulo: 'Sessão de História',
        tipo: 'humana',
        dificuldade: 'média',
        mensagemCriacao: 'Sua sessão de história',
        descricaoDetalhada: 'A história é a memória da humanidade! Cada época tem lições para nossa vida.',
        dicaPreparacao: '📜 Prepare cronologias e conecte eventos passados ao presente!',
        lembretePreparacao: 'Prepare sua máquina do tempo mental!',
        checklistPreparacao: '✅ Linha do tempo\n✅ Mapas históricos\n✅ Lista de datas importantes\n✅ Biografias-chave',
        dicaUltimahora: 'Conecte os eventos: causa e consequência são fundamentais!',
        ultimoAviso: 'A máquina do tempo está pronta!',
        fraseMotivacional: '"Quem não conhece a história está condenado a repeti-la" - George Santayana',
        objetivosEspecificos: '• Compreender processos históricos\n• Conectar causa e consequência\n• Analisar fontes históricas',
        boostFinal: 'Você é um viajante do tempo do conhecimento! 🕰️',
        mensagemInicio: 'Hora de viajar no tempo!',
        ritualInicio: '🏛️ Abra sua mente para diferentes épocas e culturas!',
        motivacao: 'Cada período histórico tem lições para o presente! 📜',
        tecnicaConcentracao: 'Técnica "Contexto-Evento-Impacto": entenda o contexto, analise o evento, avalie o impacto.',
        preparacao: 'Organize cronologias, mapas e fatos importantes! 🗺️',
        ferramentas: ['Atlas histórico', 'Linha do tempo', 'Documentários', 'Mapas', 'Biografias'],
        tecnicasEstudo: ['Cronologia visual', 'Mapas mentais', 'Storytelling histórico'],
        intervalos: 'A cada 60 min: pausa reflexiva - pense sobre como a história influencia hoje',
        metaSessao: 'Compreender processos históricos e suas conexões',
        objetivo: 'Desenvolver consciência histórica e pensamento crítico',
        dicas: ['Crie narrativas', 'Use mapas e imagens', 'Compare épocas diferentes'],
        dicaPausa: 'Reflita sobre como os eventos estudados ainda influenciam nossa sociedade!',
        ambienteIdeal: 'Ambiente silencioso para reflexão, com mapas e cronologias visíveis',
        estadoMentalIdeal: 'Reflexivo, curioso sobre diferentes culturas',
        checklist: ['Cronologias', 'Mapas históricos', 'Datas importantes', 'Contextos sociais']
      };
    }

    if (texto.includes('português') || texto.includes('literatura') || texto.includes('redação') ||
      texto.includes('gramática') || texto.includes('texto') || texto.includes('interpretação') ||
      texto.includes('linguagem') || texto.includes('escrita') || texto.includes('leitura')) {
      return {
        emoji: '📝',
        materia: 'Português',
        titulo: 'Sessão de Português',
        tipo: 'linguística',
        dificuldade: 'média',
        mensagemCriacao: 'Sua sessão de português',
        descricaoDetalhada: 'O português é nossa ferramenta de expressão! Cada palavra bem escolhida é um poder.',
        dicaPreparacao: '✍️ Prepare textos diversos e exercite sua expressão!',
        lembretePreparacao: 'As palavras estão esperando por você!',
        checklistPreparacao: '✅ Dicionário\n✅ Gramática\n✅ Textos para análise\n✅ Papel para redação',
        dicaUltimahora: 'Leia um parágrafo em voz alta para aquecer a interpretação!',
        ultimoAviso: 'É hora de dominar nossa língua!',
        fraseMotivacional: '"As palavras têm o poder de destruir e criar. Quando as palavras são verdadeiras e gentis, podem mudar o mundo"',
        objetivosEspecificos: '• Melhorar interpretação textual\n• Aprimorar gramática\n• Desenvolver escrita clara',
        boostFinal: 'Sua eloquência é sua força! ✍️',
        mensagemInicio: 'Vamos dominar nossa língua!',
        ritualInicio: '📝 Respire, organize seus pensamentos e expresse-se!',
        motivacao: 'Palavras são poder! Use-as com maestria! ✍️',
        tecnicaConcentracao: 'Técnica "Ler-Compreender-Expressar": leia atentamente, compreenda profundamente, expresse claramente.',
        preparacao: 'Dicionário, gramática e criatividade em mãos! 📖',
        ferramentas: ['Dicionário completo', 'Gramática atualizada', 'Textos diversos', 'Caderno de redação'],
        tecnicasEstudo: ['Leitura ativa', 'Resumos criativos', 'Mapas semânticos'],
        intervalos: 'A cada 50 min: pausa para ler algo prazeroso - um poema, uma crônica',
        metaSessao: 'Aprimorar domínio da língua portuguesa em todas suas formas',
        objetivo: 'Desenvolver competência comunicativa completa',
        dicas: ['Leia sempre em voz alta', 'Anote palavras novas', 'Pratique diferentes gêneros textuais'],
        dicaPausa: 'Converse com alguém ou escreva seus pensamentos - pratique a expressão!',
        ambienteIdeal: 'Local silencioso para leitura, com dicionário sempre à mão',
        estadoMentalIdeal: 'Atento à beleza da linguagem, criativo',
        checklist: ['Textos selecionados', 'Dicionário', 'Gramática', 'Material de escrita']
      };
    }

    if (texto.includes('biologia') || texto.includes('célula') || texto.includes('genética') ||
      texto.includes('evolução') || texto.includes('ecologia') || texto.includes('anatomia') ||
      texto.includes('fisiologia') || texto.includes('botânica') || texto.includes('zoologia')) {
      return {
        emoji: '🧬',
        materia: 'Biologia',
        titulo: 'Sessão de Biologia',
        tipo: 'natural',
        dificuldade: 'média',
        mensagemCriacao: 'Sua sessão de biologia',
        descricaoDetalhada: 'A biologia é o estudo da vida! Cada célula, cada organismo tem uma história fascinante.',
        dicaPreparacao: '🔬 Visualize processos celulares e conexões ecológicas!',
        lembretePreparacao: 'Prepare-se para explorar os mistérios da vida!',
        checklistPreparacao: '✅ Atlas de anatomia\n✅ Esquemas celulares\n✅ Ciclos biológicos\n✅ Classificações',
        dicaUltimahora: 'Conecte estrutura e função - na biologia, forma e função andam juntas!',
        ultimoAviso: 'A vida em suas múltiplas formas te espera!',
        fraseMotivacional: '"Nada em biologia faz sentido exceto à luz da evolução" - Theodosius Dobzhansky',
        objetivosEspecificos: '• Compreender processos vitais\n• Conectar estrutura e função\n• Analisar relações ecológicas',
        boostFinal: 'Você está conectado(a) com toda a vida do planeta! 🌱',
        mensagemInicio: 'Vamos explorar os mistérios da vida!',
        ritualInicio: '🧬 Conecte-se com a vida ao seu redor e mergulhe nos processos vitais!',
        motivacao: 'Você é parte dessa teia incrível da vida! 🌿',
        tecnicaConcentracao: 'Técnica "Macro-Micro-Função": veja o organismo completo, analise partes, compreenda funções.',
        preparacao: 'Atlas, esquemas e curiosidade sobre a vida! 🔬',
        ferramentas: ['Atlas biológico', 'Modelos celulares', 'Esquemas de sistemas', 'Classificações'],
        tecnicasEstudo: ['Diagramas de processos', 'Comparações evolutivas', 'Ciclos biológicos'],
        intervalos: 'A cada 45 min: pausa ao ar livre para observar a biologia em ação',
        metaSessao: 'Compreender a complexidade e beleza dos sistemas vivos',
        objetivo: 'Desenvolver visão integrada da vida',
        dicas: ['Sempre conecte com exemplos reais', 'Use analogias corporais', 'Observe a natureza'],
        dicaPausa: 'Observe plantas, animais ou até suas próprias células trabalhando!',
        ambienteIdeal: 'Ambiente natural quando possível, com boa iluminação para observação',
        estadoMentalIdeal: 'Curioso sobre a vida, observador da natureza',
        checklist: ['Atlas biológico', 'Esquemas de sistemas', 'Ciclos e processos', 'Classificações']
      };
    }

    if (texto.includes('geografia') || texto.includes('território') || texto.includes('relevo') ||
      texto.includes('clima') || texto.includes('população') || texto.includes('economia') ||
      texto.includes('urbanização') || texto.includes('globalização') || texto.includes('cartografia')) {
      return {
        emoji: '🌍',
        materia: 'Geografia',
        titulo: 'Sessão de Geografia',
        tipo: 'espacial',
        dificuldade: 'média',
        mensagemCriacao: 'Sua sessão de geografia',
        descricaoDetalhada: 'A geografia conecta o mundo! Cada lugar tem sua identidade e suas conexões globais.',
        dicaPreparacao: '🗺️ Tenha mapas e atlas sempre por perto para visualizar!',
        lembretePreparacao: 'Prepare sua visão espacial do mundo!',
        checklistPreparacao: '✅ Atlas mundial\n✅ Mapas temáticos\n✅ Dados estatísticos\n✅ Imagens de satélite',
        dicaUltimahora: 'Pense sempre na escala: local, regional, nacional, global!',
        ultimoAviso: 'O mundo inteiro está esperando por você!',
        fraseMotivacional: '"A geografia é a ciência que estuda a diferenciação espacial da superfície terrestre"',
        objetivosEspecificos: '• Compreender relações espaciais\n• Analisar paisagens\n• Conectar local e global',
        boostFinal: 'Você tem o mundo inteiro na sua mente! 🌎',
        mensagemInicio: 'Vamos explorar nosso planeta!',
        ritualInicio: '🌍 Visualize os espaços, conecte os lugares e analise as relações!',
        motivacao: 'Cada lugar tem sua história e suas conexões! 🗺️',
        tecnicaConcentracao: 'Técnica "Localizar-Analisar-Conectar": localize no espaço, analise características, conecte com outros lugares.',
        preparacao: 'Mapas, atlas e visão espacial aguçada! 🧭',
        ferramentas: ['Atlas completo', 'Mapas temáticos', 'Google Earth', 'Dados estatísticos', 'Fotos aéreas'],
        tecnicasEstudo: ['Análise de mapas', 'Comparações regionais', 'Estudos de caso'],
        intervalos: 'A cada 50 min: olhe pela janela e observe a geografia ao seu redor',
        metaSessao: 'Desenvolver consciência espacial e visão geográfica integrada',
        objetivo: 'Compreender as relações entre sociedade e natureza no espaço',
        dicas: ['Use sempre mapas', 'Compare escalas diferentes', 'Conecte com atualidades'],
        dicaPausa: 'Observe a paisagem ao redor - relevo, uso do solo, circulação!',
        ambienteIdeal: 'Mesa ampla para mapas, boa visão do exterior',
        estadoMentalIdeal: 'Observador espacial, conectivo, analítico',
        checklist: ['Atlas atualizado', 'Mapas diversos', 'Dados atuais', 'Régua para escalas']
      };
    }

    // Contexto padrão mais rico para outras matérias
    return {
      emoji: '📚',
      materia: 'Estudo Geral',
      titulo: 'Sessão de Estudo',
      tipo: 'geral',
      dificuldade: 'variável',
      mensagemCriacao: 'Sua sessão de estudo',
      descricaoDetalhada: 'O conhecimento é uma jornada! Cada sessão de estudo é um passo para seus objetivos.',
      dicaPreparacao: '📖 Organize seus materiais e prepare sua mente para aprender!',
      lembretePreparacao: 'Chegou a hora de expandir horizontes!',
      checklistPreparacao: '✅ Material de estudo\n✅ Anotações organizadas\n✅ Ambiente preparado\n✅ Objetivos claros',
      dicaUltimahora: 'Defina objetivos claros para esta sessão!',
      ultimoAviso: 'Sua mente está pronta para absorver conhecimento!',
      fraseMotivacional: '"Conhecimento é poder, e poder é liberdade"',
      objetivosEspecificos: '• Compreender conceitos-chave\n• Fazer conexões importantes\n• Aplicar conhecimentos',
      boostFinal: 'Você está construindo seu futuro com conhecimento! 🎓',
      mensagemInicio: 'Vamos estudar com propósito e foco!',
      ritualInicio: '📚 Respire fundo, foque nos objetivos e mergulhe no conhecimento!',
      motivacao: 'Conhecimento é o único tesouro que ninguém pode roubar! 💎',
      tecnicaConcentracao: 'Técnica "Objetivo-Método-Revisão": defina o objetivo, escolha o método, revise o aprendido.',
      preparacao: 'Organize seus materiais e prepare a mente! 🧠',
      ferramentas: ['Material de estudo', 'Caderno de anotações', 'Marcadores', 'Timer'],
      tecnicasEstudo: ['Leitura ativa', 'Resumos', 'Mapas mentais', 'Questionários'],
      intervalos: 'A cada 45 min: pausa ativa para consolidar o aprendizado',
      metaSessao: 'Alcançar compreensão profunda e duradoura do conteúdo',
      objetivo: 'Desenvolver conhecimento sólido e habilidades de estudo',
      dicas: ['Faça anotações próprias', 'Teste seu entendimento', 'Conecte com experiências'],
      dicaPausa: 'Reflita sobre o que aprendeu e como pode aplicar!',
      ambienteIdeal: 'Local organizado, silencioso, bem iluminado',
      estadoMentalIdeal: 'Focado, motivado, receptivo ao aprendizado',
      checklist: ['Material organizado', 'Objetivos definidos', 'Ambiente preparado', 'Tempo planejado']
    };
  }

  /**
   * Calcula duração da sessão em formato amigável
   */
  _calcularDuracaoSessao(sessaoData) {
    if (!sessaoData.tempoInicio || !sessaoData.tempoFim) {
      return 'Duração não definida';
    }

    const inicio = new Date(sessaoData.tempoInicio);
    const fim = new Date(sessaoData.tempoFim);
    const duracaoMs = fim - inicio;
    const horas = Math.floor(duracaoMs / (1000 * 60 * 60));
    const minutos = Math.floor((duracaoMs % (1000 * 60 * 60)) / (1000 * 60));

    if (horas > 0) {
      return `${horas}h${minutos > 0 ? ` ${minutos}min` : ''}`;
    }
    return `${minutos}min`;
  }

  /**
   * Manipula erros de conexão
   */
  handleConnectionError(error) {
    logger.error('❌ Erro de conexão RabbitMQ', { error: error.message });
    this.isConnected = false;
  }

  /**
   * Manipula fechamento de conexão
   */
  async handleConnectionClose() {
    logger.warn('⚠️ Conexão RabbitMQ fechada');
    this.isConnected = false;
    await this.handleReconnect();
  }

  /**
   * Manipula erros de canal
   */
  handleChannelError(error) {
    logger.error('❌ Erro de canal RabbitMQ', { error: error.message });
  }

  /**
   * Gerencia reconexão automática
   */
  async handleReconnect() {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      logger.error('💀 Máximo de tentativas de reconexão atingido');
      return;
    }

    this.reconnectAttempts++;

    logger.info(`🔄 Tentativa de reconexão ${this.reconnectAttempts}/${this.maxReconnectAttempts}...`);

    setTimeout(async () => {
      await this.connect();
    }, this.reconnectDelay);
  }

  /**
   * Fecha conexão graciosamente
   */
  async close() {
    try {
      if (this.channel) {
        await this.channel.close();
      }
      if (this.connection) {
        await this.connection.close();
      }
      this.isConnected = false;
      logger.info('🔒 Conexão RabbitMQ fechada');
    } catch (error) {
      logger.error('❌ Erro ao fechar conexão RabbitMQ', { error: error.message });
    }
  }

  /**
   * Verifica se está conectado
   */
  isHealthy() {
    return this.isConnected && this.connection && !this.connection.connection.stream.destroyed;
  }
}

// Singleton instance
const rabbitMQService = new RabbitMQService();
export default rabbitMQService;