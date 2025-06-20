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
    }

    // Gera o conteúdo dinamicamente baseado no tipo
    generateContent() {
        switch (this.type) {
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
    }

    generateEventReminderContent() {
        const daysDiff = this.getDaysDifference(this.entityData.date);
        return {
            title: `Lembrete: ${this.entityData.name}`,
            body: `O evento acontecerá em ${daysDiff} dias - ${new Date(this.entityData.date).toLocaleDateString('pt-BR')}`
        };
    }

    generateEventTodayContent() {
        return {
            title: `Hoje é o dia!`,
            body: `O evento ${this.entityData.name} acontece hoje às ${this.entityData.time}`
        };
    }

    generateEventCreatedContent() {
        return {
            title: `📅 Novo evento criado`,
            body: `${this.entityData.name} foi adicionado para ${new Date(this.entityData.date).toLocaleDateString('pt-BR')}`
        };
    }

    generateExamWeekReminderContent() {
        return {
            title: `📚 Prova se aproximando`,
            body: `A prova de ${this.entityData.name} acontecerá em 1 semana - ${new Date(this.entityData.date).toLocaleDateString('pt-BR')}`
        };
    }

    generateExamReminderContent() {
        const daysDiff = this.getDaysDifference(this.entityData.date);
        return {
            title: `⏰ Lembrete: Prova em ${daysDiff} dias`,
            body: `Prova de ${this.entityData.name} - ${new Date(this.entityData.date).toLocaleDateString('pt-BR')} às ${this.entityData.time}`
        };
    }

    generateExamTodayContent() {
        return {
            title: `🎯 Prova hoje!`,
            body: `Hoje é o dia da prova de ${this.entityData.name} às ${this.entityData.time}. Boa sorte!`
        };
    }

    generateExamCreatedContent() {
        return {
            title: `📋 Nova prova cadastrada`,
            body: `Prova de ${this.entityData.name} agendada para ${new Date(this.entityData.date).toLocaleDateString('pt-BR')}`
        };
    }

    generateSessionCreatedContent() {
        return {
            title: `🎯 Sessão de estudo iniciada`,
            body: `Sessão de ${this.entityData.name} começou agora. Boa sorte!`
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