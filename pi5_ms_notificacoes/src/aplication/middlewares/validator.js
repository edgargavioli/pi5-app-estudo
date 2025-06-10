import httpStatus from "http-status";

const config = {
  abortEarly: false,
  recursive: true,
};

export default (schema) => (req, res, next) => {
  try {
    schema.validateSync(req.body, config);
    next();
  } catch (err) {
    const { message, errors } = err;

    res
    .status(httpStatus.PAYMENT_REQUIRED)
    .send({
      message,
      errors,
    });
  }
}
