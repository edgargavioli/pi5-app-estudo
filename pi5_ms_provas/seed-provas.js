import { PrismaClient } from './src/node_modules/.prisma/client/default.js';

const prisma = new PrismaClient();

async function seedProvas() {
  try {
    // Verificar se já existem provas
    const provasExistentes = await prisma.prova.count();
    
    if (provasExistentes > 0) {
      console.log(`✅ Já existem ${provasExistentes} provas no banco.`);
      return;
    }

    // Buscar matérias existentes
    const materias = await prisma.materia.findMany();
    
    if (materias.length === 0) {
      console.log('❌ Nenhuma matéria encontrada. Execute o seed de matérias primeiro.');
      return;
    }

    console.log(`📚 Encontradas ${materias.length} matérias. Criando provas...`);

    // Criar provas associadas às matérias
    const provas = [
      {
        titulo: 'ENEM 2024',
        descricao: 'Exame Nacional do Ensino Médio',
        data: new Date('2024-11-05'),
        horario: new Date('2024-11-05T13:30:00'),
        local: 'Colégio Estadual Central',
        materiaId: materias.find(m => m.nome === 'Matemática')?.id,
        totalQuestoes: 45, // Matemática no ENEM
        filtros: {
          'tipo': 'vestibular',
          'nivel': 'medio'
        }
      },
      {
        titulo: 'Vestibular USP 2024',
        descricao: 'Vestibular da Universidade de São Paulo',
        data: new Date('2024-12-01'),
        horario: new Date('2024-12-01T14:00:00'),
        local: 'Campus USP',
        materiaId: materias.find(m => m.nome === 'Português')?.id,
        totalQuestoes: 30,
        filtros: {
          'tipo': 'vestibular',
          'nivel': 'superior'
        }
      },
      {
        titulo: 'Concurso TRT 2024',
        descricao: 'Tribunal Regional do Trabalho',
        data: new Date('2024-10-20'),
        horario: new Date('2024-10-20T08:00:00'),
        local: 'Centro de Convenções',
        materiaId: materias.find(m => m.nome === 'História')?.id,
        totalQuestoes: 50,
        filtros: {
          'tipo': 'concurso',
          'area': 'juridica'
        }
      },
      {
        titulo: 'Prova de Física UFMG',
        descricao: 'Prova específica de Física da UFMG',
        data: new Date('2024-11-15'),
        horario: new Date('2024-11-15T15:00:00'),
        local: 'Instituto de Ciências Exatas',
        materiaId: materias.find(m => m.nome === 'Física')?.id,
        totalQuestoes: 25,
        filtros: {
          'tipo': 'vestibular',
          'area': 'exatas'
        }
      },
      {
        titulo: 'ENADE Biologia 2024',
        descricao: 'Exame Nacional de Desempenho dos Estudantes',
        data: new Date('2024-11-24'),
        horario: new Date('2024-11-24T13:00:00'),
        local: 'Universidade Federal',
        materiaId: materias.find(m => m.nome === 'Biologia')?.id,
        totalQuestoes: 40,
        filtros: {
          'tipo': 'avaliacao',
          'area': 'biologicas'
        }
      }
    ];

    console.log('🌱 Criando provas...');

    for (const provaData of provas) {
      if (!provaData.materiaId) {
        console.log(`⚠️ Matéria não encontrada para a prova: ${provaData.titulo}`);
        continue;
      }

      const novaProva = await prisma.prova.create({
        data: provaData,
        include: {
          materia: true
        }
      });

      console.log(`✅ Prova criada: ${novaProva.titulo} (Matéria: ${novaProva.materia.nome})`);
    }

    console.log('🎉 Seed de provas concluído com sucesso!');

  } catch (error) {
    console.error('❌ Erro ao fazer seed das provas:', error);
  } finally {
    await prisma.$disconnect();
  }
}

seedProvas(); 