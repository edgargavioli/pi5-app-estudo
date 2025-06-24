export class SessaoEstudo {
    constructor(id, materiaId, provaId, conteudo, topicos, tempoInicio, tempoFim = null,
        isAgendada = false, horarioAgendado = null, metaTempo = null,
        questoesAcertadas = 0, totalQuestoes = 0, finalizada = false) {
        this.id = id;
        this.materiaId = materiaId;
        this.provaId = provaId;
        this.conteudo = conteudo;
        this.topicos = topicos;
        this.tempoInicio = tempoInicio;
        this.tempoFim = tempoFim;
        this.isAgendada = isAgendada;
        this.horarioAgendado = horarioAgendado;
        this.metaTempo = metaTempo; // Duração planejada em minutos
        this.questoesAcertadas = questoesAcertadas;
        this.totalQuestoes = totalQuestoes;
        this.finalizada = finalizada;
        this.createdAt = new Date();
        this.updatedAt = new Date();
    } static create(materiaId, provaId, conteudo, topicos, tempoInicio = null,
        isAgendada = false, horarioAgendado = null, metaTempo = null) {
        if (!materiaId) {
            throw new Error('Matéria é obrigatória');
        }
        if (!conteudo || conteudo.trim().length === 0) {
            throw new Error('Conteúdo é obrigatório');
        }
        if (!topicos || !Array.isArray(topicos) || topicos.length === 0) {
            throw new Error('Tópicos são obrigatórios e devem ser um array não vazio');
        }
        if (isAgendada && !horarioAgendado) {
            throw new Error('Sessão agendada deve ter horário definido');
        }
        if (isAgendada && !metaTempo) {
            throw new Error('Sessão agendada deve ter meta de tempo definida');
        }

        return new SessaoEstudo(
            crypto.randomUUID(),
            materiaId,
            provaId,
            conteudo.trim(),
            topicos,
            tempoInicio,
            null, // tempoFim
            isAgendada,
            horarioAgendado,
            metaTempo
        );
    }

    finalizar() {
        if (this.tempoFim) {
            throw new Error('Sessão já foi finalizada');
        }
        this.tempoFim = new Date();
        this.updatedAt = new Date();
    }

    update(conteudo, topicos) {
        if (conteudo) {
            if (conteudo.trim().length === 0) {
                throw new Error('Conteúdo não pode ser vazio');
            }
            this.conteudo = conteudo.trim();
        }
        if (topicos) {
            if (!Array.isArray(topicos) || topicos.length === 0) {
                throw new Error('Tópicos devem ser um array não vazio');
            }
            this.topicos = topicos;
        }
        this.updatedAt = new Date();
    }

    getDuracao() {
        if (!this.tempoFim) {
            return null;
        }
        return this.tempoFim - this.tempoInicio;
    }

    // Calcular progresso baseado na meta de tempo
    calcularProgresso() {
        if (!this.tempoInicio || !this.tempoFim || !this.metaTempo) {
            return 0;
        }

        const tempoRealMinutos = (this.tempoFim - this.tempoInicio) / (1000 * 60);
        const progresso = (tempoRealMinutos / this.metaTempo) * 100;
        return Math.min(progresso, 100); // Máximo 100%
    }

    // Calcular XP com base no progresso da meta
    calcularXpComMeta(xpBase) {
        if (!this.isAgendada || !this.metaTempo) {
            return xpBase; // XP normal para sessões não agendadas
        }

        const progresso = this.calcularProgresso();

        if (progresso >= 100) {
            // Bonus por completar 100% da meta
            return Math.round(xpBase * 1.5);
        } else if (progresso >= 80) {
            // XP normal se completou pelo menos 80%
            return xpBase;
        } else {
            // XP reduzido proporcionalmente
            return Math.round(xpBase * (progresso / 100));
        }
    }

    // Verificar se sessão pode ser iniciada (para sessões agendadas)
    podeSerIniciada() {
        if (!this.isAgendada) {
            return true; // Sessões livres podem ser iniciadas a qualquer momento
        }

        const agora = new Date();
        const tolerancia = 30 * 60 * 1000; // 30 minutos de tolerância
        const horarioLimite = new Date(this.horarioAgendado.getTime() + tolerancia);

        return agora >= this.horarioAgendado && agora <= horarioLimite;
    }

    // Verificar se está no prazo
    estaNoPrazo() {
        if (!this.isAgendada || !this.horarioAgendado) {
            return null; // Não aplicável para sessões livres
        }

        const agora = new Date();
        const tolerancia = 30 * 60 * 1000; // 30 minutos de tolerância
        const horarioLimite = new Date(this.horarioAgendado.getTime() + tolerancia);

        return agora <= horarioLimite;
    }
}