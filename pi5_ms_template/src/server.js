import http from "node:http";
import app from "./app.js"

const error = (err) => {
    console.error(`An error has occurred on start server\n ${err.message}`);
    throw err;
};

const listening = () => {
    console.log(`Server running on port ${process.env.PORT}`);
};

const server = http.createServer(app);
server.listen(process.env.PORT || 4040);
server.on("error", error);
server.on("listening", listening);