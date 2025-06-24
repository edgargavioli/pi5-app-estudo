import { z } from 'zod';

// Validação customizada para datetime mais flexível
const datetimeSchema = z.string().refine((val) => {
    try {
        const date = new Date(val);
        return !isNaN(date.getTime()) && val.includes('T');
    } catch {
        return false;
    }
}, {
    message: 'Formato de data/hora inválido'
});

const sessaoEstudoSchema = z.object({
    userId: z.string().uuid('ID do usuário inválido'),
    materiaId: z.string().uuid('ID da matéria inválido'),
    tempoInicio: datetimeSchema.optional(),
    tempoFim: datetimeSchema.optional(),
    conteudo: z.string().min(1, 'Conteúdo é obrigatório'),
    topicos: z.array(z.string()).min(1, 'Pelo menos um tópico é obrigatório'),
    provaId: z.string().uuid('ID da prova inválido').optional(),
    eventoId: z.string().uuid('ID do evento inválido').optional(),
    // Campos para sessões agendadas
    isAgendada: z.boolean().optional().default(false),
    horarioAgendado: datetimeSchema.optional(),
    metaTempo: z.number().min(1, 'Meta de tempo deve ser maior que 0').optional(),
    // Campos para finalização
    finalizada: z.boolean().optional().default(false),
    questoesAcertadas: z.number().min(0, 'Questões acertadas deve ser maior ou igual a 0').optional().default(0),
    totalQuestoes: z.number().min(0, 'Total de questões deve ser maior ou igual a 0').optional().default(0)
}).refine((data) => {
    // Se é agendada, deve ter horário e meta de tempo
    if (data.isAgendada) {
        if (!data.horarioAgendado) {
            throw new Error('Sessão agendada deve ter horário definido');
        }
        if (!data.metaTempo) {
            throw new Error('Sessão agendada deve ter meta de tempo definida');
        }
    }
    return true;
}, {
    message: 'Dados de sessão agendada inválidos'
});

export class SessaoEstudoValidator {
    static validate(data) {
        try {
            return sessaoEstudoSchema.parse(data);
        } catch (error) {
            throw new Error(`Erro de validação: ${error.message}`);
        }
    }
} 