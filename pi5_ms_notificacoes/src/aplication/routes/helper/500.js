import httpStatus from "http-status";

export default (err, req, res, next) => {
  const { code, message } = err;

  if (message) {
    console.error(message);
  }

  res.internal_server_error({
    code,
    message,
  });
};
