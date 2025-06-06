import { z } from 'zod';

const provaSchema = z.object({
    tipo: z.string().min(1, 'Tipo da prova é obrigatório'),
    data: z.string().datetime('Data inválida'),
    horario: z.string().datetime('Horário inválido'),
    local: z.string().min(1, 'Local é obrigatório'),
    materiaId: z.string().uuid('ID da matéria inválido'),
    filtros: z.record(z.any()).optional(),
    totalQuestoes: z.number().int().positive('Número total de questões deve ser um número inteiro positivo').optional().nullable(),
    acertos: z.number().int().min(0, 'Número de acertos deve ser um número inteiro não negativo').optional().nullable()
}).refine((data) => {
    // Validar que acertos não pode ser maior que totalQuestoes
    if (data.acertos !== null && data.acertos !== undefined && 
        data.totalQuestoes !== null && data.totalQuestoes !== undefined) {
        return data.acertos <= data.totalQuestoes;
    }
    return true;
}, {
    message: 'Número de acertos não pode ser maior que o total de questões',
    path: ['acertos']
});

export class ProvaValidator {
    static validate(data) {
        try {
            return provaSchema.parse(data);
        } catch (error) {
            throw new Error(`Erro de validação: ${error.message}`);
        }
    }
} 