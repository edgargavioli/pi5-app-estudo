import { jest } from '@jest/globals';
import { MateriaValidator } from '../../../../src/application/validators/MateriaValidator.js';

describe('MateriaValidator', () => {
  describe('validate', () => {
    it('deve validar dados corretos', () => {
      const validData = {
        nome: 'Matemática',
        descricao: 'Matemática básica e avançada',
        disciplina: 'Exatas'
      };

      const result = MateriaValidator.validate(validData);

      expect(result).toEqual(validData);
    });

    it('deve validar dados sem descrição', () => {
      const validData = {
        nome: 'Matemática',
        disciplina: 'Exatas'
      };

      const result = MateriaValidator.validate(validData);

      expect(result).toEqual(validData);
    });

    it('deve lançar erro se nome for vazio', () => {
      const invalidData = {
        nome: '',
        disciplina: 'Exatas'
      };

      expect(() => {
        MateriaValidator.validate(invalidData);
      }).toThrow('Nome é obrigatório');
    });

    it('deve lançar erro se nome for null', () => {
      const invalidData = {
        nome: null,
        disciplina: 'Exatas'
      };

      expect(() => {
        MateriaValidator.validate(invalidData);
      }).toThrow('Expected string, received null');
    });

    it('deve lançar erro se nome for undefined', () => {
      const invalidData = {
        disciplina: 'Exatas'
      };

      expect(() => {
        MateriaValidator.validate(invalidData);
      }).toThrow('Required');
    });

    it('deve lançar erro se disciplina for vazia', () => {
      const invalidData = {
        nome: 'Matemática',
        disciplina: ''
      };

      expect(() => {
        MateriaValidator.validate(invalidData);
      }).toThrow('Disciplina é obrigatória');
    });

    it('deve lançar erro se disciplina for null', () => {
      const invalidData = {
        nome: 'Matemática',
        disciplina: null
      };

      expect(() => {
        MateriaValidator.validate(invalidData);
      }).toThrow('Expected string, received null');
    });

    it('deve lançar erro se disciplina for undefined', () => {
      const invalidData = {
        nome: 'Matemática'
      };

      expect(() => {
        MateriaValidator.validate(invalidData);
      }).toThrow('Required');
    });

    it('deve aceitar nome com espaços', () => {
      const validData = {
        nome: '  Matemática  ',
        disciplina: 'Exatas'
      };

      const result = MateriaValidator.validate(validData);

      expect(result.nome).toBe('  Matemática  ');
    });

    it('deve aceitar disciplina com espaços', () => {
      const validData = {
        nome: 'Matemática',
        disciplina: '  Exatas  '
      };

      const result = MateriaValidator.validate(validData);

      expect(result.disciplina).toBe('  Exatas  ');
    });
  });
}); 