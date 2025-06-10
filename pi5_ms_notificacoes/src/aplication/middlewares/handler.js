import httpStatus from "http-status";

export default (_, res, next) => {
  res.ok = (data) => res
    .status(httpStatus.OK)
    .json(data);

  res.created = () => res
    .status(httpStatus.CREATED)
    .send();

  res.no_content = () => res
    .status(httpStatus.NO_CONTENT)
    .send();

  res.internal_server_error = (data) => {
    /*
    #swagger.responses[500] = {
      schema: { $ref: "#/definitions/InternalServerError" }
    }
    */
    res
      .status(httpStatus.INTERNAL_SERVER_ERROR)
      .json(data);
  }

  res.unauthorized = () => res
    .status(httpStatus.UNAUTHORIZED)
    .send();

  res.forbidden = () => res
    .status(httpStatus.FORBIDDEN)
    .send();

  next();
}
