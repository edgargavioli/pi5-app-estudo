const { PrismaClient } = require('@prisma/client');
const { AppError } = require('../../middleware/errorHandler');
const logger = require('../utils/logger');

const prisma = new PrismaClient();

/**
 * Gamification Service - Gerencia sistema de pontuação e conquistas
 * Responsável por XP, levels, achievements e estatísticas
 */
class GamificationService {
  constructor() {
    // Configurações do sistema de level
    this.levelConfig = {
      baseXP: 100,      // XP base para level 1
      multiplier: 1.5,  // Multiplicador por level
      maxLevel: 100     // Level máximo
    };

    // Tipos de conquistas disponíveis
    this.conquistas = {
      PRIMEIRO_ESTUDO: { xp: 50, titulo: 'Primeiro Passo', descricao: 'Primeira sessão de estudo' },
      MARATONISTA: { xp: 100, titulo: 'Maratonista', descricao: '3 horas de estudo em um dia' },
      PERSISTENTE: { xp: 150, titulo: 'Persistente', descricao: '7 dias seguidos estudando' },
      EXPERT: { xp: 200, titulo: 'Expert', descricao: '90% de acertos em uma prova' },
      DEDICADO: { xp: 250, titulo: 'Dedicado', descricao: '30 sessões de estudo completadas' }
    };
  }

  /**
   * Adicionar XP para um usuário
   * @param {string} userId - ID do usuário
   * @param {number} xp - Quantidade de XP a adicionar
   * @param {Object} detalhes - Detalhes da ação que gerou XP
   */  async adicionarXP(userId, xp, detalhes = {}) {
    try {
      // Validar userId
      if (!userId || typeof userId !== 'string') {
        logger.error('❌ UserId inválido para adicionar XP', {
          userId,
          typeOfUserId: typeof userId,
          xp,
          detalhes
        });
        throw new AppError('UserId inválido ou não fornecido', 400);
      }

      // Buscar usuário atual
      const usuario = await prisma.user.findUnique({
        where: { id: userId },
        select: { id: true, name: true, points: true }
      });

      if (!usuario) {
        throw new AppError('Usuário não encontrado', 404);
      }

      const pontosAnteriores = usuario.points || 0;
      const pontosNovos = pontosAnteriores + xp;

      // Calcular levels
      const levelAnterior = this.calcularLevel(pontosAnteriores);
      const levelNovo = this.calcularLevel(pontosNovos);
      const subiumLevel = levelNovo > levelAnterior;

      // Atualizar pontos do usuário
      const usuarioAtualizado = await prisma.user.update({
        where: { id: userId },
        data: { points: pontosNovos }
      });

      // Registrar histórico de XP
      await this.registrarHistoricoXP(userId, xp, detalhes);

      // Se subiu de level, registrar conquista
      if (subiumLevel) {
        await this.registrarSubidaLevel(userId, levelAnterior, levelNovo);
      }

      logger.info('🎮 XP adicionado com sucesso', {
        userId,
        xpAdicionado: xp,
        pontosAnteriores,
        pontosNovos,
        levelAnterior,
        levelNovo,
        subiumLevel
      });

      return {
        usuario: usuarioAtualizado,
        xpAdicionado: xp,
        pontosTotal: pontosNovos,
        level: levelNovo,
        subiumLevel,
        proximoLevel: levelNovo < this.levelConfig.maxLevel ? this.calcularXPProximoLevel(levelNovo) : null
      };

    } catch (error) {
      logger.error('❌ Erro ao adicionar XP', {
        userId,
        xp,
        error: error.message
      });
      throw error;
    }
  }
  /**
   * Calcular level baseado na quantidade de XP
   * EXATAMENTE IGUAL AO FRONTEND
   * @param {number} xp - Total de XP
   * @returns {number} Level atual
   */
  calcularLevel(xp) {
    if (xp <= 0) return 1;

    let level = 1;
    let xpNecessario = 100; // baseXP
    const multiplier = 1.5;

    // Mesmo algoritmo do frontend
    while (xp >= xpNecessario && level < 100) {
      xp -= xpNecessario;
      level++;
      xpNecessario = Math.floor(100 * Math.pow(multiplier, level - 1));
    }

    return level;
  }

  /**
   * Calcular XP necessário para o próximo level
   * EXATAMENTE IGUAL AO FRONTEND
   * @param {number} levelAtual - Level atual do usuário
   * @returns {number} XP necessário para o próximo level
   */
  calcularXPProximoLevel(levelAtual) {
    if (levelAtual >= 100) return 0;

    const baseXP = 100;
    const multiplier = 1.5;
    return Math.floor(baseXP * Math.pow(multiplier, levelAtual));
  }

  /**
   * Calcular XP atual no nível (quanto XP já foi ganho no nível atual)
   * @param {number} xpTotal - XP total do usuário
   * @param {number} levelAtual - Level atual
   * @returns {number} XP atual no nível
   */
  calcularXPAtualNoNivel(xpTotal, levelAtual) {
    if (xpTotal <= 0 || levelAtual <= 1) return xpTotal;

    // Calcular quanto XP foi gasto para chegar ao nível atual
    let xpGasto = 0;
    const baseXP = 100;
    const multiplier = 1.5;

    for (let i = 1; i < levelAtual; i++) {
      xpGasto += Math.floor(baseXP * Math.pow(multiplier, i - 1));
    }

    return xpTotal - xpGasto;
  }

  /**
   * Calcular XP que falta para o próximo nível
   * @param {number} xpTotal - XP total do usuário
   * @param {number} levelAtual - Level atual
   * @returns {number} XP que falta para o próximo nível
   */
  calcularXPFaltaProximoNivel(xpTotal, levelAtual) {
    if (levelAtual >= 100) return 0;

    const xpTotalProximoNivel = this.calcularXPProximoLevel(levelAtual);
    const xpAtualNoNivel = this.calcularXPAtualNoNivel(xpTotal, levelAtual);

    return Math.max(0, xpTotalProximoNivel - xpAtualNoNivel);
  }

  /**
   * Registrar histórico de XP ganho
   * @param {string} userId - ID do usuário
   * @param {number} xp - XP ganho
   * @param {Object} detalhes - Detalhes da ação
   */
  async registrarHistoricoXP(userId, xp, detalhes) {
    try {
      // Aqui você pode criar uma tabela de histórico se necessário
      // Por enquanto, vamos apenas logar
      logger.info('📊 XP registrado no histórico', {
        userId,
        xp,
        tipo: detalhes.tipo,
        referencia: detalhes.referencia,
        timestamp: new Date()
      });
    } catch (error) {
      logger.error('❌ Erro ao registrar histórico de XP', { userId, xp, error: error.message });
    }
  }

  /**
   * Registrar subida de level
   * @param {string} userId - ID do usuário
   * @param {number} levelAnterior - Level anterior
   * @param {number} levelNovo - Novo level
   */
  async registrarSubidaLevel(userId, levelAnterior, levelNovo) {
    try {
      logger.info('🎉 LEVEL UP!', {
        userId,
        levelAnterior,
        levelNovo,
        timestamp: new Date()
      });

      // Aqui você pode implementar notificações, conquistas especiais, etc.
      // Por exemplo, notificar o frontend sobre o level up

    } catch (error) {
      logger.error('❌ Erro ao registrar subida de level', { userId, error: error.message });
    }
  }

  /**
   * Desbloquear conquista para usuário
   * @param {string} userId - ID do usuário
   * @param {string} tipoConquista - Tipo da conquista
   * @param {Object} detalhes - Detalhes adicionais
   */
  async desbloquearConquista(userId, tipoConquista, detalhes = {}) {
    try {
      const conquista = this.conquistas[tipoConquista];
      if (!conquista) {
        logger.warn('⚠️ Tipo de conquista não encontrado', { tipoConquista });
        return null;
      }

      // Adicionar XP da conquista
      const resultado = await this.adicionarXP(userId, conquista.xp, {
        tipo: 'CONQUISTA',
        referencia: tipoConquista,
        descricao: conquista.titulo
      });

      logger.info('🏆 Conquista desbloqueada!', {
        userId,
        conquista: tipoConquista,
        titulo: conquista.titulo,
        xpGanho: conquista.xp
      });

      return {
        conquista,
        xpGanho: conquista.xp,
        resultado
      };

    } catch (error) {
      logger.error('❌ Erro ao desbloquear conquista', { userId, tipoConquista, error: error.message });
      throw error;
    }
  }

  /**
   * Obter estatísticas do usuário
   * @param {string} userId - ID do usuário
   * @returns {Object} Estatísticas completas
   */
  async obterEstatisticas(userId) {
    try {
      const usuario = await prisma.user.findUnique({
        where: { id: userId },
        select: { id: true, name: true, points: true }
      });

      if (!usuario) {
        throw new AppError('Usuário não encontrado', 404);
      }

      const pontos = usuario.points || 0;
      const level = this.calcularLevel(pontos);
      const xpProximoLevel = this.calcularXPProximoLevel(level);

      return {
        usuario: {
          id: usuario.id,
          name: usuario.name
        },
        pontos,
        level,
        xpProximoLevel,
        percentualProximoLevel: xpProximoLevel > 0 ? ((pontos % xpProximoLevel) / xpProximoLevel) * 100 : 100
      };

    } catch (error) {
      logger.error('❌ Erro ao obter estatísticas', { userId, error: error.message });
      throw error;
    }
  }
  /**
   * Calcular XP específico para sessões de estudo
   * ATUALIZADO: Usar mesma lógica do frontend para consistência
   * @param {Object} sessaoData - Dados da sessão de estudo
   * @returns {Object} Resultado do cálculo de XP
   */
  async calcularXpSessao(sessaoData) {
    try {
      const {
        tempoEstudoMinutos,
        isAgendada = false,
        metaTempo = null,
        cumpriuPrazo = null,
        questoesAcertadas = 0,
        totalQuestoes = 0
      } = sessaoData;      // 🎯 MESMA LÓGICA DO FRONTEND - AJUSTADA PARA TESTES
      let xpBase = 5; // XP base por finalizar sessão
      let xpTempo = Math.round(tempoEstudoMinutos * 1.5); // 1.5 XP por minuto  
      let xpQuestoes = questoesAcertadas * 3; // 3 XP por questão acertada

      // Para testes com tempo < 1 minuto, garantir pelo menos 1 XP de tempo
      if (tempoEstudoMinutos > 0 && xpTempo === 0) {
        xpTempo = 1;
      }

      let detalhes = [
        `Sessão finalizada: +${xpBase} XP`,
        `Tempo de estudo (${tempoEstudoMinutos} min): +${xpTempo} XP`
      ];

      if (questoesAcertadas > 0) {
        detalhes.push(`Questões corretas (${questoesAcertadas}): +${xpQuestoes} XP`);
      }

      let xpTotal = xpBase + xpTempo + xpQuestoes;

      // Bônus para sessões agendadas
      if (isAgendada) {
        if (cumpriuPrazo === true) {
          const bonus = Math.round(xpTotal * 0.5); // +50% bônus
          xpTotal += bonus;
          detalhes.push(`Bônus agendada no prazo: +${bonus} XP`);
        } else if (cumpriuPrazo === false) {
          const penalidade = Math.round(xpTotal * 0.2); // -20% penalidade
          xpTotal -= penalidade;
          detalhes.push(`Penalidade atraso: -${penalidade} XP`);
        }
      }

      // Garantir que o XP seja positivo
      xpTotal = Math.max(1, xpTotal);

      logger.info('🎮 XP calculado', {
        tempoEstudoMinutos,
        isAgendada,
        cumpriuPrazo,
        questoesAcertadas,
        totalQuestoes,
        xpBase,
        xpTempo,
        xpQuestoes,
        xpTotal,
        detalhes
      });

      return {
        xpTotal,
        detalhamento: {
          xpBase,
          xpTempo,
          xpQuestoes,
          xpTotal,
          detalhes
        }
      };

    } catch (error) {
      logger.error('❌ Erro ao calcular XP da sessão', { error: error.message, sessaoData });
      throw error;
    }
  }
  /**
   * Processar finalização de sessão com cálculo automático de XP
   * @param {string} userId - ID do usuário
   * @param {Object} sessaoData - Dados da sessão finalizada
   */
  async processarFinalizacaoSessao(userId, sessaoData) {
    try {
      logger.info('🎮 Processando finalização de sessão', {
        userId,
        sessaoId: sessaoData.id,
        tempoMinutos: sessaoData.tempoEstudoMinutos,
        isAgendada: sessaoData.isAgendada,
        questoes: `${sessaoData.questoesAcertadas}/${sessaoData.totalQuestoes}`
      });

      // Calcular XP da sessão
      const resultadoXp = await this.calcularXpSessao(sessaoData);

      // Adicionar XP ao usuário
      const resultado = await this.adicionarXP(userId, resultadoXp.xpTotal, {
        tipo: 'sessao_estudo',
        referencia: sessaoData.id || 'sessao_finalizada',
        detalhamento: resultadoXp.detalhamento
      }); logger.info('✅ Sessão processada com XP', {
        userId,
        sessaoId: sessaoData.id,
        xpGanho: resultadoXp.xpTotal,
        pontosTotal: resultado.pontosTotal,
        levelAnterior: resultado.level - (resultado.subiumLevel ? 1 : 0),
        levelAtual: resultado.level,
        subiumLevel: resultado.subiumLevel,
        detalhes: resultadoXp.detalhamento.detalhes
      });

      // Calcular informações adicionais para o frontend
      const xpFaltaProximoNivel = this.calcularXPFaltaProximoNivel(resultado.pontosTotal, resultado.level);
      const xpAtualNoNivel = this.calcularXPAtualNoNivel(resultado.pontosTotal, resultado.level);
      const xpTotalProximoNivel = this.calcularXPProximoLevel(resultado.level);
      const progressoNivel = xpTotalProximoNivel > 0 ? xpAtualNoNivel / xpTotalProximoNivel : 1.0;

      return {
        xpGanho: resultadoXp.xpTotal,
        xpTotal: resultado.pontosTotal,
        nivel: resultado.level,
        pontosTotal: resultado.pontosTotal,
        subiumLevel: resultado.subiumLevel,
        levelAnterior: resultado.level - (resultado.subiumLevel ? 1 : 0),
        proximoLevel: resultado.proximoLevel,
        xpProximoNivel: xpFaltaProximoNivel, // XP que falta para o próximo nível
        xpParaProximoNivel: xpFaltaProximoNivel, // Compatibilidade
        progressoNivel: progressoNivel,
        xpAtualNoNivel: xpAtualNoNivel,
        xpTotalProximoNivel: xpTotalProximoNivel,
        detalhes: resultadoXp.detalhamento.detalhes,
        detalhamentoXp: resultadoXp.detalhamento
      };

    } catch (error) {
      logger.error('❌ Erro ao processar finalização de sessão', { userId, error: error.message });
      throw error;
    }
  }
}

module.exports = GamificationService;