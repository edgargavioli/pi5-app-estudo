import { describe, test, expect, beforeEach } from '@jest/globals';
import { Prova } from '../../../src/domain/entities/Prova.js';

describe('Prova Entity', () => {
    let prova;

    beforeEach(() => {
        prova = new Prova(
            'prova-123',
            'Prova de Matemática',
            'Prova sobre álgebra linear',
            new Date('2024-12-25'),
            new Date('2024-12-25T10:00:00'),
            'Sala 101',
            'materia-456',
            { dificuldade: 'média' },
            ['materia-456', 'materia-789']
        );
    });

    describe('Constructor', () => {
        test('should create prova with all properties', () => {
            expect(prova.id).toBe('prova-123');
            expect(prova.titulo).toBe('Prova de Matemática');
            expect(prova.descricao).toBe('Prova sobre álgebra linear');
            expect(prova.data).toEqual(new Date('2024-12-25'));
            expect(prova.horario).toEqual(new Date('2024-12-25T10:00:00'));
            expect(prova.local).toBe('Sala 101');
            expect(prova.materiaId).toBe('materia-456');
            expect(prova.filtros).toEqual({ dificuldade: 'média' });
            expect(prova.materias).toEqual(['materia-456', 'materia-789']);
            expect(prova.createdAt).toBeInstanceOf(Date);
            expect(prova.updatedAt).toBeInstanceOf(Date);
        });

        test('should create prova with optional parameters as null', () => {
            const provaSimples = new Prova('id', 'Título', null, new Date(), new Date(), 'Local');
            
            expect(provaSimples.descricao).toBeNull();
            expect(provaSimples.materiaId).toBeNull();
            expect(provaSimples.filtros).toBeNull();
            expect(provaSimples.materias).toEqual([]);
        });
    });

    describe('create method', () => {
        test('should create new prova with required fields', () => {
            const novaProva = Prova.create(
                'Nova Prova',
                'Descrição teste',
                '2024-12-30',
                '2024-12-30T14:00:00',
                'Sala 202'
            );

            expect(novaProva.titulo).toBe('Nova Prova');
            expect(novaProva.descricao).toBe('Descrição teste');
            expect(novaProva.data).toEqual(new Date('2024-12-30'));
            expect(novaProva.horario).toEqual(new Date('2024-12-30T14:00:00'));
            expect(novaProva.local).toBe('Sala 202');
            expect(novaProva.id).toBeDefined();
        });

        test('should throw error when titulo is missing', () => {
            expect(() => {
                Prova.create(null, 'Desc', '2024-12-30', '2024-12-30T14:00:00', 'Local');
            }).toThrow('Título da prova é obrigatório');
        });

        test('should throw error when data is missing', () => {
            expect(() => {
                Prova.create('Título', 'Desc', null, '2024-12-30T14:00:00', 'Local');
            }).toThrow('Data da prova é obrigatória');
        });

        test('should throw error when local is empty', () => {
            expect(() => {
                Prova.create('Título', 'Desc', '2024-12-30', '2024-12-30T14:00:00', '   ');
            }).toThrow('Local da prova é obrigatório');
        });
    });

    describe('update method', () => {
        test('should update prova fields correctly', async () => {
            const originalUpdatedAt = prova.updatedAt;
            
            // Aguardar um momento para garantir diferença no timestamp
            await new Promise(resolve => setTimeout(resolve, 10));
            
            prova.update(
                'Título Atualizado',
                'Nova descrição',
                '2025-01-15',
                '2025-01-15T15:00:00',
                'Sala 303',
                'nova-materia',
                { nivel: 'avançado' },
                ['materia-nova']
            );

            expect(prova.titulo).toBe('Título Atualizado');
            expect(prova.descricao).toBe('Nova descrição');
            expect(prova.data).toEqual(new Date('2025-01-15'));
            expect(prova.horario).toEqual(new Date('2025-01-15T15:00:00'));
            expect(prova.local).toBe('Sala 303');
            expect(prova.materiaId).toBe('nova-materia');
            expect(prova.filtros).toEqual({ nivel: 'avançado' });
            expect(prova.materias).toEqual(['materia-nova']);
            expect(prova.updatedAt).not.toEqual(originalUpdatedAt);
        });

        test('should throw error when updating local to empty string', () => {
            expect(() => {
                prova.update(null, null, null, null, '  ', null, null, null);
            }).toThrow('Local da prova não pode ser vazio');
        });
    });
}); 