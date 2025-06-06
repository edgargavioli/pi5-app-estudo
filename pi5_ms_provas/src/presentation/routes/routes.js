import { Router } from "express";

import order from "../middlewares/order.js";
import hateoas from "../middlewares/hateoas.js";
import handler from "../middlewares/handler.js";
import { authMiddleware, optionalAuthMiddleware } from "../../middleware/auth.js";

import materiaRoutes from "./materiaRoutes.js";
import provaRoutes from "./provaRoutes.js";
import sessaoRoutes from "./sessaoRoutes.js";
import eventoRoutes from "./eventoRoutes.js";

import InternalServerError from "./helper/500.js";
import NotFound from "./helper/404.js";

const routes = Router();

routes.use(order);
routes.use(hateoas);
routes.use(handler);

// 🔒 Middleware JWT aplicado a TODAS as rotas protegidas
routes.use("/materias", authMiddleware, materiaRoutes);
routes.use("/provas", authMiddleware, provaRoutes);
routes.use("/sessoes", authMiddleware, sessaoRoutes);
routes.use("/eventos", authMiddleware, eventoRoutes);

// 📖 Rota pública para health check (sem autenticação)
routes.get("/health", (req, res) => {
  res.json({
    status: "ok",
    service: "pi5-ms-provas",
    timestamp: new Date().toISOString(),
    authentication: "JWT validation enabled"
  });
});

// 📖 Rota pública para documentação (sem autenticação)
routes.get("/", (req, res) => {
  res.json({
    message: "PI5 MS Provas - Microserviço de Provas e Sessões",
    version: "1.0.0",
    authentication: "JWT tokens obrigatórios",
    userService: process.env.USER_SERVICE_URL,
    documentation: "/swagger",
    endpoints: {
      materias: "/materias",
      provas: "/provas", 
      sessoes: "/sessoes"
    }
  });
});

routes.use(InternalServerError);
routes.use(NotFound);

export default routes;
