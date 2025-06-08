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
    eventoId: z.string().uuid('ID do evento inválido').optional()
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