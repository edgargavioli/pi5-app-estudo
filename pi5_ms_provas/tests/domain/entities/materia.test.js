import { describe, test, expect } from '@jest/globals';
import { Materia } from '../../../src/domain/entities/Materia.js';

describe('Materia Entity', () => {
    describe('create method', () => {
        test('should create materia with valid data', () => {
            const materia = Materia.create('Matemática', 'Ciências Exatas');
            
            expect(materia.nome).toBe('Matemática');
            expect(materia.disciplina).toBe('Ciências Exatas');
            expect(materia.id).toBeDefined();
            expect(materia.createdAt).toBeInstanceOf(Date);
            expect(materia.updatedAt).toBeInstanceOf(Date);
        });

        test('should throw errors for invalid data', () => {
            expect(() => Materia.create('', 'Disciplina')).toThrow('Nome da matéria é obrigatório');
            expect(() => Materia.create('Nome', '')).toThrow('Disciplina é obrigatória');
            expect(() => Materia.create('  ', 'Disciplina')).toThrow('Nome da matéria é obrigatório');
            expect(() => Materia.create('Nome', '  ')).toThrow('Disciplina é obrigatória');
        });
    });
}); 