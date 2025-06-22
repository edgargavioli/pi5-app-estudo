import { jest } from '@jest/globals';

// Mock simples do prismaClient
const mockPrisma = {
  materia: {
    create: jest.fn(),
    findUnique: jest.fn(),
    findMany: jest.fn(),
    update: jest.fn(),
    delete: jest.fn()
  }
};

// Mock do módulo prismaClient
jest.unstable_mockModule('../../../../../src/infrastructure/persistence/repositories/prismaClient.js', () => ({
  default: mockPrisma
}));

// Importar o repositório após o mock
import { MateriaRepository } from '../../../../../src/infrastructure/persistence/repositories/MateriaRepository.js';

describe('MateriaRepository', () => {
  let materiaRepository;

  beforeEach(() => {
    materiaRepository = new MateriaRepository();
    jest.clearAllMocks();
  });

  describe('create', () => {
    it('deve criar uma matéria com sucesso', async () => {
      const materiaData = {
        nome: 'Matemática',
        descricao: 'Matemática básica e avançada',
        userId: 'user-123'
      };
      const expectedMateria = {
        id: 'materia-123',
        ...materiaData,
        createdAt: new Date(),
        updatedAt: new Date()
      };

      mockPrisma.materia.create.mockResolvedValue(expectedMateria);

      const result = await materiaRepository.create(materiaData);

      expect(mockPrisma.materia.create).toHaveBeenCalledWith({
        data: materiaData
      });
      expect(result).toEqual(expectedMateria);
    });

    it('deve propagar erro do Prisma', async () => {
      const materiaData = {
        nome: 'Matemática',
        descricao: 'Matemática básica e avançada',
        userId: 'user-123'
      };
      const prismaError = new Error('Erro no banco de dados');

      mockPrisma.materia.create.mockRejectedValue(prismaError);

      await expect(materiaRepository.create(materiaData))
        .rejects
        .toThrow('Erro no banco de dados');

      expect(mockPrisma.materia.create).toHaveBeenCalledWith({
        data: materiaData
      });
    });
  });

  describe('findById', () => {
    it('deve encontrar matéria por ID', async () => {
      const materiaId = 'materia-123';
      const expectedMateria = {
        id: materiaId,
        nome: 'Matemática',
        descricao: 'Matemática básica e avançada',
        userId: 'user-123',
        createdAt: new Date(),
        updatedAt: new Date()
      };

      mockPrisma.materia.findUnique.mockResolvedValue(expectedMateria);

      const result = await materiaRepository.findById(materiaId);

      expect(mockPrisma.materia.findUnique).toHaveBeenCalledWith({
        where: { id: materiaId }
      });
      expect(result).toEqual(expectedMateria);
    });

    it('deve retornar null se matéria não for encontrada', async () => {
      const materiaId = 'materia-inexistente';

      mockPrisma.materia.findUnique.mockResolvedValue(null);

      const result = await materiaRepository.findById(materiaId);

      expect(mockPrisma.materia.findUnique).toHaveBeenCalledWith({
        where: { id: materiaId }
      });
      expect(result).toBeNull();
    });
  });

  describe('findAll', () => {
    it('deve retornar todas as matérias', async () => {
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

      mockPrisma.materia.findMany.mockResolvedValue(expectedMaterias);

      const result = await materiaRepository.findAll();

      expect(mockPrisma.materia.findMany).toHaveBeenCalledWith();
      expect(result).toEqual(expectedMaterias);
    });

    it('deve retornar array vazio se não houver matérias', async () => {
      mockPrisma.materia.findMany.mockResolvedValue([]);

      const result = await materiaRepository.findAll();

      expect(mockPrisma.materia.findMany).toHaveBeenCalledWith();
      expect(result).toEqual([]);
    });
  });

  describe('findByUserId', () => {
    it('deve encontrar matérias por userId', async () => {
      const userId = 'user-123';
      const expectedMaterias = [
        {
          id: 'materia-1',
          nome: 'Matemática',
          descricao: 'Matemática básica e avançada',
          userId,
          createdAt: new Date(),
          updatedAt: new Date()
        }
      ];

      mockPrisma.materia.findMany.mockResolvedValue(expectedMaterias);

      const result = await materiaRepository.findByUserId(userId);

      expect(mockPrisma.materia.findMany).toHaveBeenCalledWith({
        where: { userId }
      });
      expect(result).toEqual(expectedMaterias);
    });

    it('deve retornar array vazio se não houver matérias para o usuário', async () => {
      const userId = 'user-inexistente';

      mockPrisma.materia.findMany.mockResolvedValue([]);

      const result = await materiaRepository.findByUserId(userId);

      expect(mockPrisma.materia.findMany).toHaveBeenCalledWith({
        where: { userId }
      });
      expect(result).toEqual([]);
    });
  });

  describe('update', () => {
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

      mockPrisma.materia.update.mockResolvedValue(expectedMateria);

      const result = await materiaRepository.update(materiaId, updateData);

      expect(mockPrisma.materia.update).toHaveBeenCalledWith({
        where: { id: materiaId },
        data: updateData
      });
      expect(result).toEqual(expectedMateria);
    });

    it('deve propagar erro do Prisma', async () => {
      const materiaId = 'materia-123';
      const updateData = {
        nome: 'Matemática Avançada'
      };
      const prismaError = new Error('Erro no banco de dados');

      mockPrisma.materia.update.mockRejectedValue(prismaError);

      await expect(materiaRepository.update(materiaId, updateData))
        .rejects
        .toThrow('Erro no banco de dados');

      expect(mockPrisma.materia.update).toHaveBeenCalledWith({
        where: { id: materiaId },
        data: updateData
      });
    });
  });

  describe('delete', () => {
    it('deve deletar uma matéria com sucesso', async () => {
      const materiaId = 'materia-123';
      const expectedMateria = {
        id: materiaId,
        nome: 'Matemática',
        descricao: 'Matemática básica e avançada',
        userId: 'user-123',
        createdAt: new Date(),
        updatedAt: new Date()
      };

      mockPrisma.materia.delete.mockResolvedValue(expectedMateria);

      const result = await materiaRepository.delete(materiaId);

      expect(mockPrisma.materia.delete).toHaveBeenCalledWith({
        where: { id: materiaId }
      });
      expect(result).toEqual(expectedMateria);
    });

    it('deve propagar erro do Prisma', async () => {
      const materiaId = 'materia-123';
      const prismaError = new Error('Erro no banco de dados');

      mockPrisma.materia.delete.mockRejectedValue(prismaError);

      await expect(materiaRepository.delete(materiaId))
        .rejects
        .toThrow('Erro no banco de dados');

      expect(mockPrisma.materia.delete).toHaveBeenCalledWith({
        where: { id: materiaId }
      });
    });
  });
}); 