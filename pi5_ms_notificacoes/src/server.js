import http from "node:http";
import app from "./app.js";
import { startAllConsumers } from "./aplication/consumer/notification-consumer.js";

const error = (err) => {
    console.error(`Erro ao iniciar servidor\n ${err.message}`);
    throw err;
};

const listening = () => {
    console.log(`Servidor rodando na porta ${process.env.PORT}`);
    
    // Inicia os consumers após o servidor estar rodando
    startAllConsumers();
};

const server = http.createServer(app);
server.listen(process.env.PORT || 4040);
server.on("error", error);
server.on("listening", listening);