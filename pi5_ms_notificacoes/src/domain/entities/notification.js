export default class Notification3 {
    constructor(
        userId,
        type,
        entityId,
        entityType,
        entityData,
        scheduledFor,
        status = 'PENDING'
    ) {
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