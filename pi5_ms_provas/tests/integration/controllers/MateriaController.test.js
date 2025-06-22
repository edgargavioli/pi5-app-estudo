import { jest } from '@jest/globals';

// Mock dos use cases
jest.unstable_mockModule('../../../../src/application/use-cases/materia/CreateMateriaUseCase.js', () => ({
  CreateMateriaUseCase: jest.fn()
}));

jest.unstable_mockModule('../../../../src/application/use-cases/materia/GetMateriaUseCase.js', () => ({
  GetMateriaUseCase: jest.fn()
}));

jest.unstable_mockModule('../../../../src/application/use-cases/materia/UpdateMateriaUseCase.js', () => ({
  UpdateMateriaUseCase: jest.fn()
}));

jest.unstable_mockModule('../../../../src/application/use-cases/materia/DeleteMateriaUseCase.js', () => ({
  DeleteMateriaUseCase: jest.fn()
}));

// Importar os use cases mockados
const { CreateMateriaUseCase } = await import('../../../../src/application/use-cases/materia/CreateMateriaUseCase.js');
const { GetMateriaUseCase } = await import('../../../../src/application/use-cases/materia/GetMateriaUseCase.js');
const { UpdateMateriaUseCase } = await import('../../../../src/application/use-cases/materia/UpdateMateriaUseCase.js');
const { DeleteMateriaUseCase } = await import('../../../../src/application/use-cases/materia/DeleteMateriaUseCase.js');

describe('MateriaController Integration Tests', () => {
  let mockCreateUseCase;
  let mockGetUseCase;
  let mockUpdateUseCase;
  let mockDeleteUseCase;

  beforeEach(() => {
    // Limpar todos os mocks
    jest.clearAllMocks();

    // Configurar mocks dos use cases
    mockCreateUseCase = {
      execute: jest.fn()
    };
    mockGetUseCase = {
      execute: jest.fn(),
      executeAll: jest.fn()
    };
    mockUpdateUseCase = {
      execute: jest.fn()
    };
    mockDeleteUseCase = {
      execute: jest.fn()
    };

    // Mock das classes dos use cases
    CreateMateriaUseCase.mockImplementation(() => mockCreateUseCase);
    GetMateriaUseCase.mockImplementation(() => mockGetUseCase);
    UpdateMateriaUseCase.mockImplementation(() => mockUpdateUseCase);
    DeleteMateriaUseCase.mockImplementation(() => mockDeleteUseCase);
  });

  describe('CreateMateriaUseCase', () => {
    it('deve criar uma matéria com sucesso', async () => {
      const materiaData = {
        nome: 'Matemática',
        descricao: 'Matemática básica e avançada'
      };
      const expectedMateria = {
        id: 'materia-123',
        ...materiaData,
        userId: 'user-123',
        createdAt: new Date(),
        updatedAt: new Date()
      };

      mockCreateUseCase.execute.mockResolvedValue(expectedMateria);

      const result = await mockCreateUseCase.execute(materiaData, 'user-123');

      expect(mockCreateUseCase.execute).toHaveBeenCalledWith(materiaData, 'user-123');
      expect(result).toEqual(expectedMateria);
    });

    it('deve retornar erro se dados forem inválidos', async () => {
      const invalidData = {
        nome: '',
        descricao: 'Matemática básica e avançada'
      };

      mockCreateUseCase.execute.mockRejectedValue(new Error('Nome é obrigatório'));

      await expect(mockCreateUseCase.execute(invalidData, 'user-123'))
        .rejects
        .toThrow('Nome é obrigatório');
    });
  });

  describe('GetMateriaUseCase', () => {
    it('deve retornar todas as matérias do usuário', async () => {
      const expectedMaterias = [
        {
          id: 'materia-1',
          nome: 'Matemática',
          descricao: 'Matemática básica e avançada',
          userId: 'user-123',
          createdAt: new Date(),
          updatedAt: new Date()
        },
        {
          id: 'materia-2',
          nome: 'Português',
          descricao: 'Língua Portuguesa',
          userId: 'user-123',
          createdAt: new Date(),
          updatedAt: new Date()
        }
      ];

      mockGetUseCase.executeAll.mockResolvedValue(expectedMaterias);

      const result = await mockGetUseCase.executeAll('user-123');

      expect(mockGetUseCase.executeAll).toHaveBeenCalledWith('user-123');
      expect(result).toEqual(expectedMaterias);
    });

    it('deve retornar uma matéria específica', async () => {
      const materiaId = 'materia-123';
      const expectedMateria = {
        id: materiaId,
        nome: 'Matemática',
        descricao: 'Matemática básica e avançada',
        userId: 'user-123',
        createdAt: new Date(),
        updatedAt: new Date()
      };

      mockGetUseCase.execute.mockResolvedValue(expectedMateria);

      const result = await mockGetUseCase.execute(materiaId, 'user-123');

      expect(mockGetUseCase.execute).toHaveBeenCalledWith(materiaId, 'user-123');
      expect(result).toEqual(expectedMateria);
    });
  });

  describe('UpdateMateriaUseCase', () => {
    it('deve atualizar uma matéria com sucesso', async () => {
      const materiaId = 'materia-123';
      const updateData = {
        nome: 'Matemática Avançada',
        descricao: 'Matemática avançada e complexa'
      };
      const expectedMateria = {
        id: materiaId,
        ...updateData,
        userId: 'user-123',
        createdAt: new Date(),
        updatedAt: new Date()
      };

      mockUpdateUseCase.execute.mockResolvedValue(expectedMateria);

      const result = await mockUpdateUseCase.execute(materiaId, updateData, 'user-123');

      expect(mockUpdateUseCase.execute).toHaveBeenCalledWith(materiaId, updateData, 'user-123');
      expect(result).toEqual(expectedMateria);
    });
  });

  describe('DeleteMateriaUseCase', () => {
    it('deve deletar uma matéria com sucesso', async () => {
      const materiaId = 'materia-123';

      mockDeleteUseCase.execute.mockResolvedValue(true);

      const result = await mockDeleteUseCase.execute(materiaId, 'user-123');

      expect(mockDeleteUseCase.execute).toHaveBeenCalledWith(materiaId, 'user-123');
      expect(result).toBe(true);
    });
  });
}); 