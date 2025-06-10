import amqp from 'amqplib';
import dotenv from 'dotenv';

// Carregar variáveis de ambiente
dotenv.config();

const RABBITMQ_URL = process.env.RABBITMQ || 'amqp://admin:admin123@rabbitmq-broker:5672/';
const USER_QUEUE = process.env.USER_QUEUE || 'user_created_queue';
const EVENT_QUEUE = process.env.EVENT_QUEUE || 'event_created_queue';
const STREAK_QUEUE = process.env.STREAK_QUEUE || 'streak_created_queue';
const EXAM_QUEUE = process.env.EXAM_QUEUE || 'exam.created';
const SESSION_CREATED_QUEUE = process.env.SESSAO_CRIADA_QUEUE || 'sessao.criada';
const SESSION_FINISHED_QUEUE = process.env.SESSAO_FINALIZADA_QUEUE || 'sessao.finalizada';
const FCM_TOKEN_UPDATED_QUEUE = 'fcm_token_updated_queue';

class TestProducer {
    constructor() {
        this.connection = null;
        this.channel = null;
        this.currentUserId = null;
        this.currentFcmToken = null;
    }

    async connect() {
        try {
            console.log('🔗 Conectando ao RabbitMQ...');
            this.connection = await amqp.connect(RABBITMQ_URL);
            this.channel = await this.connection.createChannel();
            console.log('✅ Conectado ao RabbitMQ com sucesso!');
        } catch (error) {
            console.error('❌ Erro ao conectar no RabbitMQ:', error);
            throw error;
        }
    }

    async setupQueues() {
        try {
            console.log('🏗️ Configurando filas...');
            await this.channel.assertQueue(USER_QUEUE, { durable: true });
            await this.channel.assertQueue(EVENT_QUEUE, { durable: true });
            await this.channel.assertQueue(STREAK_QUEUE, { durable: true });
            await this.channel.assertQueue(EXAM_QUEUE, { durable: true });
            await this.channel.assertQueue(SESSION_CREATED_QUEUE, { durable: true });
            await this.channel.assertQueue(SESSION_FINISHED_QUEUE, { durable: true });
            await this.channel.assertQueue(FCM_TOKEN_UPDATED_QUEUE, { durable: true });
            console.log('✅ Filas configuradas com sucesso!');
        } catch (error) {
            console.error('❌ Erro ao configurar filas:', error);
            throw error;
        }
    }

    async sendUserMessage() {
        this.currentUserId = Math.floor(Math.random() * 1000);
        this.currentFcmToken = `foHKBFb7RoyIMBiRrmZp5X:APA91bGhMUSZbfsHMiqXX7ECYYSTVpmxnn3D2crjtE4OjT4qdgahxfKkuWZJBU74KWdvUxOP_BcfzHZb2-9q7EVWNVyWzwb8S37gLTB9n17r4EbRFgGXJNA`;

        const userData = {
            id: this.currentUserId,
            fcmToken: this.currentFcmToken,
            name: 'Test User',
            email: 'test@example.com',
            createdAt: new Date().toISOString()
        };

        try {
            const message = Buffer.from(JSON.stringify(userData));
            await this.channel.sendToQueue(USER_QUEUE, message, { persistent: true });
            console.log('📤 Mensagem de usuário enviada:', userData);
            return userData;
        } catch (error) {
            console.error('❌ Erro ao enviar mensagem de usuário:', error);
            throw error;
        }
    }

    async sendEventMessage() {
        if (!this.currentFcmToken) {
            console.error('❌ Nenhum fcmToken disponível. Envie uma mensagem de usuário primeiro.');
            return;
        }

        const message = {
            fcmToken: this.currentFcmToken, // ✅ Usar o mesmo token do usuário criado
            eventData: {
                id: Math.floor(Math.random() * 1000),
                name: 'Evento de Teste',
                description: 'Este é um evento de teste',
                date: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000), // 5 dias no futuro
                location: 'Local de Teste',
                createdAt: new Date()
            }
        };

        await this.channel.sendToQueue(EVENT_QUEUE, Buffer.from(JSON.stringify(message)), { persistent: true });
        console.log('📤 Mensagem de evento enviada:', message);
    }

    async sendStreakMessage() {
        if (!this.currentFcmToken) {
            console.error('❌ Nenhum fcmToken disponível. Envie uma mensagem de usuário primeiro.');
            return;
        }

        const message = {
            fcmToken: this.currentFcmToken, // ✅ Usar o mesmo token do usuário criado
            streakData: {
                id: Math.floor(Math.random() * 1000),
                currentCount: Math.floor(Math.random() * 30) + 1,
                lastActivityDate: new Date(Date.now() - 24 * 60 * 60 * 1000), // 1 dia atrás
                expiresAt: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000), // 2 dias no futuro
                activityType: 'daily_login',
                createdAt: new Date()
            }
        };

        await this.channel.sendToQueue(STREAK_QUEUE, Buffer.from(JSON.stringify(message)), { persistent: true });
        console.log('📤 Mensagem de streak enviada:', message);
    }

    async sendExamMessage() {
        if (!this.currentFcmToken) {
            console.error('❌ Nenhum fcmToken disponível. Envie uma mensagem de usuário primeiro.');
            return;
        }

        // Primeiro, criar usuário com ID específico para teste
        const userId = 'test-user-' + Math.floor(Math.random() * 1000);

        const examMessage = {
            data: {
                userId: userId,
                examType: 'prova',
                examId: Math.floor(Math.random() * 1000).toString(),
                examData: {
                    id: Math.floor(Math.random() * 1000),
                    titulo: 'Prova de Matemática - TESTE',
                    descricao: 'Prova de teste do sistema',
                    data: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 dias no futuro
                    horario: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
                    local: 'Sala 101',
                    materiaId: 'test-materia-id',
                    totalQuestoes: 20,
                    userId: userId,
                    createdAt: new Date()
                },
                action: 'CREATED'
            }
        };

        // Enviar para a fila de exames
        await this.channel.sendToQueue(EXAM_QUEUE, Buffer.from(JSON.stringify(examMessage)), { persistent: true });
        console.log('📤 Mensagem de prova enviada:', examMessage);
    }

    async sendSessionCreatedMessage() {
        if (!this.currentFcmToken) {
            console.error('❌ Nenhum fcmToken disponível. Envie uma mensagem de usuário primeiro.');
            return;
        }

        const message = {
            fcmToken: this.currentFcmToken,
            sessionData: {
                id: Math.floor(Math.random() * 1000),
                subject: 'Física',
                duration: 60,
                startTime: new Date(),
                createdAt: new Date()
            }
        };

        await this.channel.sendToQueue(SESSION_CREATED_QUEUE, Buffer.from(JSON.stringify(message)), { persistent: true });
        console.log('📤 Mensagem de sessão criada enviada:', message);
    }

    async sendSessionFinishedMessage() {
        if (!this.currentFcmToken) {
            console.error('❌ Nenhum fcmToken disponível. Envie uma mensagem de usuário primeiro.');
            return;
        }

        const message = {
            fcmToken: this.currentFcmToken,
            sessionData: {
                id: Math.floor(Math.random() * 1000),
                subject: 'Química',
                duration: 45,
                completedAt: new Date(),
                score: 85
            }
        };

        await this.channel.sendToQueue(SESSION_FINISHED_QUEUE, Buffer.from(JSON.stringify(message)), { persistent: true });
        console.log('📤 Mensagem de sessão finalizada enviada:', message);
    }

    async sendFcmTokenUpdate() {
        if (!this.currentUserId) {
            console.error('❌ Nenhum usuário disponível. Envie uma mensagem de usuário primeiro.');
            return;
        }

        const newFcmToken = `NEW_TOKEN_${Date.now()}:APA91bGhMUSZbfsHMiqXX7ECYYSTVpmxnn3D2crjtE4OjT4qdgahxfKkuWZJBU74KWdvUxOP_BcfzHZb2-9q7EVWNVyWzwb8S37gLTB9n17r4EbRFgGXJNA`;

        const message = {
            eventType: 'FCM_TOKEN_UPDATED',
            timestamp: new Date().toISOString(),
            data: {
                userId: this.currentUserId,
                fcmToken: newFcmToken,
                oldFcmToken: this.currentFcmToken,
                updatedAt: new Date().toISOString()
            }
        };

        try {
            await this.channel.sendToQueue(FCM_TOKEN_UPDATED_QUEUE, Buffer.from(JSON.stringify(message)), { persistent: true });
            console.log('📤 Mensagem de FCM token atualizado enviada:', message);

            // Atualizar token atual para próximos testes
            this.currentFcmToken = newFcmToken;
        } catch (error) {
            console.error('❌ Erro ao enviar mensagem de FCM token atualizado:', error);
            throw error;
        }
    }

    async sendTestMessages() {
        console.log('\n🧪 Iniciando envio de mensagens de teste...\n');

        console.log('👤 Testando fila de usuários...');
        await this.sendUserMessage();
        await this.delay(2000);

        console.log('\n📱 Testando fila de FCM token atualizado...');
        await this.sendFcmTokenUpdate();
        await this.delay(1000);

        // Enviar mensagem de evento (usando o mesmo fcmToken)
        console.log('\n📅 Testando fila de eventos...');
        await this.sendEventMessage();
        await this.delay(1000);

        // Enviar mensagem de prova
        console.log('\n📋 Testando fila de provas...');
        await this.sendExamMessage();
        await this.delay(1000);

        // Enviar mensagem de sessão criada
        console.log('\n📚 Testando fila de sessão criada...');
        await this.sendSessionCreatedMessage();
        await this.delay(1000);

        // Enviar mensagem de sessão finalizada
        console.log('\n✅ Testando fila de sessão finalizada...');
        await this.sendSessionFinishedMessage();
        await this.delay(1000);

        // Enviar mensagem de streak (usando o mesmo fcmToken)
        console.log('\n🔥 Testando fila de streaks...');
        await this.sendStreakMessage();
        await this.delay(1000);

        console.log('\n✅ Todas as mensagens de teste foram enviadas!');
    }

    async sendMultipleMessages(count = 3) {
        console.log(`\n🔄 Enviando ${count} conjuntos de mensagens...\n`);

        for (let i = 1; i <= count; i++) {
            console.log(`\n📦 Conjunto ${i}/${count}:`);

            // Criar usuário primeiro
            await this.sendUserMessage();
            await this.delay(2000); // ✅ Aguardar criação

            // Criar evento e streak para o mesmo usuário
            await this.sendEventMessage();
            await this.delay(500);

            await this.sendStreakMessage();
            await this.delay(500);
        }

        console.log(`\n✅ ${count * 3} mensagens enviadas com sucesso!`);
    }

    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    async close() {
        try {
            if (this.channel) {
                await this.channel.close();
            }
            if (this.connection) {
                await this.connection.close();
            }
            console.log('🔌 Conexão fechada.');
        } catch (error) {
            console.error('❌ Erro ao fechar conexão:', error);
        }
    }
}

// Função principal para executar os testes
async function runTests() {
    const producer = new TestProducer();

    try {
        // Conectar ao RabbitMQ
        await producer.connect();

        // Configurar filas
        await producer.setupQueues();

        // Aguardar um pouco antes de enviar mensagens
        console.log('\n⏳ Aguardando 2 segundos antes de enviar mensagens...');
        await producer.delay(2000);

        // Enviar mensagens de teste
        await producer.sendTestMessages();

        // Aguardar mais um pouco
        await producer.delay(2000);

        // Enviar múltiplas mensagens para teste de volume
        await producer.sendMultipleMessages(2);

    } catch (error) {
        console.error('❌ Erro durante execução dos testes:', error);
    } finally {
        // Fechar conexão
        await producer.close();
        process.exit(0);
    }
}

// Executar apenas se o arquivo for executado diretamente
console.log('🚀 Iniciando testes do Producer RabbitMQ...\n');
runTests();

export default TestProducer;