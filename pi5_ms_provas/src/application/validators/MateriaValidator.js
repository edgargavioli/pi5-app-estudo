import { z } from 'zod';

const materiaSchema = z.object({
    nome: z.string().min(1, 'Nome é obrigatório'),
    descricao: z.string().optional(),
    disciplina: z.string().min(1, 'Disciplina é obrigatória')
});

export class MateriaValidator {
    static validate(data) {
        try {
            return materiaSchema.parse(data);
        } catch (error) {
            throw new Error(`Erro de validação: ${error.message}`);
        }
    }
} 