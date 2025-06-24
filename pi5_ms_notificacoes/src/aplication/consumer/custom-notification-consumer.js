import { getChannel } from "../../infrastructure/messaging/rabbitmq.js";
import NotificationPersistence from "../../infrastructure/persistence/notification.js";
import UserPersistence from "../../infrastructure/persistence/user.js";

const notificationPersistence = new NotificationPersistence();
const userPersistence = new UserPersistence();

/**
 * Contextos personalizados para sessões baseado no conteúdo
 */
function getSessaoContexto(sessaoData) {
    const conteudo = (sessaoData.conteudo || '').toLowerCase();
    const topicos = (sessaoData.topicos || []).join(' ').toLowerCase();
    const texto = `${conteudo} ${topicos}`;

    // Detectar contexto baseado no conteúdo com contextos muito mais ricos
    if (texto.includes('matemática') || texto.includes('cálculo') || texto.includes('álgebra') ||
        texto.includes('geometria') || texto.includes('trigonometria') || texto.includes('função') ||
        texto.includes('equação') || texto.includes('logaritmo') || texto.includes('matriz')) {
        return {
            emoji: '🔢',
            materia: 'Matemática',
            titulo: 'Sessão de Matemática',
            tipo: 'exata',
            mensagemCriacao: 'Sua sessão de matemática',
            dicaPreparacao: '💡 Tenha sempre papel, lápis, borracha e calculadora à mão!',
            preparacao: '🔢 Organize suas fórmulas e prepare-se para os cálculos!',
            motivacao: 'Cada problema resolvido é um passo para a excelência! 📐',
            ultimoAviso: 'É hora de dominar os números!',
            mensagemInicio: 'Vamos dominar os números!',
            ferramentas: ['Calculadora científica', 'Papel milimetrado', 'Régua', 'Tabela de fórmulas'],
            dicaPausa: 'Faça um exercício físico leve - isso oxigena o cérebro para cálculos!'
        };
    }

    if (texto.includes('física') || texto.includes('mecânica') || texto.includes('eletricidade') ||
        texto.includes('óptica') || texto.includes('termodinâmica') || texto.includes('ondas')) {
        return {
            emoji: '⚡',
            materia: 'Física',
            titulo: 'Sessão de Física',
            tipo: 'exata',
            mensagemCriacao: 'Sua sessão de física',
            dicaPreparacao: '🔬 Prepare experimentos mentais e visualize os fenômenos!',
            preparacao: '⚡ Visualize as leis da física e prepare suas fórmulas!',
            motivacao: 'A física explica tudo ao nosso redor! Seja curioso(a)! 🌌',
            ultimoAviso: 'As leis da física te aguardam!',
            mensagemInicio: 'Hora de desvendar o universo!',
            ferramentas: ['Tabela de constantes', 'Calculadora', 'Diagramas', 'Simuladores'],
            dicaPausa: 'Observe a física ao seu redor durante a pausa - a gravidade, o movimento!'
        };
    }

    if (texto.includes('química') || texto.includes('orgânica') || texto.includes('reações') ||
        texto.includes('átomo') || texto.includes('molécula') || texto.includes('elemento')) {
        return {
            emoji: '🧪',
            materia: 'Química',
            titulo: 'Sessão de Química',
            tipo: 'exata',
            mensagemCriacao: 'Sua sessão de química',
            dicaPreparacao: '⚗️ Visualize as moléculas e suas interações!',
            preparacao: '🧪 Organize sua tabela periódica e visualize as transformações!',
            motivacao: 'A química está em tudo! Transforme conhecimento em sucesso! ⚗️',
            ultimoAviso: 'As moléculas estão prontas para reagir!',
            mensagemInicio: 'Vamos criar algumas reações!',
            ferramentas: ['Tabela periódica', 'Modelos moleculares', 'Calculadora'],
            dicaPausa: 'Observe a química ao redor: a digestão, a fotossíntese!'
        };
    }

    if (texto.includes('história') || texto.includes('brasil') || texto.includes('mundo') ||
        texto.includes('guerra') || texto.includes('revolução') || texto.includes('império')) {
        return {
            emoji: '🏛️',
            materia: 'História',
            titulo: 'Sessão de História',
            tipo: 'humana',
            mensagemCriacao: 'Sua sessão de história',
            dicaPreparacao: '📜 Prepare cronologias e conecte eventos passados ao presente!',
            preparacao: '🏛️ Organize suas cronologias e prepare sua máquina do tempo mental!',
            motivacao: 'Cada período histórico tem lições para o presente! 📜',
            ultimoAviso: 'A máquina do tempo está pronta!',
            mensagemInicio: 'Hora de viajar no tempo!',
            ferramentas: ['Atlas histórico', 'Linha do tempo', 'Mapas', 'Biografias'],
            dicaPausa: 'Reflita sobre como os eventos estudados ainda influenciam hoje!'
        };
    }

    if (texto.includes('português') || texto.includes('literatura') || texto.includes('redação') ||
        texto.includes('gramática') || texto.includes('texto') || texto.includes('interpretação')) {
        return {
            emoji: '�',
            materia: 'Português',
            titulo: 'Sessão de Português',
            tipo: 'linguística',
            mensagemCriacao: 'Sua sessão de português',
            dicaPreparacao: '✍️ Prepare textos diversos e exercite sua expressão!',
            preparacao: '📝 Organize seus textos e prepare sua expressão!',
            motivacao: 'Palavras são poder! Use-as com maestria! ✍️',
            ultimoAviso: 'É hora de dominar nossa língua!',
            mensagemInicio: 'Vamos dominar nossa língua!',
            ferramentas: ['Dicionário completo', 'Gramática', 'Textos diversos'],
            dicaPausa: 'Converse com alguém ou escreva seus pensamentos!'
        };
    }

    if (texto.includes('biologia') || texto.includes('célula') || texto.includes('genética') ||
        texto.includes('evolução') || texto.includes('ecologia') || texto.includes('anatomia')) {
        return {
            emoji: '🧬',
            materia: 'Biologia',
            titulo: 'Sessão de Biologia',
            tipo: 'natural',
            mensagemCriacao: 'Sua sessão de biologia',
            dicaPreparacao: '🔬 Visualize processos celulares e conexões ecológicas!',
            preparacao: '🧬 Conecte-se com a vida ao seu redor!',
            motivacao: 'Você é parte dessa teia incrível da vida! 🌿',
            ultimoAviso: 'A vida em suas múltiplas formas te espera!',
            mensagemInicio: 'Vamos explorar os mistérios da vida!',
            ferramentas: ['Atlas biológico', 'Modelos celulares', 'Esquemas'],
            dicaPausa: 'Observe plantas, animais ou suas próprias células trabalhando!'
        };
    }

    // Contexto padrão
    return {
        emoji: '📚',
        materia: 'Estudo Geral',
        titulo: 'Sessão de Estudo',
        tipo: 'geral',
        mensagemCriacao: 'Sua sessão de estudo',
        dicaPreparacao: '📖 Organize seus materiais e prepare sua mente!',
        preparacao: '📚 Organize seus materiais e foque nos objetivos!',
        motivacao: 'Conhecimento é o único tesouro que ninguém pode roubar! 💎',
        ultimoAviso: 'Sua mente está pronta para absorver conhecimento!',
        mensagemInicio: 'Vamos estudar com propósito e foco!',
        ferramentas: ['Material de estudo', 'Caderno', 'Marcadores'],
        dicaPausa: 'Reflita sobre o que aprendeu e como pode aplicar!'
    };
}

/**
 * Contextos para eventos baseado no tipo
 */
function getEventoContexto(tipoEvento) {
    const contextos = {
        'PROVA_SIMULADA': {
            emoji: '📝',
            titulo: 'Simulado',
            mensagemCriacao: 'Seu simulado',
            lembreteUrgente: 'Atenção! Seu simulado',
            mensagemDia: 'É hora do seu simulado!',
            motivacao: 'Você treinou para isso! Vá com confiança! 💪'
        },
        'EXAME_OFICIAL': {
            emoji: '🎓',
            titulo: 'Exame',
            mensagemCriacao: 'Seu exame',
            lembreteUrgente: 'IMPORTANTE! Seu exame',
            mensagemDia: 'DIA DO EXAME!',
            motivacao: 'Todo seu esforço foi para este momento! Você consegue! 🌟'
        },
        'VESTIBULAR': {
            emoji: '🎯',
            titulo: 'Vestibular',
            mensagemCriacao: 'Seu vestibular',
            lembreteUrgente: 'VESTIBULAR CHEGANDO!',
            mensagemDia: 'DIA DO VESTIBULAR!',
            motivacao: 'Este é o momento que define seu futuro! Mande ver! 🚀'
        },
        'ENEM': {
            emoji: '📚',
            titulo: 'ENEM',
            mensagemCriacao: 'Sua prova do ENEM',
            lembreteUrgente: 'ENEM se aproxima!',
            mensagemDia: 'DIA DO ENEM!',
            motivacao: 'Anos de estudo para este momento! Você está preparado(a)! 🌈'
        },
        'CONCURSO': {
            emoji: '⚖️',
            titulo: 'Concurso',
            mensagemCriacao: 'Seu concurso',
            lembreteUrgente: 'CONCURSO em 3 dias!',
            mensagemDia: 'DIA DO CONCURSO!',
            motivacao: 'O cargo dos seus sonhos está ao seu alcance! Foco total! 💼'
        }
    };

    return contextos[tipoEvento] || {
        emoji: '📋',
        titulo: 'Evento',
        mensagemCriacao: 'Seu evento',
        lembreteUrgente: 'Seu evento',
        mensagemDia: 'Seu evento é hoje!',
        motivacao: 'Boa sorte em seu evento! 🍀'
    };
}

/**
 * Calcula duração da sessão em formato amigável
 */
function calcularDuracaoSessao(sessaoData) {
    if (!sessaoData.tempoInicio || !sessaoData.tempoFim) {
        return 'Duração não definida';
    }

    const inicio = new Date(sessaoData.tempoInicio);
    const fim = new Date(sessaoData.tempoFim);
    const duracaoMs = fim - inicio;
    const horas = Math.floor(duracaoMs / (1000 * 60 * 60));
    const minutos = Math.floor((duracaoMs % (1000 * 60 * 60)) / (1000 * 60));

    if (horas > 0) {
        return `${horas}h${minutos > 0 ? ` ${minutos}min` : ''}`;
    }
    return `${minutos}min`;
}

/**
 * Processa notificações de eventos criados
 */
async function processEventoNotificacao(msg, channel) {
    if (!msg) {
        console.error('Received null message for evento notification');
        return;
    }

    try {
        const message = JSON.parse(msg.content.toString());
        console.log('📬 Processing evento notification:', message);

        // A estrutura vem aninhada: message.data.data contém os dados do evento
        const eventData = message.data.data || message.data;

        console.log('🔍 Debug evento - eventData:', eventData);

        // Verificar se o usuário existe
        let user;
        try {
            const userId = eventData.userId || 'user-default';
            if (userId && userId !== 'user-default') {
                console.log('🔍 Buscando usuário por ID:', userId);
                user = await userPersistence.findById(userId);
            } else {
                console.log('🔍 Usando fallback para usuário padrão');
                const defaultUsers = await userPersistence.getAll();
                user = defaultUsers[0];
            }
        } catch (error) {
            console.error(`❌ User not found:`, error.message);
            channel.ack(msg);
            return;
        }

        if (!user) {
            console.error('❌ Nenhum usuário encontrado para criar notificações');
            channel.ack(msg);
            return;
        }

        // Gerar notificações personalizadas baseadas nas regras de negócio
        const agora = new Date();
        const dataEvento = new Date(eventData.data || eventData.dataEvento);
        const horarioEvento = new Date(eventData.horario);
        const diasAteEvento = Math.ceil((dataEvento - agora) / (1000 * 60 * 60 * 24)); const contextoEvento = getEventoContexto(eventData.tipo);

        // Notificação imediata
        await notificationPersistence.create({
            userId: user.id,
            type: `EVENTO_CRIADO`,
            entityId: eventData.eventoId || eventData.id,
            entityType: 'evento',
            entityData: eventData,
            scheduledFor: agora,
            message: `${contextoEvento.emoji} ${contextoEvento.titulo} Criado!`,
            title: `${contextoEvento.emoji} ${contextoEvento.titulo} Criado!`,
            body: `${contextoEvento.mensagemCriacao} "${eventData.titulo}" foi agendado${diasAteEvento > 0 ? ` para ${diasAteEvento} dias` : ' para hoje'}! 📅\n📍 Local: ${eventData.local}\n⏰ Horário: ${horarioEvento.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}`,
            priority: 'normal'
        });

        // Lembrete 3 dias antes (se aplicável)
        if (diasAteEvento > 3) {
            const lembrete3Dias = new Date(dataEvento.getTime() - 3 * 24 * 60 * 60 * 1000);
            await notificationPersistence.create({
                userId: user.id,
                type: `EVENTO_LEMBRETE_3_DIAS`,
                entityId: eventData.eventoId || eventData.id,
                entityType: 'evento',
                entityData: eventData,
                scheduledFor: lembrete3Dias,
                message: `⏰ Lembrete: ${contextoEvento.titulo} em 3 dias`,
                title: `⏰ Lembrete: ${contextoEvento.titulo} em 3 dias`,
                body: `${contextoEvento.lembreteUrgente} "${eventData.titulo}" acontece em 3 dias! 🗓️\n📍 Local: ${eventData.local}\n⏰ Horário: ${horarioEvento.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}`,
                priority: 'high'
            });
        }

        // Lembrete no dia do evento
        if (diasAteEvento > 0) {
            const lembreteHoje = new Date(dataEvento.setHours(8, 0, 0, 0));
            await notificationPersistence.create({
                userId: user.id,
                type: `EVENTO_DIA`,
                entityId: eventData.eventoId || eventData.id,
                entityType: 'evento',
                entityData: eventData,
                scheduledFor: lembreteHoje,
                message: `🔥 HOJE: ${contextoEvento.titulo}!`,
                title: `🔥 HOJE: ${contextoEvento.titulo}!`,
                body: `${contextoEvento.mensagemDia} "${eventData.titulo}" é HOJE! 🎯\n📍 ${eventData.local}\n⏰ ${horarioEvento.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}\n\n${contextoEvento.motivacao}`,
                priority: 'critical'
            });
        }

        console.log(`✅ Notificações de evento criadas para ${eventData.titulo}`);
        channel.ack(msg);
    } catch (error) {
        console.error('Error processing evento notification:', error);
        channel.nack(msg, false, true);
    }
}/**
 * Processa notificações de sessões criadas
 */
async function processSessaoNotificacao(msg, channel) {
    if (!msg) {
        console.error('Received null message for sessao notification');
        return;
    }

    try {
        const message = JSON.parse(msg.content.toString());
        console.log('📚 Processing sessao notification:', message);

        // A estrutura vem aninhada: message.data.data contém os dados da sessão
        const sessaoData = message.data.data || message.data;

        console.log('🔍 Debug sessao - sessaoData:', sessaoData);

        // Verificar se o usuário existe
        let user;
        try {
            const userId = sessaoData.userId || 'user-default';
            if (userId && userId !== 'user-default') {
                console.log('🔍 Buscando usuário por ID:', userId);
                user = await userPersistence.findById(userId);
            } else {
                console.log('🔍 Usando fallback para usuário padrão');
                const defaultUsers = await userPersistence.getAll();
                user = defaultUsers[0];
            }
        } catch (error) {
            console.error(`❌ User not found:`, error.message);
            channel.ack(msg);
            return;
        }

        if (!user) {
            console.error('❌ Nenhum usuário encontrado para criar notificações');
            channel.ack(msg);
            return;
        }

        // Gerar notificações personalizadas para sessões
        const agora = new Date();
        const tempoInicio = sessaoData.tempoInicio ? new Date(sessaoData.tempoInicio) : null;
        const contextoSessao = getSessaoContexto(sessaoData);
        const duracao = calcularDuracaoSessao(sessaoData);

        // Notificação imediata de criação
        await notificationPersistence.create({
            userId: user.id,
            type: `SESSAO_CRIADA`,
            entityId: sessaoData.sessaoId || sessaoData.id,
            entityType: 'sessao',
            entityData: sessaoData,
            scheduledFor: agora,
            message: `${contextoSessao.emoji} ${contextoSessao.titulo} Organizada!`,
            title: `${contextoSessao.emoji} ${contextoSessao.titulo} Organizada!`,
            body: `${contextoSessao.mensagemCriacao} "${sessaoData.conteudo}" está planejada! 📚\n\n📋 Foco: ${sessaoData.topicos?.join(', ') || 'Tópicos gerais'}\n⏱️ ${duracao}${tempoInicio ? `\n📅 ${tempoInicio.toLocaleDateString('pt-BR')} às ${tempoInicio.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}` : ''}\n\n${contextoSessao.dicaPreparacao}`,
            priority: 'normal'
        });

        // Se há horário programado, criar lembretes
        if (tempoInicio && tempoInicio > agora) {
            const minutosAteInicio = Math.ceil((tempoInicio - agora) / (1000 * 60));

            // Lembrete de preparação (3h antes para sessões longas, 30min para curtas)
            const tempoPreparacao = duracao.includes('h') ? 3 * 60 : 30; // 3h ou 30min em minutos
            if (minutosAteInicio > tempoPreparacao) {
                const lembretePreparacao = new Date(tempoInicio.getTime() - tempoPreparacao * 60 * 1000);
                await notificationPersistence.create({
                    userId: user.id,
                    type: `SESSAO_PREPARACAO`,
                    entityId: sessaoData.sessaoId || sessaoData.id,
                    entityType: 'sessao',
                    entityData: sessaoData,
                    scheduledFor: lembretePreparacao,
                    message: `🎯 ${contextoSessao.emoji} Prepare-se: ${contextoSessao.titulo} se aproxima!`,
                    title: `🎯 ${contextoSessao.emoji} Prepare-se: ${contextoSessao.titulo} se aproxima!`,
                    body: `${contextoSessao.preparacao} "${sessaoData.conteudo}" ${duracao.includes('h') ? 'em 3 horas' : 'em 30 minutos'}! �\n\n📋 Tópicos: ${sessaoData.topicos?.join(', ') || 'Revisão geral'}\n\n💡 ${contextoSessao.dicaPreparacao}`,
                    priority: 'high'
                });
            }

            // Lembrete 15 minutos antes (último aviso)
            if (minutosAteInicio > 15) {
                const quinzeMinutosAntes = new Date(tempoInicio.getTime() - 15 * 60 * 1000);
                await notificationPersistence.create({
                    userId: user.id,
                    type: `SESSAO_ULTIMO_AVISO`,
                    entityId: sessaoData.sessaoId || sessaoData.id,
                    entityType: 'sessao',
                    entityData: sessaoData,
                    scheduledFor: quinzeMinutosAntes,
                    message: `⚡ ${contextoSessao.emoji} ÚLTIMO AVISO: ${contextoSessao.titulo} em 15 min!`,
                    title: `⚡ ${contextoSessao.emoji} ÚLTIMO AVISO: ${contextoSessao.titulo} em 15 min!`,
                    body: `${contextoSessao.ultimoAviso} "${sessaoData.conteudo}" começa em 15 minutos! ⏰\n\n🎯 Prepare-se mentalmente e organize seus materiais.\n\n${contextoSessao.motivacao}`,
                    priority: 'urgent'
                });
            }

            // Lembrete no momento exato da sessão
            await notificationPersistence.create({
                userId: user.id,
                type: `SESSAO_INICIO`,
                entityId: sessaoData.sessaoId || sessaoData.id,
                entityType: 'sessao',
                entityData: sessaoData,
                scheduledFor: tempoInicio,
                message: `🚀 ${contextoSessao.emoji} AGORA: ${contextoSessao.titulo}!`,
                title: `🚀 ${contextoSessao.emoji} AGORA: ${contextoSessao.titulo}!`,
                body: `${contextoSessao.mensagemInicio} "${sessaoData.conteudo}"! 🎯\n\n📚 Foco total em: ${sessaoData.topicos?.join(', ') || 'seus objetivos'}\n⏱️ Duração: ${duracao}\n\n${contextoSessao.motivacao}`,
                priority: 'critical'
            });

            // Se a sessão for longa (>2h), adicionar lembrete de pausa
            if (sessaoData.tempoFim) {
                const fimSessao = new Date(sessaoData.tempoFim);
                const duracaoMs = fimSessao - tempoInicio;
                const duracaoHoras = duracaoMs / (1000 * 60 * 60);

                if (duracaoHoras > 2) {
                    const metadeSessao = new Date(tempoInicio.getTime() + duracaoMs / 2);
                    await notificationPersistence.create({
                        userId: user.id,
                        type: `SESSAO_PAUSA`,
                        entityId: sessaoData.sessaoId || sessaoData.id,
                        entityType: 'sessao',
                        entityData: sessaoData,
                        scheduledFor: metadeSessao,
                        message: `🧘‍♀️ ${contextoSessao.emoji} Hora da Pausa Revigorante!`,
                        title: `🧘‍♀️ ${contextoSessao.emoji} Hora da Pausa Revigorante!`,
                        body: `Você está no meio da sua sessão de ${contextoSessao.titulo.toLowerCase()}! 💪\n\n🎉 Parabéns pelo foco até aqui!\n\n⏸️ Faça uma pausa de 15-20 minutos:\n• Alongue-se 🤸‍♀️\n• Hidrate-se 💧\n• Respire ar puro 🌱\n\n${contextoSessao.dicaPausa}\n\nDepois volte com tudo! 🔥`,
                        priority: 'medium'
                    });
                }
            }
        }

        console.log(`✅ Notificações de sessão criadas para ${sessaoData.conteudo}`);
        channel.ack(msg);
    } catch (error) {
        console.error('Error processing sessao notification:', error);
        channel.nack(msg, false, true);
    }
}

/**
 * Processa notificações de provas criadas
 */
async function processProvaNotificacao(msg, channel) {
    if (!msg) {
        console.error('Received null message for prova notification');
        return;
    }

    try {
        const message = JSON.parse(msg.content.toString());
        console.log('📝 Processing prova notification:', message);

        // A estrutura vem aninhada: message.data.data contém os dados da prova
        const provaData = message.data.data || message.data;

        console.log('🔍 Debug prova - provaData:', provaData);

        // Verificar se o usuário existe
        let user;
        try {
            const userId = provaData.userId || 'user-default';
            if (userId && userId !== 'user-default') {
                console.log('🔍 Buscando usuário por ID:', userId);
                user = await userPersistence.findById(userId);
            } else {
                console.log('🔍 Usando fallback para usuário padrão');
                const defaultUsers = await userPersistence.getAll();
                user = defaultUsers[0];
            }
        } catch (error) {
            console.error(`❌ User not found:`, error.message);
            channel.ack(msg);
            return;
        }

        if (!user) {
            console.error('❌ Nenhum usuário encontrado para criar notificações');
            channel.ack(msg);
            return;
        }

        // Gerar notificações personalizadas baseadas nas regras de negócio
        const agora = new Date();
        const dataProva = new Date(provaData.data || provaData.dataProva);
        const horarioProva = new Date(provaData.horario);
        const diasAteProva = Math.ceil((dataProva - agora) / (1000 * 60 * 60 * 24));

        // Contexto específico para provas
        const contextoProva = {
            emoji: '📝',
            titulo: 'Prova',
            tipo: 'acadêmica',
            mensagemCriacao: 'Sua prova',
            dicaPreparacao: '📚 Organize seus materiais e revise os principais tópicos!',
            preparacao: '🎯 Foque nos pontos principais e pratique exercícios!',
            motivacao: 'Você se preparou bem! Confie em si mesmo! 💪',
            ultimoAviso: 'É hoje! Confie no seu preparo!',
            mensagemInicio: 'Hora de mostrar o que sabe!',
            mensagemDia: 'HOJE é o dia da sua prova!',
            lembreteUrgente: 'Última revisão!'
        };

        // Notificação imediata
        await notificationPersistence.create({
            userId: user.id,
            type: `PROVA_CRIADA`,
            entityId: provaData.provaId || provaData.id,
            entityType: 'prova',
            entityData: provaData,
            scheduledFor: agora,
            message: `${contextoProva.emoji} ${contextoProva.titulo} Criada!`,
            title: `${contextoProva.emoji} ${contextoProva.titulo} Criada!`,
            body: `${contextoProva.mensagemCriacao} "${provaData.titulo}" foi agendada${diasAteProva > 0 ? ` para ${diasAteProva} dias` : ' para hoje'}! 📅\n📍 Local: ${provaData.local}\n⏰ Horário: ${horarioProva.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}`,
            priority: 'normal'
        });

        // Lembrete 1 semana antes (se aplicável)
        if (diasAteProva > 7) {
            const lembrete1Semana = new Date(dataProva.getTime() - 7 * 24 * 60 * 60 * 1000);
            await notificationPersistence.create({
                userId: user.id,
                type: `PROVA_LEMBRETE_1_SEMANA`,
                entityId: provaData.provaId || provaData.id,
                entityType: 'prova',
                entityData: provaData,
                scheduledFor: lembrete1Semana,
                message: `📚 Lembrete: Prova em 1 semana`,
                title: `📚 Lembrete: Prova em 1 semana`,
                body: `A prova "${provaData.titulo}" acontecerá em 1 semana! 📅\nComece a intensificar seus estudos! 💪\n📍 Local: ${provaData.local}\n⏰ Horário: ${horarioProva.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}`,
                priority: 'normal'
            });
        }

        // Lembrete 3 dias antes (se aplicável)
        if (diasAteProva > 3) {
            const lembrete3Dias = new Date(dataProva.getTime() - 3 * 24 * 60 * 60 * 1000);
            await notificationPersistence.create({
                userId: user.id,
                type: `PROVA_LEMBRETE_3_DIAS`,
                entityId: provaData.provaId || provaData.id,
                entityType: 'prova',
                entityData: provaData,
                scheduledFor: lembrete3Dias,
                message: `⏰ Prova em 3 dias - Revisão final!`,
                title: `⏰ Prova em 3 dias - Revisão final!`,
                body: `${contextoProva.lembreteUrgente} A prova "${provaData.titulo}" é em 3 dias! 🎯\nFaça uma revisão geral dos tópicos principais!\n📍 Local: ${provaData.local}\n⏰ Horário: ${horarioProva.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}`,
                priority: 'high'
            });
        }

        // Lembrete 1 dia antes
        if (diasAteProva > 1) {
            const lembrete1Dia = new Date(dataProva.getTime() - 1 * 24 * 60 * 60 * 1000);
            lembrete1Dia.setHours(20, 0, 0, 0); // 20h do dia anterior
            await notificationPersistence.create({
                userId: user.id,
                type: `PROVA_LEMBRETE_1_DIA`,
                entityId: provaData.provaId || provaData.id,
                entityType: 'prova',
                entityData: provaData,
                scheduledFor: lembrete1Dia,
                message: `🔔 AMANHÃ é dia de prova!`,
                title: `🔔 AMANHÃ é dia de prova!`,
                body: `A prova "${provaData.titulo}" é AMANHÃ! 📚\n✅ Separe seus materiais\n✅ Descanse bem\n✅ Confie no seu preparo!\n📍 Local: ${provaData.local}\n⏰ Horário: ${horarioProva.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}`,
                priority: 'high'
            });
        }

        // Lembrete no dia da prova
        if (diasAteProva >= 0) {
            const lembreteHoje = new Date(dataProva);
            lembreteHoje.setHours(7, 0, 0, 0); // 7h da manhã do dia da prova
            await notificationPersistence.create({
                userId: user.id,
                type: `PROVA_DIA`,
                entityId: provaData.provaId || provaData.id,
                entityType: 'prova',
                entityData: provaData,
                scheduledFor: lembreteHoje,
                message: `🎯 HOJE é dia de prova!`,
                title: `🎯 HOJE é dia de prova!`,
                body: `${contextoProva.mensagemDia} "${provaData.titulo}"! 🔥\n\n${contextoProva.motivacao}\n\n📍 ${provaData.local}\n⏰ ${horarioProva.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}\n\n🍀 Boa sorte!`,
                priority: 'critical'
            });
        }

        // Lembrete 1 hora antes da prova
        if (diasAteProva >= 0) {
            const lembrete1Hora = new Date(horarioProva.getTime() - 60 * 60 * 1000);
            await notificationPersistence.create({
                userId: user.id,
                type: `PROVA_1_HORA`,
                entityId: provaData.provaId || provaData.id,
                entityType: 'prova',
                entityData: provaData,
                scheduledFor: lembrete1Hora,
                message: `⏰ Prova em 1 hora!`,
                title: `⏰ Prova em 1 hora!`,
                body: `Sua prova "${provaData.titulo}" começa em 1 hora! ⏰\n\n✅ Verifique seus materiais\n✅ Saia com antecedência\n✅ Mantenha a calma!\n\n📍 ${provaData.local}\n🕐 ${horarioProva.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}`,
                priority: 'critical'
            });
        }

        console.log(`✅ Notificações de prova criadas para ${provaData.titulo}`);
        channel.ack(msg);
    } catch (error) {
        console.error('Error processing prova notification:', error);
        channel.nack(msg, false, true);
    }
}

/**
 * Inicia o consumer para notificações customizadas
 */
export async function startCustomNotificationConsumer() {
    try {
        const channel = await getChannel();

        // Configurar filas simplificadas
        const EVENTO_NOTIFICATION_QUEUE = 'notificacao.evento.criado';
        const SESSAO_NOTIFICATION_QUEUE = 'notificacao.sessao.criada';
        const PROVA_NOTIFICATION_QUEUE = 'notificacao.prova.criada';

        // Declarar filas
        await channel.assertQueue(EVENTO_NOTIFICATION_QUEUE, { durable: true });
        await channel.assertQueue(SESSAO_NOTIFICATION_QUEUE, { durable: true });
        await channel.assertQueue(PROVA_NOTIFICATION_QUEUE, { durable: true });

        // Configurar exchange
        const EXCHANGE = 'pi5_events';
        await channel.assertExchange(EXCHANGE, 'topic', { durable: true });

        // Bind filas ao exchange
        await channel.bindQueue(EVENTO_NOTIFICATION_QUEUE, EXCHANGE, 'notificacao.evento.criado');
        await channel.bindQueue(SESSAO_NOTIFICATION_QUEUE, EXCHANGE, 'notificacao.sessao.criada');
        await channel.bindQueue(PROVA_NOTIFICATION_QUEUE, EXCHANGE, 'notificacao.prova.criada');

        // Configurar consumers
        await channel.consume(EVENTO_NOTIFICATION_QUEUE, (msg) => {
            processEventoNotificacao(msg, channel);
        }, { noAck: false });

        await channel.consume(SESSAO_NOTIFICATION_QUEUE, (msg) => {
            processSessaoNotificacao(msg, channel);
        }, { noAck: false });

        await channel.consume(PROVA_NOTIFICATION_QUEUE, (msg) => {
            processProvaNotificacao(msg, channel);
        }, { noAck: false });

        console.log('🚀 Custom notification consumer started successfully');
        console.log(`📬 Listening for evento notifications on: ${EVENTO_NOTIFICATION_QUEUE}`);
        console.log(`📚 Listening for sessao notifications on: ${SESSAO_NOTIFICATION_QUEUE}`);
        console.log(`📝 Listening for prova notifications on: ${PROVA_NOTIFICATION_QUEUE}`);

    } catch (error) {
        console.error('Error starting custom notification consumer:', error);
        setTimeout(startCustomNotificationConsumer, 10000);
    }
}