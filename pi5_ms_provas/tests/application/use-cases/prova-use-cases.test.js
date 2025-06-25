import { describe, test, expect, beforeEach, jest } from '@jest/globals';
import { CreateProvaUseCase } from '../../../src/application/use-cases/prova/CreateProvaUseCase.js';
import { GetProvaUseCase } from '../../../src/application/use-cases/prova/GetProvaUseCase.js';
import { UpdateProvaUseCase } from '../../../src/application/use-cases/prova/UpdateProvaUseCase.js';
import { DeleteProvaUseCase } from '../../../src/application/use-cases/prova/DeleteProvaUseCase.js';

describe('Prova Use Cases', () => {
    let provaRepository;
    let materiaRepository;
    let createUseCase;
    let getUseCase;
    let updateUseCase;
    let deleteUseCase;

    beforeEach(() => {
        provaRepository = createMockRepository();
        materiaRepository = createMockRepository();
        
        createUseCase = new CreateProvaUseCase(provaRepository, materiaRepository);
        getUseCase = new GetProvaUseCase(provaRepository);
        updateUseCase = new UpdateProvaUseCase(provaRepository, materiaRepository);
        deleteUseCase = new DeleteProvaUseCase(provaRepository);
    });

    describe('CreateProvaUseCase', () => {
        test('should create prova successfully with valid data', async () => {
            const mockMateria = createMockMateria({ userId: 'user-123' });
            const mockProva = createMockProva({ userId: 'user-123' });
            
            materiaRepository.findById.mockResolvedValue(mockMateria);
            provaRepository.create.mockResolvedValue(mockProva);

            const provaData = {
                titulo: 'Nova Prova',
                descricao: 'Descrição da prova',
                data: '2024-12-25',
                horario: '2024-12-25T10:00:00',
                local: 'Sala 101',
                materiaId: 'materia-456'
            };

            const result = await createUseCase.execute(provaData, 'user-123');

            expect(materiaRepository.findById).toHaveBeenCalledWith('materia-456');
            expect(provaRepository.create).toHaveBeenCalled();
            expect(result).toEqual(mockProva);
        });

        test('should throw error when userId is missing', async () => {
            const provaData = {
                titulo: 'Nova Prova',
                data: '2024-12-25',
                horario: '2024-12-25T10:00:00',
                local: 'Sala 101'
            };

            await expect(createUseCase.execute(provaData, null))
                .rejects.toThrow('UserId é obrigatório');
        });

        test('should throw error when materia is not found', async () => {
            materiaRepository.findById.mockResolvedValue(null);

            const provaData = {
                titulo: 'Nova Prova',
                data: '2024-12-25',
                horario: '2024-12-25T10:00:00',
                local: 'Sala 101',
                materiaId: 'inexistente'
            };

            await expect(createUseCase.execute(provaData, 'user-123'))
                .rejects.toThrow('Matéria não encontrada');
        });

        test('should throw error when materia does not belong to user', async () => {
            const mockMateria = createMockMateria({ userId: 'outro-user' });
            materiaRepository.findById.mockResolvedValue(mockMateria);

            const provaData = {
                titulo: 'Nova Prova',
                data: '2024-12-25',
                horario: '2024-12-25T10:00:00',
                local: 'Sala 101',
                materiaId: 'materia-456'
            };

            await expect(createUseCase.execute(provaData, 'user-123'))
                .rejects.toThrow('Matéria não encontrada');
        });
    });

    describe('GetProvaUseCase', () => {
        test('should get prova by id successfully', async () => {
            const mockProva = createMockProva({ userId: 'user-123' });
            provaRepository.findById.mockResolvedValue(mockProva);

            const result = await getUseCase.execute('prova-123', 'user-123');

            expect(provaRepository.findById).toHaveBeenCalledWith('prova-123');
            expect(result).toEqual(mockProva);
        });

        test('should get all provas for user', async () => {
            const mockProvas = [createMockProva(), createMockProva({ id: 'prova-456' })];
            provaRepository.findByUserId.mockResolvedValue(mockProvas);

            const result = await getUseCase.executeAll('user-123');

            expect(provaRepository.findByUserId).toHaveBeenCalledWith('user-123');
            expect(result).toEqual(mockProvas);
        });
    });

    describe('UpdateProvaUseCase', () => {
        test('should update prova successfully', async () => {
            const mockProva = createMockProva({ userId: 'user-123' });
            const updatedProva = { ...mockProva, titulo: 'Título Atualizado' };
            
            provaRepository.findById.mockResolvedValue(mockProva);
            provaRepository.update.mockResolvedValue(updatedProva);

            const updateData = { titulo: 'Título Atualizado' };
            const result = await updateUseCase.execute('prova-123', updateData, 'user-123');

            expect(provaRepository.findById).toHaveBeenCalledWith('prova-123');
            expect(provaRepository.update).toHaveBeenCalled();
            expect(result).toEqual(updatedProva);
        });

        test('should throw error when prova not found for update', async () => {
            provaRepository.findById.mockResolvedValue(null);

            await expect(updateUseCase.execute('inexistente', {}, 'user-123'))
                .rejects.toThrow('Prova não encontrada');
        });

        test('should throw error when user does not own prova', async () => {
            const mockProva = createMockProva({ userId: 'outro-user' });
            provaRepository.findById.mockResolvedValue(mockProva);

            await expect(updateUseCase.execute('prova-123', {}, 'user-123'))
                .rejects.toThrow('Prova não encontrada');
        });
    });

    describe('DeleteProvaUseCase', () => {
        test('should delete prova successfully', async () => {
            const mockProva = createMockProva({ userId: 'user-123' });
            provaRepository.findById.mockResolvedValue(mockProva);
            provaRepository.delete.mockResolvedValue(true);

            await deleteUseCase.execute('prova-123', 'user-123');

            expect(provaRepository.findById).toHaveBeenCalledWith('prova-123');
            expect(provaRepository.delete).toHaveBeenCalledWith('prova-123');
        });

        test('should throw error when prova not found for deletion', async () => {
            provaRepository.findById.mockResolvedValue(null);

            await expect(deleteUseCase.execute('inexistente', 'user-123'))
                .rejects.toThrow('Prova não encontrada');
        });

        test('should throw error when user does not own prova for deletion', async () => {
            const mockProva = createMockProva({ userId: 'outro-user' });
            provaRepository.findById.mockResolvedValue(mockProva);

            await expect(deleteUseCase.execute('prova-123', 'user-123'))
                .rejects.toThrow('Prova não encontrada');
        });
    });
}); 