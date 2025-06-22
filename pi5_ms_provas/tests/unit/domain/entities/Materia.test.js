import { jest } from '@jest/globals';
import { Materia } from '../../../../src/domain/entities/Materia.js';

describe('Materia Entity', () => {
  describe('create', () => {
    it('deve criar uma matéria válida', () => {
      const materia = Materia.create('Matemática', 'Exatas');
      
      expect(materia).toBeInstanceOf(Materia);
      expect(materia.nome).toBe('Matemática');
      expect(materia.disciplina).toBe('Exatas');
      expect(materia.id).toBeDefined();
      expect(materia.createdAt).toBeInstanceOf(Date);
      expect(materia.updatedAt).toBeInstanceOf(Date);
    });

    it('deve lançar erro se nome for vazio', () => {
      expect(() => {
        Materia.create('', 'Exatas');
      }).toThrow('Nome da matéria é obrigatório');
    });

    it('deve lançar erro se nome for null', () => {
      expect(() => {
        Materia.create(null, 'Exatas');
      }).toThrow('Nome da matéria é obrigatório');
    });

    it('deve lançar erro se disciplina for vazia', () => {
      expect(() => {
        Materia.create('Matemática', '');
      }).toThrow('Disciplina é obrigatória');
    });

    it('deve lançar erro se disciplina for null', () => {
      expect(() => {
        Materia.create('Matemática', null);
      }).toThrow('Disciplina é obrigatória');
    });

    it('deve remover espaços em branco do nome e disciplina', () => {
      const materia = Materia.create('  Matemática  ', '  Exatas  ');
      
      expect(materia.nome).toBe('Matemática');
      expect(materia.disciplina).toBe('Exatas');
    });
  });

  describe('update', () => {
    let materia;

    beforeEach(() => {
      materia = Materia.create('Matemática', 'Exatas');
    });

    it('deve atualizar nome e disciplina', async () => {
      const oldUpdatedAt = materia.updatedAt;
      
      // Aguardar um pouco para garantir diferença de timestamp
      await new Promise(resolve => setTimeout(resolve, 10));
      
      materia.update('Matemática Avançada', 'Ciências Exatas');
      
      expect(materia.nome).toBe('Matemática Avançada');
      expect(materia.disciplina).toBe('Ciências Exatas');
      expect(materia.updatedAt.getTime()).toBeGreaterThan(oldUpdatedAt.getTime());
    });

    it('deve atualizar apenas o nome', async () => {
      const oldDisciplina = materia.disciplina;
      const oldUpdatedAt = materia.updatedAt;
      
      await new Promise(resolve => setTimeout(resolve, 10));
      
      materia.update('Matemática Avançada', null);
      
      expect(materia.nome).toBe('Matemática Avançada');
      expect(materia.disciplina).toBe(oldDisciplina);
      expect(materia.updatedAt.getTime()).toBeGreaterThan(oldUpdatedAt.getTime());
    });

    it('deve atualizar apenas a disciplina', async () => {
      const oldNome = materia.nome;
      const oldUpdatedAt = materia.updatedAt;
      
      await new Promise(resolve => setTimeout(resolve, 10));
      
      materia.update(null, 'Ciências Exatas');
      
      expect(materia.nome).toBe(oldNome);
      expect(materia.disciplina).toBe('Ciências Exatas');
      expect(materia.updatedAt.getTime()).toBeGreaterThan(oldUpdatedAt.getTime());
    });

    it('deve lançar erro se nome atualizado for vazio', () => {
      expect(() => {
        materia.update('', 'Exatas');
      }).toThrow('Nome da matéria não pode ser vazio');
    });

    it('deve lançar erro se disciplina atualizada for vazia', () => {
      expect(() => {
        materia.update('Matemática', '');
      }).toThrow('Disciplina não pode ser vazia');
    });

    it('deve permitir atualizar apenas nome (disciplina null)', () => {
      const oldDisciplina = materia.disciplina;
      materia.update('Matemática Avançada', null);
      expect(materia.nome).toBe('Matemática Avançada');
      expect(materia.disciplina).toBe(oldDisciplina);
    });

    it('deve permitir atualizar apenas disciplina (nome null)', () => {
      const oldNome = materia.nome;
      materia.update(null, 'Ciências Exatas');
      expect(materia.nome).toBe(oldNome);
      expect(materia.disciplina).toBe('Ciências Exatas');
    });

    it('deve remover espaços em branco ao atualizar', () => {
      materia.update('  Matemática Avançada  ', '  Ciências Exatas  ');
      
      expect(materia.nome).toBe('Matemática Avançada');
      expect(materia.disciplina).toBe('Ciências Exatas');
    });
  });

  describe('constructor', () => {
    it('deve criar instância com todos os parâmetros', () => {
      const id = 'test-id';
      const nome = 'Matemática';
      const disciplina = 'Exatas';
      const createdAt = new Date('2024-01-01');
      const updatedAt = new Date('2024-01-02');
      
      const materia = new Materia(id, nome, disciplina);
      materia.createdAt = createdAt;
      materia.updatedAt = updatedAt;
      
      expect(materia.id).toBe(id);
      expect(materia.nome).toBe(nome);
      expect(materia.disciplina).toBe(disciplina);
      expect(materia.createdAt).toBe(createdAt);
      expect(materia.updatedAt).toBe(updatedAt);
    });
  });
}); 