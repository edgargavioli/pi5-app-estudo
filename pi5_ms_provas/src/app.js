import express from "express";
import compression from "compression";
import morgan from "morgan";
import helmet from "helmet";
import cors from "cors";
import dotenv from "dotenv";
import promMid from "express-prometheus-middleware";
import swaggerUi from "swagger-ui-express";
import { readFileSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

import routes from "./presentation/routes/routes.js";

dotenv.config();

// Configurar __dirname no ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Carregar swagger.json
const swaggerFile = JSON.parse(
  readFileSync(join(__dirname, "./config/swagger.json"), "utf8")
);

const app = express();

app.use(cors());
app.use(helmet());
app.use(compression());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan("dev"));
app.use(promMid({
    metricsPath: "/metrics",
    collectDefaultMetrics: true,
    requestDurationBuckets: [0.1, 0.5, 1, 1.5],
    requestLengthBuckets: [515, 1024, 5120, 10240],
    responseLengthBuckets: [515, 1024, 5120, 10240],
}));
app.use("/swagger", swaggerUi.serve, swaggerUi.setup(swaggerFile));
app.use(routes);

export { app };
