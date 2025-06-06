export const whitelist = (req, res, next) => {
  const WHITELIST = process.env.WHITELIST.split(",");
  const clientIp = req.ip || req.connection.remoteAddress;

  if (!WHITELIST.includes(clientIp)) {
    return res.forbidden();
  }

  next();
}
