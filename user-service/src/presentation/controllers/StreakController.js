const { PrismaClient } = require('@prisma/client');
const { DateTime } = require('luxon');

const prisma = new PrismaClient();

class StreakController {
    /**
     * @swagger
     * /api/users/{userId}/streak:
     *   get:
     *     summary: Obter informações da sequência de estudos do usuário
     *     tags: [Streaks]
     *     parameters:
     *       - in: path
     *         name: userId
     *         required: true
     *         schema:
     *           type: string
     *         description: ID do usuário
     *     responses:
     *       200:
     *         description: Informações da sequência obtidas com sucesso
     *         content:
     *           application/json:
     *             schema:
     *               type: object
     *               properties:
     *                 data:
     *                   type: object
     *                   properties:
     *                     currentStreak:
     *                       type: integer
     *                       description: Dias consecutivos atual
     *                     longestStreak:
     *                       type: integer
     *                       description: Maior sequência já alcançada
     *                     isActivatedToday:
     *                       type: boolean
     *                       description: Se já ativou a sequência hoje
     *                     studiedToday:
     *                       type: integer
     *                       description: Minutos estudados hoje
     *                     targetMinutes:
     *                       type: integer
     *                       description: Meta em minutos para ativar a sequência
     *                     needsToStudy:
     *                       type: boolean
     *                       description: Se ainda precisa estudar para ativar hoje
     *                 _links:
     *                   type: object
     *                   properties:
     *                     self:
     *                       type: object
     *                       properties:
     *                         href:
     *                           type: string
     *                     update:
     *                       type: object
     *                       properties:
     *                         href:
     *                           type: string
     *                     achievements:
     *                       type: object
     *                       properties:
     *                         href:
     *                           type: string
     *       404:
     *         description: Usuário não encontrado
     */    static async getStreak(req, res) {
        try {
            const { id: userId } = req.params;

            // Verificar se o usuário existe
            const user = await prisma.user.findUnique({
                where: { id: userId }
            });

            if (!user) {
                return res.status(404).json({
                    error: 'Usuário não encontrado',
                    code: 'USER_NOT_FOUND'
                });
            }

            // Buscar ou criar streak do usuário
            let streak = await prisma.studyStreak.findUnique({
                where: { userId }
            });

            if (!streak) {
                streak = await prisma.studyStreak.create({
                    data: {
                        userId,
                        currentStreak: 0,
                        longestStreak: 0,
                        targetMinutes: 0.17, // ~10 segundos para testes
                        timezone: 'America/Sao_Paulo'
                    }
                });
            }

            // Verificar se precisa resetar o dia
            await StreakController._checkAndResetDaily(streak);

            // Recarregar dados após possível reset
            streak = await prisma.studyStreak.findUnique({
                where: { userId }
            });

            const needsToStudy = streak.studiedToday < streak.targetMinutes;

            const response = {
                data: {
                    currentStreak: streak.currentStreak,
                    longestStreak: streak.longestStreak,
                    isActivatedToday: streak.isActivatedToday,
                    studiedToday: streak.studiedToday,
                    targetMinutes: streak.targetMinutes,
                    needsToStudy,
                    lastStudyDate: streak.lastStudyDate,
                    timezone: streak.timezone
                },
                _links: {
                    self: {
                        href: `/api/users/${userId}/streak`
                    },
                    update: {
                        href: `/api/users/${userId}/streak`,
                        method: 'PUT'
                    },
                    achievements: {
                        href: `/api/users/${userId}/streak/achievements`
                    }
                }
            };

            res.json(response);
        } catch (error) {
            console.error('Erro ao obter streak:', error);
            res.status(500).json({
                error: 'Erro interno do servidor',
                code: 'INTERNAL_ERROR'
            });
        }
    }

    /**
     * @swagger
     * /api/users/{userId}/streak:
     *   put:
     *     summary: Atualizar sequência de estudos (adicionar tempo estudado)
     *     tags: [Streaks]
     *     parameters:
     *       - in: path
     *         name: userId
     *         required: true
     *         schema:
     *           type: string
     *         description: ID do usuário
     *     requestBody:
     *       required: true
     *       content:
     *         application/json:
     *           schema:
     *             type: object
     *             properties:     *               studyMinutes:
     *                 type: number
     *                 description: Tempo de estudo em minutos (mínimo 10 segundos = 0.167 minutos)
     *                 minimum: 0.167
     *               timezone:
     *                 type: string
     *                 description: Fuso horário do usuário
     *                 default: "America/Sao_Paulo"
     *             required:
     *               - studyMinutes
     *     responses:
     *       200:
     *         description: Sequência atualizada com sucesso
     *         content:
     *           application/json:
     *             schema:
     *               type: object
     *               properties:
     *                 data:
     *                   type: object
     *                   properties:
     *                     activated:
     *                       type: boolean
     *                       description: Se a sequência foi ativada nesta sessão
     *                     currentStreak:
     *                       type: integer
     *                     newAchievements:
     *                       type: array
     *                       items:
     *                         type: object
     *                         properties:
     *                           streakDays:
     *                             type: integer
     *                           title:
     *                             type: string
     *                           description:
     *                             type: string
     *       400:
     *         description: Dados inválidos
     *       404:
     *         description: Usuário não encontrado
     */    static async updateStreak(req, res) {
        try {
            const { id: userId } = req.params;
            const { studyMinutes, timezone = 'America/Sao_Paulo' } = req.body; console.log('🔥 Streak update request:', {
                userId,
                studyMinutes,
                studyMinutesType: typeof studyMinutes,
                timezone,
                body: req.body
            });

            // Validar que o tempo de estudo seja pelo menos 10 segundos (0.167 minutos)
            const minStudyMinutes = 10 / 60; // 10 segundos em minutos = 0.167
            if (!studyMinutes || studyMinutes < minStudyMinutes) {
                console.log('🔥 Invalid study minutes:', studyMinutes, 'minimum required:', minStudyMinutes);
                return res.status(400).json({
                    error: 'Tempo de estudo deve ser pelo menos 10 segundos',
                    code: 'INVALID_STUDY_MINUTES',
                    minimumSeconds: 10
                });
            }

            // Verificar se o usuário existe
            const user = await prisma.user.findUnique({
                where: { id: userId }
            });

            if (!user) {
                return res.status(404).json({
                    error: 'Usuário não encontrado',
                    code: 'USER_NOT_FOUND'
                });
            }

            // Buscar ou criar streak
            let streak = await prisma.studyStreak.findUnique({
                where: { userId }
            });

            if (!streak) {
                streak = await prisma.studyStreak.create({
                    data: {
                        userId,
                        currentStreak: 0,
                        longestStreak: 0,
                        targetMinutes: 0.17,
                        timezone
                    }
                });
            }

            // Verificar reset diário
            await StreakController._checkAndResetDaily(streak);

            // Recarregar após possível reset
            streak = await prisma.studyStreak.findUnique({
                where: { userId }
            });

            const wasActivatedBefore = streak.isActivatedToday;
            const newStudiedMinutes = streak.studiedToday + studyMinutes;
            const willBeActivated = newStudiedMinutes >= streak.targetMinutes;
            const justActivated = !wasActivatedBefore && willBeActivated;

            // Atualizar streak
            const updatedData = {
                studiedToday: newStudiedMinutes,
                timezone,
                updatedAt: new Date()
            };

            if (justActivated) {
                updatedData.isActivatedToday = true;
                updatedData.lastStudyDate = new Date();
                updatedData.currentStreak = streak.currentStreak + 1;

                if (updatedData.currentStreak > streak.longestStreak) {
                    updatedData.longestStreak = updatedData.currentStreak;
                }
            }

            const updatedStreak = await prisma.studyStreak.update({
                where: { userId },
                data: updatedData
            });

            // Verificar conquistas
            const newAchievements = [];
            if (justActivated) {
                const achievements = await StreakController._checkAchievements(userId, updatedStreak.currentStreak);
                newAchievements.push(...achievements);
            }

            const response = {
                data: {
                    activated: justActivated,
                    currentStreak: updatedStreak.currentStreak,
                    longestStreak: updatedStreak.longestStreak,
                    studiedToday: updatedStreak.studiedToday,
                    isActivatedToday: updatedStreak.isActivatedToday,
                    newAchievements
                },
                _links: {
                    self: {
                        href: `/api/users/${userId}/streak`
                    },
                    achievements: {
                        href: `/api/users/${userId}/streak/achievements`
                    }
                }
            };

            res.json(response);
        } catch (error) {
            console.error('Erro ao atualizar streak:', error);
            res.status(500).json({
                error: 'Erro interno do servidor',
                code: 'INTERNAL_ERROR'
            });
        }
    }

    /**
     * @swagger
     * /api/users/{userId}/streak/achievements:
     *   get:
     *     summary: Obter conquistas de sequência do usuário
     *     tags: [Streaks]
     *     parameters:
     *       - in: path
     *         name: userId
     *         required: true
     *         schema:
     *           type: string
     *         description: ID do usuário
     *     responses:
     *       200:
     *         description: Conquistas obtidas com sucesso
     *         content:
     *           application/json:
     *             schema:
     *               type: object
     *               properties:
     *                 data:
     *                   type: array
     *                   items:
     *                     type: object
     *                     properties:
     *                       streakDays:
     *                         type: integer
     *                       title:
     *                         type: string
     *                       description:
     *                         type: string
     *                       unlockedAt:
     *                         type: string
     *                         format: date-time
     */
    static async getAchievements(req, res) {
        try {
            const { id: userId } = req.params;

            const achievements = await prisma.streakAchievement.findMany({
                where: { userId },
                orderBy: { streakDays: 'asc' }
            });

            const response = {
                data: achievements.map(achievement => ({
                    streakDays: achievement.streakDays,
                    title: achievement.title,
                    description: achievement.description,
                    unlockedAt: achievement.unlockedAt
                })),
                _links: {
                    self: {
                        href: `/api/users/${userId}/streak/achievements`
                    },
                    streak: {
                        href: `/api/users/${userId}/streak`
                    }
                }
            };

            res.json(response);
        } catch (error) {
            console.error('Erro ao obter conquistas:', error);
            res.status(500).json({
                error: 'Erro interno do servidor',
                code: 'INTERNAL_ERROR'
            });
        }
    }

    // Métodos auxiliares privados
    static async _checkAndResetDaily(streak) {
        const now = DateTime.now().setZone(streak.timezone);
        const lastReset = DateTime.fromJSDate(streak.lastResetDate).setZone(streak.timezone);

        // Verificar se mudou de dia
        if (now.day !== lastReset.day || now.month !== lastReset.month || now.year !== lastReset.year) {
            // Verificar se perdeu a sequência (não estudou ontem)
            const yesterday = now.minus({ days: 1 });
            const lastStudy = streak.lastStudyDate ?
                DateTime.fromJSDate(streak.lastStudyDate).setZone(streak.timezone) : null;

            let newCurrentStreak = streak.currentStreak;

            if (!lastStudy ||
                (lastStudy.day !== yesterday.day ||
                    lastStudy.month !== yesterday.month ||
                    lastStudy.year !== yesterday.year)) {
                // Perdeu a sequência
                newCurrentStreak = 0;
            }

            // Reset diário
            await prisma.studyStreak.update({
                where: { userId: streak.userId },
                data: {
                    isActivatedToday: false,
                    studiedToday: 0,
                    currentStreak: newCurrentStreak,
                    lastResetDate: now.toJSDate(),
                    updatedAt: new Date()
                }
            });
        }
    }

    static async _checkAchievements(userId, currentStreak) {
        const milestones = [3, 7, 15, 30, 60, 100, 150, 200, 365];
        const newAchievements = [];

        for (const milestone of milestones) {
            if (currentStreak >= milestone) {
                // Verificar se já tem essa conquista
                const existing = await prisma.streakAchievement.findUnique({
                    where: {
                        userId_streakDays: {
                            userId,
                            streakDays: milestone
                        }
                    }
                });

                if (!existing) {
                    const achievement = await prisma.streakAchievement.create({
                        data: {
                            userId,
                            streakDays: milestone,
                            title: StreakController._getAchievementTitle(milestone),
                            description: StreakController._getAchievementDescription(milestone)
                        }
                    });

                    newAchievements.push({
                        streakDays: achievement.streakDays,
                        title: achievement.title,
                        description: achievement.description
                    });
                }
            }
        }

        return newAchievements;
    }

    static _getAchievementTitle(days) {
        const titles = {
            3: '🔥 Começando a Queimar',
            7: '🔥 Uma Semana em Chamas',
            15: '🔥 Quinze Dias de Fogo',
            30: '🔥 Um Mês Incandescente',
            60: '🔥 Dois Meses de Dedicação',
            100: '🔥 Cem Dias de Pura Determinação',
            150: '🔥 Mestre da Consistência',
            200: '🔥 Lenda dos Estudos',
            365: '🔥 Um Ano Inteiro de Fogo!'
        };
        return titles[days] || `🔥 ${days} Dias Consecutivos`;
    } static _getAchievementDescription(days) {
        const descriptions = {
            3: 'Você manteve sua sequência por 3 dias consecutivos!',
            7: 'Uma semana inteira de dedicação aos estudos!',
            15: 'Quinze dias de disciplina e foco!',
            30: 'Um mês inteiro mantendo o compromisso com seus estudos!',
            60: 'Dois meses de consistência impressionante!',
            100: 'Cem dias de dedicação exemplar!',
            150: 'Você se tornou um mestre da consistência!',
            200: 'Uma verdadeira lenda dos estudos!',
            365: 'Um ano inteiro sem quebrar a sequência! Incrível!'
        };
        return descriptions[days] || `Manteve a sequência por ${days} dias consecutivos!`;
    }

    /**
     * Método para atualizar streak via eventos do RabbitMQ
     * Usado pelo EventHandler quando uma sessão é finalizada
     */
    static async updateStreakFromEvent(userId, studyMinutes, timezone = 'America/Sao_Paulo') {
        try {
            // Simular request object para reutilizar a lógica existente
            const mockReq = {
                params: { id: userId },
                body: {
                    studyMinutes,
                    timezone
                }
            };

            // Simular response object
            const mockRes = {
                status: () => mockRes,
                json: (data) => data
            };

            // Chamar o método updateStreak existente
            return await StreakController.updateStreak(mockReq, mockRes);
        } catch (error) {
            console.error('Erro ao atualizar streak via evento:', error);
            throw error;
        }
    }
}

module.exports = StreakController;
