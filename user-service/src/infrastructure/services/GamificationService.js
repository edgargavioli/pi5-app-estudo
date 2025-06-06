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
   */
  async adicionarXP(userId, xp, detalhes = {}) {
    try {
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
   * @param {number} xp - Total de XP
   * @returns {number} Level atual
   */
  calcularLevel(xp) {
    if (xp <= 0) return 1;

    let level = 1;
    let xpNecessario = this.levelConfig.baseXP;

    while (xp >= xpNecessario && level < this.levelConfig.maxLevel) {
      xp -= xpNecessario;
      level++;
      xpNecessario = Math.floor(this.levelConfig.baseXP * Math.pow(this.levelConfig.multiplier, level - 1));
    }

    return level;
  }

  /**
   * Calcular XP necessário para o próximo level
   * @param {number} levelAtual - Level atual do usuário
   * @returns {number} XP necessário para o próximo level
   */
  calcularXPProximoLevel(levelAtual) {
    if (levelAtual >= this.levelConfig.maxLevel) return 0;
    
    return Math.floor(this.levelConfig.baseXP * Math.pow(this.levelConfig.multiplier, levelAtual));
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
}

module.exports = GamificationService; 