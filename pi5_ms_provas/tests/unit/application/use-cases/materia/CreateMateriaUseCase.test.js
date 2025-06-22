import { jest } from '@jest/globals';
import { CreateMateriaUseCase } from '../../../../../src/application/use-cases/materia/CreateMateriaUseCase.js';

describe('CreateMateriaUseCase', () => {
  let mockMateriaRepository;
  let createMateriaUseCase;

  beforeEach(() => {
    mockMateriaRepository = {
      create: jest.fn()
    };
    createMateriaUseCase = new CreateMateriaUseCase(mockMateriaRepository);
  });

  describe('execute', () => {
    it('deve criar uma matéria com sucesso', async () => {
      const materiaData = {
        nome: 'Matemática',
        descricao: 'Matemática básica e avançada'
      };
      const userId = 'user-123';
      const expectedMateria = {
        id: 'materia-123',
        ...materiaData,
        userId,
        createdAt: new Date(),
        updatedAt: new Date()
      };

      mockMateriaRepository.create.mockResolvedValue(expectedMateria);

      const result = await createMateriaUseCase.execute(materiaData, userId);

      expect(mockMateriaRepository.create).toHaveBeenCalledWith({
        nome: materiaData.nome,
        descricao: materiaData.descricao,
        userId
      });
      expect(result).toEqual(expectedMateria);
    });

    it('deve criar uma matéria sem descrição', async () => {
      const materiaData = {
        nome: 'Matemática'
      };
      const userId = 'user-123';
      const expectedMateria = {
        id: 'materia-123',
        ...materiaData,
        userId,
        createdAt: new Date(),
        updatedAt: new Date()
      };

      mockMateriaRepository.create.mockResolvedValue(expectedMateria);

      const result = await createMateriaUseCase.execute(materiaData, userId);

      expect(mockMateriaRepository.create).toHaveBeenCalledWith({
        nome: materiaData.nome,
        descricao: undefined,
        userId
      });
      expect(result).toEqual(expectedMateria);
    });

    it('deve lançar erro se nome for vazio', async () => {
      const materiaData = {
        nome: '',
        descricao: 'Matemática básica e avançada'
      };
      const userId = 'user-123';

      await expect(createMateriaUseCase.execute(materiaData, userId))
        .rejects
        .toThrow('Nome é obrigatório');

      expect(mockMateriaRepository.create).not.toHaveBeenCalled();
    });

    it('deve lançar erro se nome for null', async () => {
      const materiaData = {
        nome: null,
        descricao: 'Matemática básica e avançada'
      };
      const userId = 'user-123';

      await expect(createMateriaUseCase.execute(materiaData, userId))
        .rejects
        .toThrow('Nome é obrigatório');

      expect(mockMateriaRepository.create).not.toHaveBeenCalled();
    });

    it('deve lançar erro se nome for undefined', async () => {
      const materiaData = {
        descricao: 'Matemática básica e avançada'
      };
      const userId = 'user-123';

      await expect(createMateriaUseCase.execute(materiaData, userId))
        .rejects
        .toThrow('Nome é obrigatório');

      expect(mockMateriaRepository.create).not.toHaveBeenCalled();
    });

    it('deve lançar erro se userId for vazio', async () => {
      const materiaData = {
        nome: 'Matemática',
        descricao: 'Matemática básica e avançada'
      };
      const userId = '';

      await expect(createMateriaUseCase.execute(materiaData, userId))
        .rejects
        .toThrow('UserId é obrigatório');

      expect(mockMateriaRepository.create).not.toHaveBeenCalled();
    });

    it('deve lançar erro se userId for null', async () => {
      const materiaData = {
        nome: 'Matemática',
        descricao: 'Matemática básica e avançada'
      };
      const userId = null;

      await expect(createMateriaUseCase.execute(materiaData, userId))
        .rejects
        .toThrow('UserId é obrigatório');

      expect(mockMateriaRepository.create).not.toHaveBeenCalled();
    });

    it('deve lançar erro se userId for undefined', async () => {
      const materiaData = {
        nome: 'Matemática',
        descricao: 'Matemática básica e avançada'
      };

      await expect(createMateriaUseCase.execute(materiaData, undefined))
        .rejects
        .toThrow('UserId é obrigatório');

      expect(mockMateriaRepository.create).not.toHaveBeenCalled();
    });

    it('deve propagar erro do repositório', async () => {
      const materiaData = {
        nome: 'Matemática',
        descricao: 'Matemática básica e avançada'
      };
      const userId = 'user-123';
      const repositoryError = new Error('Erro no banco de dados');

      mockMateriaRepository.create.mockRejectedValue(repositoryError);

      await expect(createMateriaUseCase.execute(materiaData, userId))
        .rejects
        .toThrow('Erro no banco de dados');

      expect(mockMateriaRepository.create).toHaveBeenCalledWith({
        nome: materiaData.nome,
        descricao: materiaData.descricao,
        userId
      });
    });
  });
}); 