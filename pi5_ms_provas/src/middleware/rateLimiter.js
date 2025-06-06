const rateLimit = require('express-rate-limit');

const userRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100, // limite de 100 requisições por IP
  message: 'Muitas requisições deste IP, tente novamente mais tarde.'
});

module.exports = {
  userRateLimit
}; 