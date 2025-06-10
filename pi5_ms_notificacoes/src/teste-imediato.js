import amqp from 'amqplib';
import dotenv from 'dotenv';

dotenv.config();

const RABBITMQ_URL = process.env.RABBITMQ || 'amqp://admin:admin@localhost:5672';
const USER_QUEUE = 'user_created_queue';
const EVENT_QUEUE = 'event_created_queue';
const EXAM_QUEUE = 'exam.created';

async function testeImediato() {
    let connection, channel;

    try {
        console.log('🚨 TESTE IMEDIATO - PROVA AGORA! 🚨');

        connection = await amqp.connect(RABBITMQ_URL);
        channel = await connection.createChannel();

        // Token e userId fixos
        const fcmToken = 'foHKBFb7RoyIMBiRrmZp5X:APA91bGhMUSZbfsHMiqXX7ECYYSTVpmxnn3D2crjtE4OjT4qdgahxfKkuWZJBU74KWdvUxOP_BcfzHZb2-9q7EVWNVyWzwb8S37gLTB9n17r4EbRFgGXJNA';
        const userId = 'test-user-immediate';

        // 1. Criar usuário primeiro
        console.log('👤 Criando usuário...');
        const userData = { fcmToken, id: userId };
        await channel.sendToQueue(USER_QUEUE, Buffer.from(JSON.stringify(userData)), { persistent: true });

        // Aguardar criação do usuário
        console.log('⏳ Aguardando 3 segundos...');
        await new Promise(resolve => setTimeout(resolve, 3000));

        // 2. Criar prova que acontece EM 1 DIA
        console.log('🚨 Criando PROVA IMEDIATA (1 dia)...');
        const agora = new Date();
        const provaEm1Dia = new Date(agora.getTime() + 1 * 24 * 60 * 60 * 1000); // 1 dia

        const examData = {
            data: {
                userId: userId,
                examType: 'prova',
                examId: '999',
                examData: {
                    id: 999,
                    titulo: '🔥 PROVA TESTE IMEDIATO',
                    descricao: 'Esta prova acontece em 1 dia!',
                    data: provaEm1Dia,
                    horario: provaEm1Dia,
                    local: 'TESTE AGORA',
                    materiaId: 'test-materia',
                    totalQuestoes: 10,
                    userId: userId,
                    createdAt: new Date()
                },
                action: 'CREATED'
            }
        };

        await channel.sendToQueue(EXAM_QUEUE, Buffer.from(JSON.stringify(examData)), { persistent: true });

        console.log('📋 PROVA CRIADA!');
        console.log(`🕐 Data da prova: ${provaEm1Dia.toLocaleString()}`);
        console.log('📱 Você deve receber notificação imediatamente!');

        console.log('\n✅ TESTE CONCLUÍDO!');
        console.log('🔔 Aguarde as notificações chegarem!');

    } catch (error) {
        console.error('❌ Erro:', error);
    } finally {
        if (channel) await channel.close();
        if (connection) await connection.close();
        process.exit(0);
    }
}

testeImediato();