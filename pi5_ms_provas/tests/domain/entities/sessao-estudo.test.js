import { describe, test, expect, beforeEach, jest } from '@jest/globals';
import { SessaoEstudo } from '../../../src/domain/entities/SessaoEstudo.js';

describe('SessaoEstudo Entity', () => {
    let sessao;

    beforeEach(() => {
        sessao = new SessaoEstudo(
            'sessao-123',
            'materia-456',
            'prova-789',
            'Álgebra Linear',
            ['Matrizes', 'Determinantes'],
            new Date('2024-12-20T10:00:00'),
            null,
            true,
            new Date('2024-12-20T10:00:00'),
            60,
            8,
            10,
            false
        );
    });

    describe('Cálculo de Duração', () => {
        test('should calculate duration correctly when finished', () => {
            const inicio = new Date('2024-12-20T10:00:00');
            const fim = new Date('2024-12-20T11:30:00');
            
            sessao.tempoInicio = inicio;
            sessao.tempoFim = fim;

            const duracao = sessao.getDuracao();
            const duracaoEsperada = fim - inicio; // 90 minutos em ms
            
            expect(duracao).toBe(duracaoEsperada);
        });

        test('should return null when session is not finished', () => {
            sessao.tempoFim = null;
            expect(sessao.getDuracao()).toBeNull();
        });
    });

    describe('Cálculo de Progresso', () => {
        test('should calculate progress correctly when meeting time goal', () => {
            // Sessão de 60 minutos (metaTempo)
            const inicio = new Date('2024-12-20T10:00:00');
            const fim = new Date('2024-12-20T11:00:00'); // Exatamente 60 min
            
            sessao.tempoInicio = inicio;
            sessao.tempoFim = fim;
            sessao.metaTempo = 60;

            const progresso = sessao.calcularProgresso();
            expect(progresso).toBe(100);
        });

        test('should limit progress to maximum 100%', () => {
            // Sessão de 120 minutos com meta de 60
            const inicio = new Date('2024-12-20T10:00:00');
            const fim = new Date('2024-12-20T12:00:00'); // 120 min
            
            sessao.tempoInicio = inicio;
            sessao.tempoFim = fim;
            sessao.metaTempo = 60;

            const progresso = sessao.calcularProgresso();
            expect(progresso).toBe(100); // Máximo 100%
        });
    });

    describe('Cálculo de XP com Meta', () => {
        test('should give bonus XP when completing 100% of goal', () => {
            const xpBase = 100;
            
            // Mock progresso de 100%
            sessao.calcularProgresso = jest.fn().mockReturnValue(100);
            sessao.isAgendada = true;
            sessao.metaTempo = 60;

            const xpFinal = sessao.calcularXpComMeta(xpBase);
            expect(xpFinal).toBe(150); // 1.5x bonus
        });

        test('should give normal XP when completing 80-99% of goal', () => {
            const xpBase = 100;
            
            // Mock progresso de 85%
            sessao.calcularProgresso = jest.fn().mockReturnValue(85);
            sessao.isAgendada = true;
            sessao.metaTempo = 60;

            const xpFinal = sessao.calcularXpComMeta(xpBase);
            expect(xpFinal).toBe(100); // XP normal
        });

        test('should give proportional XP when completing less than 80%', () => {
            const xpBase = 100;
            
            // Mock progresso de 50%
            sessao.calcularProgresso = jest.fn().mockReturnValue(50);
            sessao.isAgendada = true;
            sessao.metaTempo = 60;

            const xpFinal = sessao.calcularXpComMeta(xpBase);
            expect(xpFinal).toBe(50); // 50% do XP base
        });
    });
}); 