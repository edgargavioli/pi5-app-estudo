import { PrismaClient } from './src/node_modules/.prisma/client/default.js';

const prisma = new PrismaClient();

async function seedMaterias() {
  try {
    // Verificar se já existem matérias
    const materiasExistentes = await prisma.materia.count();
    
    if (materiasExistentes > 0) {
      console.log(`✅ Já existem ${materiasExistentes} matérias no banco.`);
      return;
    }

    // Criar matérias básicas
    const materias = [
      {
        nome: 'Matemática',
        descricao: 'Matemática básica e avançada'
      },
      {
        nome: 'Português',
        descricao: 'Língua Portuguesa e Literatura'
      },
      {
        nome: 'História',
        descricao: 'História Geral e do Brasil'
      },
      {
        nome: 'Geografia',
        descricao: 'Geografia Física e Humana'
      },
      {
        nome: 'Biologia',
        descricao: 'Ciências Biológicas'
      },
      {
        nome: 'Física',
        descricao: 'Física Geral'
      },
      {
        nome: 'Química',
        descricao: 'Química Geral e Orgânica'
      },
      {
        nome: 'Inglês',
        descricao: 'Língua Inglesa'
      }
    ];

    console.log('🌱 Criando matérias...');

    for (const materia of materias) {
      const novaMaterial = await prisma.materia.create({
        data: materia
      });
      console.log(`✅ Matéria criada: ${novaMaterial.nome}`);
    }

    console.log('🎉 Seed de matérias concluído com sucesso!');

  } catch (error) {
    console.error('❌ Erro ao fazer seed das matérias:', error);
  } finally {
    await prisma.$disconnect();
  }
}

seedMaterias(); 