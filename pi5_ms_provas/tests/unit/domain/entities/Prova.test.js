import { jest } from '@jest/globals';
import { Prova } from '../../../../src/domain/entities/Prova.js';

describe('Prova Entity', () => {
  const validProvaData = {
    titulo: 'Prova de Matemática',
    descricao: 'Prova sobre álgebra linear',
    data: '2024-12-15',
    horario: '2024-12-15T14:00:00.000Z',
    local: 'Universidade XYZ',
    materiaId: 'materia-id-123',
    filtros: { dificuldade: 'MEDIA', temas: ['Álgebra'] },
    totalQuestoes: 20
  };

  describe('create', () => {
    it('deve criar uma prova válida', () => {
      const prova = Prova.create(
        validProvaData.titulo,
        validProvaData.descricao,
        validProvaData.data,
        validProvaData.horario,
        validProvaData.local,
        validProvaData.materiaId,
        validProvaData.filtros,
        validProvaData.totalQuestoes
      );
      
      expect(prova).toBeInstanceOf(Prova);
      expect(prova.titulo).toBe(validProvaData.titulo);
      expect(prova.descricao).toBe(validProvaData.descricao);
      expect(prova.data).toEqual(new Date(validProvaData.data));
      expect(prova.horario).toEqual(new Date(validProvaData.horario));
      expect(prova.local).toBe(validProvaData.local);
      expect(prova.materiaId).toBe(validProvaData.materiaId);
      expect(prova.filtros).toEqual(validProvaData.filtros);
      expect(prova.totalQuestoes).toBe(validProvaData.totalQuestoes);
      expect(prova.id).toBeDefined();
      expect(prova.createdAt).toBeInstanceOf(Date);
      expect(prova.updatedAt).toBeInstanceOf(Date);
    });

    it('deve criar prova sem filtros e totalQuestoes', () => {
      const prova = Prova.create(
        validProvaData.titulo,
        validProvaData.descricao,
        validProvaData.data,
        validProvaData.horario,
        validProvaData.local,
        validProvaData.materiaId
      );
      
      expect(prova.filtros).toBeNull();
      expect(prova.totalQuestoes).toBeNull();
    });

    it('deve lançar erro se título for vazio', () => {
      expect(() => {
        Prova.create(
          '',
          validProvaData.descricao,
          validProvaData.data,
          validProvaData.horario,
          validProvaData.local,
          validProvaData.materiaId
        );
      }).toThrow('Título da prova é obrigatório');
    });

    it('deve lançar erro se data for vazia', () => {
      expect(() => {
        Prova.create(
          validProvaData.titulo,
          validProvaData.descricao,
          null,
          validProvaData.horario,
          validProvaData.local,
          validProvaData.materiaId
        );
      }).toThrow('Data da prova é obrigatória');
    });

    it('deve lançar erro se horário for vazio', () => {
      expect(() => {
        Prova.create(
          validProvaData.titulo,
          validProvaData.descricao,
          validProvaData.data,
          null,
          validProvaData.local,
          validProvaData.materiaId
        );
      }).toThrow('Horário da prova é obrigatório');
    });

    it('deve lançar erro se local for vazio', () => {
      expect(() => {
        Prova.create(
          validProvaData.titulo,
          validProvaData.descricao,
          validProvaData.data,
          validProvaData.horario,
          '',
          validProvaData.materiaId
        );
      }).toThrow('Local da prova é obrigatório');
    });

    it('deve lançar erro se matéria for vazia', () => {
      expect(() => {
        Prova.create(
          validProvaData.titulo,
          validProvaData.descricao,
          validProvaData.data,
          validProvaData.horario,
          validProvaData.local,
          null
        );
      }).toThrow('Matéria é obrigatória');
    });

    it('deve lançar erro se totalQuestoes for menor ou igual a zero', () => {
      expect(() => {
        Prova.create(
          validProvaData.titulo,
          validProvaData.descricao,
          validProvaData.data,
          validProvaData.horario,
          validProvaData.local,
          validProvaData.materiaId,
          validProvaData.filtros,
          0
        );
      }).toThrow('Número total de questões deve ser maior que zero');
    });

    it('deve remover espaços em branco do local', () => {
      const prova = Prova.create(
        validProvaData.titulo,
        validProvaData.descricao,
        validProvaData.data,
        validProvaData.horario,
        '  Universidade XYZ  ',
        validProvaData.materiaId
      );
      
      expect(prova.local).toBe('Universidade XYZ');
    });
  });

  describe('update', () => {
    let prova;

    beforeEach(() => {
      prova = Prova.create(
        validProvaData.titulo,
        validProvaData.descricao,
        validProvaData.data,
        validProvaData.horario,
        validProvaData.local,
        validProvaData.materiaId,
        validProvaData.filtros,
        validProvaData.totalQuestoes
      );
    });

    it('deve atualizar todos os campos', async () => {
      const oldUpdatedAt = prova.updatedAt;
      
      await new Promise(resolve => setTimeout(resolve, 10));
      
      prova.update(
        'Novo Título',
        'Nova Descrição',
        '2024-12-20',
        '2024-12-20T15:00:00.000Z',
        'Novo Local',
        'nova-materia-id',
        { dificuldade: 'DIFICIL' },
        30,
        25
      );
      
      expect(prova.titulo).toBe('Novo Título');
      expect(prova.descricao).toBe('Nova Descrição');
      expect(prova.data).toEqual(new Date('2024-12-20'));
      expect(prova.horario).toEqual(new Date('2024-12-20T15:00:00.000Z'));
      expect(prova.local).toBe('Novo Local');
      expect(prova.materiaId).toBe('nova-materia-id');
      expect(prova.filtros).toEqual({ dificuldade: 'DIFICIL' });
      expect(prova.totalQuestoes).toBe(30);
      expect(prova.acertos).toBe(25);
      expect(prova.updatedAt.getTime()).toBeGreaterThan(oldUpdatedAt.getTime());
    });

    it('deve lançar erro se local atualizado for vazio', () => {
      expect(() => {
        prova.update(null, null, null, null, '', null);
      }).toThrow('Local da prova não pode ser vazio');
    });

    it('deve permitir atualizar sem local (local null)', () => {
      const oldLocal = prova.local;
      prova.update(null, null, null, null, null, null);
      expect(prova.local).toBe(oldLocal);
    });

    it('deve lançar erro se totalQuestoes for menor ou igual a zero', () => {
      expect(() => {
        prova.update(null, null, null, null, null, null, null, 0);
      }).toThrow('Número total de questões deve ser maior que zero');
    });

    it('deve lançar erro se acertos for negativo', () => {
      expect(() => {
        prova.update(null, null, null, null, null, null, null, 20, -1);
      }).toThrow('Número de acertos não pode ser negativo');
    });

    it('deve lançar erro se acertos for maior que totalQuestoes', () => {
      expect(() => {
        prova.update(null, null, null, null, null, null, null, 20, 25);
      }).toThrow('Número de acertos não pode ser maior que o total de questões');
    });

    it('deve permitir acertos igual a null', () => {
      prova.update(null, null, null, null, null, null, null, null, null);
      expect(prova.acertos).toBeNull();
    });
  });

  describe('percentualAcerto', () => {
    it('deve calcular percentual de acerto corretamente', () => {
      const prova = Prova.create(
        validProvaData.titulo,
        validProvaData.descricao,
        validProvaData.data,
        validProvaData.horario,
        validProvaData.local,
        validProvaData.materiaId,
        validProvaData.filtros,
        20
      );
      
      prova.update(null, null, null, null, null, null, null, 20, 15);
      expect(prova.percentualAcerto).toBe(75); // 15/20 * 100 = 75%
    });

    it('deve retornar null se não houver totalQuestoes', () => {
      const prova = Prova.create(
        validProvaData.titulo,
        validProvaData.descricao,
        validProvaData.data,
        validProvaData.horario,
        validProvaData.local,
        validProvaData.materiaId
      );
      
      expect(prova.percentualAcerto).toBeNull();
    });

    it('deve retornar null se não houver acertos', () => {
      const prova = Prova.create(
        validProvaData.titulo,
        validProvaData.descricao,
        validProvaData.data,
        validProvaData.horario,
        validProvaData.local,
        validProvaData.materiaId,
        validProvaData.filtros,
        20
      );
      
      expect(prova.percentualAcerto).toBeNull();
    });
  });

  describe('foiRealizada', () => {
    it('deve retornar true se prova foi realizada', () => {
      const prova = Prova.create(
        validProvaData.titulo,
        validProvaData.descricao,
        validProvaData.data,
        validProvaData.horario,
        validProvaData.local,
        validProvaData.materiaId,
        validProvaData.filtros,
        20
      );
      
      prova.update(null, null, null, null, null, null, null, null, 15);
      expect(prova.foiRealizada).toBe(true);
    });

    it('deve retornar false se prova não foi realizada', () => {
      const prova = Prova.create(
        validProvaData.titulo,
        validProvaData.descricao,
        validProvaData.data,
        validProvaData.horario,
        validProvaData.local,
        validProvaData.materiaId,
        validProvaData.filtros,
        20
      );
      
      expect(prova.foiRealizada).toBe(false);
    });
  });
}); 