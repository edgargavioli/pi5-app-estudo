import { jest } from '@jest/globals';
import { SessaoEstudo } from '../../../../src/domain/entities/SessaoEstudo.js';

describe('SessaoEstudo Entity', () => {
  const validSessaoData = {
    materiaId: 'materia-id-123',
    provaId: 'prova-id-456',
    conteudo: 'Revisão de Álgebra Linear',
    topicos: ['Matrizes', 'Determinantes', 'Sistemas Lineares'],
    tempoInicio: new Date('2024-01-01T10:00:00.000Z')
  };

  describe('create', () => {
    it('deve criar uma sessão válida', () => {
      const sessao = SessaoEstudo.create(
        validSessaoData.materiaId,
        validSessaoData.provaId,
        validSessaoData.conteudo,
        validSessaoData.topicos,
        validSessaoData.tempoInicio
      );
      
      expect(sessao).toBeInstanceOf(SessaoEstudo);
      expect(sessao.materiaId).toBe(validSessaoData.materiaId);
      expect(sessao.provaId).toBe(validSessaoData.provaId);
      expect(sessao.conteudo).toBe(validSessaoData.conteudo);
      expect(sessao.topicos).toEqual(validSessaoData.topicos);
      expect(sessao.tempoInicio).toEqual(validSessaoData.tempoInicio);
      expect(sessao.tempoFim).toBeNull();
      expect(sessao.id).toBeDefined();
      expect(sessao.createdAt).toBeInstanceOf(Date);
      expect(sessao.updatedAt).toBeInstanceOf(Date);
    });

    it('deve criar sessão sem provaId', () => {
      const sessao = SessaoEstudo.create(
        validSessaoData.materiaId,
        null,
        validSessaoData.conteudo,
        validSessaoData.topicos,
        validSessaoData.tempoInicio
      );
      
      expect(sessao.provaId).toBeNull();
    });

    it('deve criar sessão sem tempoInicio', () => {
      const sessao = SessaoEstudo.create(
        validSessaoData.materiaId,
        validSessaoData.provaId,
        validSessaoData.conteudo,
        validSessaoData.topicos
      );
      
      expect(sessao.tempoInicio).toBeNull();
    });

    it('deve lançar erro se materiaId for vazio', () => {
      expect(() => {
        SessaoEstudo.create(
          null,
          validSessaoData.provaId,
          validSessaoData.conteudo,
          validSessaoData.topicos
        );
      }).toThrow('Matéria é obrigatória');
    });

    it('deve lançar erro se conteudo for vazio', () => {
      expect(() => {
        SessaoEstudo.create(
          validSessaoData.materiaId,
          validSessaoData.provaId,
          '',
          validSessaoData.topicos
        );
      }).toThrow('Conteúdo é obrigatório');
    });

    it('deve lançar erro se conteudo for null', () => {
      expect(() => {
        SessaoEstudo.create(
          validSessaoData.materiaId,
          validSessaoData.provaId,
          null,
          validSessaoData.topicos
        );
      }).toThrow('Conteúdo é obrigatório');
    });

    it('deve lançar erro se topicos for vazio', () => {
      expect(() => {
        SessaoEstudo.create(
          validSessaoData.materiaId,
          validSessaoData.provaId,
          validSessaoData.conteudo,
          []
        );
      }).toThrow('Tópicos são obrigatórios e devem ser um array não vazio');
    });

    it('deve lançar erro se topicos for null', () => {
      expect(() => {
        SessaoEstudo.create(
          validSessaoData.materiaId,
          validSessaoData.provaId,
          validSessaoData.conteudo,
          null
        );
      }).toThrow('Tópicos são obrigatórios e devem ser um array não vazio');
    });

    it('deve lançar erro se topicos não for array', () => {
      expect(() => {
        SessaoEstudo.create(
          validSessaoData.materiaId,
          validSessaoData.provaId,
          validSessaoData.conteudo,
          'não é array'
        );
      }).toThrow('Tópicos são obrigatórios e devem ser um array não vazio');
    });

    it('deve remover espaços em branco do conteúdo', () => {
      const sessao = SessaoEstudo.create(
        validSessaoData.materiaId,
        validSessaoData.provaId,
        '  Revisão de Álgebra Linear  ',
        validSessaoData.topicos
      );
      
      expect(sessao.conteudo).toBe('Revisão de Álgebra Linear');
    });
  });

  describe('finalizar', () => {
    let sessao;

    beforeEach(() => {
      sessao = SessaoEstudo.create(
        validSessaoData.materiaId,
        validSessaoData.provaId,
        validSessaoData.conteudo,
        validSessaoData.topicos,
        validSessaoData.tempoInicio
      );
    });

    it('deve finalizar a sessão', async () => {
      const oldUpdatedAt = sessao.updatedAt;
      
      await new Promise(resolve => setTimeout(resolve, 10));
      
      sessao.finalizar();
      
      expect(sessao.tempoFim).toBeInstanceOf(Date);
      expect(sessao.updatedAt.getTime()).toBeGreaterThan(oldUpdatedAt.getTime());
    });

    it('deve lançar erro se sessão já foi finalizada', () => {
      sessao.finalizar();
      
      expect(() => {
        sessao.finalizar();
      }).toThrow('Sessão já foi finalizada');
    });
  });

  describe('update', () => {
    let sessao;

    beforeEach(() => {
      sessao = SessaoEstudo.create(
        validSessaoData.materiaId,
        validSessaoData.provaId,
        validSessaoData.conteudo,
        validSessaoData.topicos,
        validSessaoData.tempoInicio
      );
    });

    it('deve atualizar conteúdo e tópicos', async () => {
      const oldUpdatedAt = sessao.updatedAt;
      const novosTopicos = ['Derivadas', 'Integrais', 'Limites'];
      
      await new Promise(resolve => setTimeout(resolve, 10));
      
      sessao.update('Revisão de Cálculo', novosTopicos);
      
      expect(sessao.conteudo).toBe('Revisão de Cálculo');
      expect(sessao.topicos).toEqual(novosTopicos);
      expect(sessao.updatedAt.getTime()).toBeGreaterThan(oldUpdatedAt.getTime());
    });

    it('deve atualizar apenas o conteúdo', async () => {
      const oldTopicos = sessao.topicos;
      const oldUpdatedAt = sessao.updatedAt;
      
      await new Promise(resolve => setTimeout(resolve, 10));
      
      sessao.update('Novo Conteúdo', null);
      
      expect(sessao.conteudo).toBe('Novo Conteúdo');
      expect(sessao.topicos).toEqual(oldTopicos);
      expect(sessao.updatedAt.getTime()).toBeGreaterThan(oldUpdatedAt.getTime());
    });

    it('deve atualizar apenas os tópicos', async () => {
      const oldConteudo = sessao.conteudo;
      const oldUpdatedAt = sessao.updatedAt;
      const novosTopicos = ['Novo Tópico'];
      
      await new Promise(resolve => setTimeout(resolve, 10));
      
      sessao.update(null, novosTopicos);
      
      expect(sessao.conteudo).toBe(oldConteudo);
      expect(sessao.topicos).toEqual(novosTopicos);
      expect(sessao.updatedAt.getTime()).toBeGreaterThan(oldUpdatedAt.getTime());
    });

    it('deve lançar erro se conteúdo atualizado for vazio', () => {
      expect(() => {
        sessao.update('', validSessaoData.topicos);
      }).toThrow('Conteúdo não pode ser vazio');
    });

    it('deve permitir atualizar sem conteúdo (conteúdo null)', () => {
      const oldConteudo = sessao.conteudo;
      sessao.update(null, validSessaoData.topicos);
      expect(sessao.conteudo).toBe(oldConteudo);
    });

    it('deve lançar erro se tópicos atualizados for vazio', () => {
      expect(() => {
        sessao.update(validSessaoData.conteudo, []);
      }).toThrow('Tópicos devem ser um array não vazio');
    });

    it('deve lançar erro se tópicos atualizados não for array', () => {
      expect(() => {
        sessao.update(validSessaoData.conteudo, 'não é array');
      }).toThrow('Tópicos devem ser um array não vazio');
    });

    it('deve remover espaços em branco do conteúdo atualizado', () => {
      sessao.update('  Novo Conteúdo  ', validSessaoData.topicos);
      
      expect(sessao.conteudo).toBe('Novo Conteúdo');
    });
  });

  describe('getDuracao', () => {
    it('deve calcular duração corretamente', () => {
      const tempoInicio = new Date('2024-01-01T10:00:00.000Z');
      const tempoFim = new Date('2024-01-01T11:30:00.000Z');
      const duracaoEsperada = tempoFim.getTime() - tempoInicio.getTime();
      
      const sessao = SessaoEstudo.create(
        validSessaoData.materiaId,
        validSessaoData.provaId,
        validSessaoData.conteudo,
        validSessaoData.topicos,
        tempoInicio
      );
      
      sessao.tempoFim = tempoFim;
      expect(sessao.getDuracao()).toBe(duracaoEsperada);
    });

    it('deve retornar null se sessão não foi finalizada', () => {
      const sessao = SessaoEstudo.create(
        validSessaoData.materiaId,
        validSessaoData.provaId,
        validSessaoData.conteudo,
        validSessaoData.topicos,
        validSessaoData.tempoInicio
      );
      
      expect(sessao.getDuracao()).toBeNull();
    });

    it('deve retornar null se não houver tempoInicio', () => {
      const sessao = SessaoEstudo.create(
        validSessaoData.materiaId,
        validSessaoData.provaId,
        validSessaoData.conteudo,
        validSessaoData.topicos
      );
      
      sessao.tempoFim = new Date();
      expect(sessao.getDuracao()).toBeNull();
    });
  });

  describe('constructor', () => {
    it('deve criar instância com todos os parâmetros', () => {
      const id = 'test-id';
      const materiaId = 'materia-id';
      const provaId = 'prova-id';
      const conteudo = 'Conteúdo';
      const topicos = ['Tópico 1'];
      const tempoInicio = new Date('2024-01-01T10:00:00.000Z');
      const tempoFim = new Date('2024-01-01T11:00:00.000Z');
      const createdAt = new Date('2024-01-01');
      const updatedAt = new Date('2024-01-02');
      
      const sessao = new SessaoEstudo(id, materiaId, provaId, conteudo, topicos, tempoInicio, tempoFim);
      sessao.createdAt = createdAt;
      sessao.updatedAt = updatedAt;
      
      expect(sessao.id).toBe(id);
      expect(sessao.materiaId).toBe(materiaId);
      expect(sessao.provaId).toBe(provaId);
      expect(sessao.conteudo).toBe(conteudo);
      expect(sessao.topicos).toEqual(topicos);
      expect(sessao.tempoInicio).toBe(tempoInicio);
      expect(sessao.tempoFim).toBe(tempoFim);
      expect(sessao.createdAt).toBe(createdAt);
      expect(sessao.updatedAt).toBe(updatedAt);
    });
  });
}); 