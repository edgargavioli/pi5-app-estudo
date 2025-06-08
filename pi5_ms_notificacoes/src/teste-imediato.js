import amqp from 'amqplib';
import dotenv from 'dotenv';

dotenv.config();

const RABBITMQ_URL = process.env.RABBITMQ || 'amqp://admin:admin@localhost:5672';
const USER_QUEUE = 'user_created_queue';
const EVENT_QUEUE = 'event_created_queue';

async function testeImediato() {
    let connection, channel;

    try {
        console.log('🚨 TESTE IMEDIATO - EVENTO AGORA! 🚨');

        connection = await amqp.connect(RABBITMQ_URL);
        channel = await connection.createChannel();

        // Token fixo
        const fcmToken = 'foHKBFb7RoyIMBiRrmZp5X:APA91bGhMUSZbfsHMiqXX7ECYYSTVpmxnn3D2crjtE4OjT4qdgahxfKkuWZJBU74KWdvUxOP_BcfzHZb2-9q7EVWNVyWzwb8S37gLTB9n17r4EbRFgGXJNA';

        // 1. Criar usuário primeiro
        console.log('👤 Criando usuário...');
        const userData = { fcmToken };
        await channel.sendToQueue(USER_QUEUE, Buffer.from(JSON.stringify(userData)), { persistent: true });

        // Aguardar criação do usuário
        console.log('⏳ Aguardando 3 segundos...');
        await new Promise(resolve => setTimeout(resolve, 3000));

        // 2. Criar evento que acontece EM 2 MINUTOS
        console.log('🚨 Criando EVENTO IMEDIATO (2 minutos)...');
        const agora = new Date();
        const eventoEm2Min = new Date(agora.getTime() + 2 * 60 * 1000); // 2 minutos

        const eventData = {
            fcmToken,
            eventData: {
                id: 999,
                name: '🔥 EVENTO TESTE IMEDIATO',
                description: 'Este evento acontece em 2 minutos!',
                date: eventoEm2Min,
                location: 'TESTE AGORA',
                createdAt: new Date()
            }
        };

        await channel.sendToQueue(EVENT_QUEUE, Buffer.from(JSON.stringify(eventData)), { persistent: true });

        console.log('📅 EVENTO CRIADO!');
        console.log(`🕐 Data do evento: ${eventoEm2Min.toLocaleString()}`);
        console.log('📱 Você deve receber notificação em ~2 minutos!');

        // 3. Criar também um evento para HOJE às 8h (se ainda não passou)
        const hoje8h = new Date();
        hoje8h.setHours(8, 0, 0, 0);

        if (hoje8h > new Date()) {
            console.log('📅 Criando evento para hoje às 8h...');
            const eventHoje = {
                fcmToken,
                eventData: {
                    id: 998,
                    name: 'Evento Hoje às 8h',
                    description: 'Evento programado para hoje',
                    date: hoje8h,
                    location: 'TESTE HOJE',
                    createdAt: new Date()
                }
            };
            await channel.sendToQueue(EVENT_QUEUE, Buffer.from(JSON.stringify(eventHoje)), { persistent: true });
            console.log(`🕰️ Evento para hoje criado: ${hoje8h.toLocaleString()}`);
        }

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