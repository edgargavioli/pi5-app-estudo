export default class Notification {
    constructor(
        id,
        userId,
        type,
        entityId,
        entityType,
        entityData,
        scheduledFor,
        status = 'PENDING'
    ) {
        this.id = id;
        this.userId = userId;
        this.type = type;
        this.entityId = entityId;
        this.entityType = entityType;
        this.entityData = entityData;
        this.scheduledFor = scheduledFor;
        this.status = status;
    }    // Gera o conteúdo dinamicamente baseado no tipo
    generateContent() {
        switch (this.type) {
            // Eventos
            case 'EVENTO_CRIADO':
                return this.generateEventCreatedContent();
            case 'EVENTO_LEMBRETE_3_DIAS':
                return this.generateEventReminderContent(3);
            case 'EVENTO_DIA':
                return this.generateEventTodayContent();

            // Provas
            case 'PROVA_CRIADA':
                return this.generateExamCreatedContent();
            case 'PROVA_LEMBRETE_1_SEMANA':
                return this.generateExamWeekReminderContent();
            case 'PROVA_LEMBRETE_3_DIAS':
                return this.generateExamReminderContent(3);
            case 'PROVA_LEMBRETE_1_DIA':
                return this.generateExamReminderContent(1);
            case 'PROVA_DIA':
                return this.generateExamTodayContent();
            case 'PROVA_1_HORA':
                return this.generateExamOneHourContent();

            // Sessões
            case 'SESSAO_CRIADA':
                return this.generateSessionCreatedContent();
            case 'SESSAO_INICIADA':
                return this.generateSessionStartedContent();
            case 'SESSAO_LEMBRETE':
                return this.generateSessionReminderContent();

            // Tipos legados
            case 'EVENT_REMINDER':
                return this.generateEventReminderContent();
            case 'EVENT_TODAY':
                return this.generateEventTodayContent();
            case 'EVENT_CREATED':
                return this.generateEventCreatedContent();
            case 'EXAM_WEEK_REMINDER':
                return this.generateExamWeekReminderContent();
            case 'EXAM_REMINDER':
                return this.generateExamReminderContent();
            case 'EXAM_TODAY':
                return this.generateExamTodayContent();
            case 'EXAM_CREATED':
                return this.generateExamCreatedContent();
            case 'SESSION_CREATED':
                return this.generateSessionCreatedContent();
            case 'SESSION_FINISHED':
                return this.generateSessionFinishedContent();
            case 'STREAK_WARNING':
                return this.generateStreakWarningContent();
            case 'STREAK_EXPIRED':
                return this.generateStreakExpiredContent();
            default:
                return {
                    title: 'Notificação',
                    body: 'Você tem uma nova notificação'
                };
        }
    } generateEventReminderContent(days = null) {
        const daysDiff = days || this.getDaysDifference(this.entityData.date || this.entityData.data);
        const entityName = this.entityData.titulo || this.entityData.name || 'Evento';
        const entityDate = this.entityData.data || this.entityData.date;

        if (daysDiff === 3) {
            return {
                title: `⏰ Lembrete: ${entityName} em 3 dias`,
                body: `O evento "${entityName}" acontecerá em 3 dias - ${new Date(entityDate).toLocaleDateString('pt-BR')}`
            };
        } else {
            return {
                title: `Lembrete: ${entityName}`,
                body: `O evento acontecerá em ${daysDiff} dias - ${new Date(entityDate).toLocaleDateString('pt-BR')}`
            };
        }
    }

    generateEventTodayContent() {
        const entityName = this.entityData.titulo || this.entityData.name || 'Evento';
        const entityTime = this.entityData.horario || this.entityData.time;
        const timeStr = entityTime ? new Date(entityTime).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' }) : '';

        return {
            title: `🔥 HOJE: ${entityName}!`,
            body: `O evento "${entityName}" acontece hoje${timeStr ? ` às ${timeStr}` : ''}! 🎯`
        };
    }

    generateEventCreatedContent() {
        const entityName = this.entityData.titulo || this.entityData.name || 'Evento';
        const entityDate = this.entityData.data || this.entityData.date;

        return {
            title: `📅 Novo evento criado`,
            body: `"${entityName}" foi adicionado para ${new Date(entityDate).toLocaleDateString('pt-BR')}`
        };
    }

    generateExamWeekReminderContent() {
        const entityName = this.entityData.titulo || this.entityData.name || 'Prova';
        const entityDate = this.entityData.data || this.entityData.date;

        return {
            title: `📚 Prova se aproximando`,
            body: `A prova "${entityName}" acontecerá em 1 semana - ${new Date(entityDate).toLocaleDateString('pt-BR')}`
        };
    } generateExamReminderContent(days = null) {
        const daysDiff = days || this.getDaysDifference(this.entityData.date || this.entityData.data);
        const entityName = this.entityData.titulo || this.entityData.name || 'Prova';
        const entityDate = this.entityData.data || this.entityData.date;
        const entityTime = this.entityData.horario || this.entityData.time;

        if (daysDiff === 1) {
            return {
                title: `🔔 AMANHÃ é dia de prova!`,
                body: `A prova "${entityName}" é AMANHÃ! 📚\n✅ Separe seus materiais\n✅ Descanse bem\n✅ Confie no seu preparo!`
            };
        } else if (daysDiff === 3) {
            return {
                title: `⏰ Prova em 3 dias - Revisão final!`,
                body: `A prova "${entityName}" é em 3 dias! 🎯\nFaça uma revisão geral dos tópicos principais!`
            };
        } else {
            return {
                title: `⏰ Lembrete: Prova em ${daysDiff} dias`,
                body: `Prova "${entityName}" - ${new Date(entityDate).toLocaleDateString('pt-BR')}`
            };
        }
    }

    generateExamOneHourContent() {
        const entityName = this.entityData.titulo || this.entityData.name || 'Prova';
        const entityLocal = this.entityData.local || 'Local da prova';
        return {
            title: `⏰ Prova em 1 hora!`,
            body: `Sua prova "${entityName}" começa em 1 hora! ⏰\n\n✅ Verifique seus materiais\n✅ Saia com antecedência\n✅ Mantenha a calma!\n\n📍 ${entityLocal}`
        };
    }

    generateSessionStartedContent() {
        const sessionName = this.entityData.conteudo || this.entityData.name || 'Sessão de estudo';
        return {
            title: `🎯 Sessão iniciada!`,
            body: `Sua sessão "${sessionName}" começou! Foque e dê o seu melhor! 💪`
        };
    }

    generateSessionReminderContent() {
        const sessionName = this.entityData.conteudo || this.entityData.name || 'Sessão de estudo';
        return {
            title: `📚 Lembrete de sessão`,
            body: `Não esqueça da sua sessão "${sessionName}" hoje! 📅`
        };
    } generateExamTodayContent() {
        const entityName = this.entityData.titulo || this.entityData.name || 'Prova';
        const entityTime = this.entityData.horario || this.entityData.time;
        const timeStr = entityTime ? new Date(entityTime).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' }) : '';

        return {
            title: `🎯 HOJE é dia de prova!`,
            body: `Hoje é o dia da prova "${entityName}"${timeStr ? ` às ${timeStr}` : ''}! Você se preparou bem! Confie em si mesmo! 💪🍀 Boa sorte!`
        };
    }

    generateExamCreatedContent() {
        const entityName = this.entityData.titulo || this.entityData.name || 'Prova';
        const entityDate = this.entityData.data || this.entityData.date;

        return {
            title: `� Nova prova cadastrada`,
            body: `Prova "${entityName}" agendada para ${new Date(entityDate).toLocaleDateString('pt-BR')}`
        };
    }

    generateSessionCreatedContent() {
        const sessionName = this.entityData.conteudo || this.entityData.name || 'Sessão de estudo';

        return {
            title: `📚 Sessão de estudo criada`,
            body: `Sessão "${sessionName}" foi criada! Organize-se e bons estudos! 💪`
        };
    }

    generateSessionFinishedContent() {
        const score = this.entityData.score ? ` - Pontuação: ${this.entityData.score}%` : '';
        return {
            title: `✅ Sessão concluída`,
            body: `Parabéns! Você finalizou a sessão de ${this.entityData.name}${score}`
        };
    }

    generateStreakWarningContent() {
        const hoursLeft = this.getHoursUntilMidnight();
        return {
            title: `⚠️ Sua sequência ${this.entityData.name} expira hoje!`,
            body: `Você tem ${hoursLeft} horas para completar sua sequência de ${this.entityData.currentCount} dias`
        };
    }

    generateStreakExpiredContent() {
        return {
            title: `💔 Sequência perdida`,
            body: `Sua sequência ${this.entityData.name} de ${this.entityData.previousCount} dias foi perdida. Comece uma nova!`
        };
    }

    getDaysDifference(targetDate) {
        const today = new Date();
        const target = new Date(targetDate);
        const diffTime = target - today;
        return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    }

    getHoursUntilMidnight() {
        const now = new Date();
        const midnight = new Date();
        midnight.setHours(24, 0, 0, 0);
        return Math.ceil((midnight - now) / (1000 * 60 * 60));
    }

    static fromJson(json) {
        return new Notification(
            json.id,
            json.userId,
            json.type,
            json.entityId,
            json.entityType,
            json.entityData,
            json.scheduledFor,
            json.status
        );
    }

    toJson() {
        return {
            id: this.id,
            userId: this.userId,
            type: this.type,
            entityId: this.entityId,
            entityType: this.entityType,
            entityData: this.entityData,
            scheduledFor: this.scheduledFor,
            status: this.status
        };
    }
}