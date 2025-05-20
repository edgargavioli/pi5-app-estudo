import { Router } from "express";

import order from "../middlewares/order.js";
import hateoas from "../middlewares/hateoas.js";
import handler from "../middlewares/handler.js";

import InternalServerError from "./helper/500.js";
import NotFound from "./helper/404.js";

const routes = Router();
routes.use(order);
routes.use(hateoas);
routes.use(handler);

routes.use(InternalServerError);
routes.use(NotFound);

export default routes;
