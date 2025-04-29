const jwt = require('jsonwebtoken');
require('dotenv').config();

/**
 * Gera um token de acesso JWT
 * @param {Object} payload - Dados a serem armazenados no token
 * @returns {string} - Token JWT gerado
 */
const generateAccessToken = (payload) => {
  return jwt.sign(
    payload,
    process.env.ACCESS_TOKEN_SECRET,
    { expiresIn: process.env.ACCESS_TOKEN_EXPIRY || '15m' }
  );
};

/**
 * Gera um token de refresh JWT
 * @param {Object} payload - Dados a serem armazenados no token
 * @returns {string} - Token JWT gerado
 */
const generateRefreshToken = (payload) => {
  return jwt.sign(
    payload,
    process.env.REFRESH_TOKEN_SECRET,
    { expiresIn: process.env.REFRESH_TOKEN_EXPIRY || '7d' }
  );
};

/**
 * Verifica se um token de acesso é válido
 * @param {string} token - Token a ser verificado
 * @returns {Object|null} - Payload do token ou null se inválido
 */
const verifyAccessToken = (token) => {
  try {
    return jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
  } catch (error) {
    return null;
  }
};

/**
 * Verifica se um token de refresh é válido
 * @param {string} token - Token a ser verificado
 * @returns {Object|null} - Payload do token ou null se inválido
 */
const verifyRefreshToken = (token) => {
  try {
    return jwt.verify(token, process.env.REFRESH_TOKEN_SECRET);
  } catch (error) {
    return null;
  }
};

/**
 * Gera novo token de acesso a partir de um token de refresh válido
 * @param {string} refreshToken - Token de refresh
 * @returns {string|null} - Novo token de acesso ou null se refresh token inválido
 */
const refreshAccessToken = (refreshToken) => {
  const payload = verifyRefreshToken(refreshToken);
  if (!payload) return null;
  
  // Remover dados desnecessários para o novo token
  const { iat, exp, ...userData } = payload;
  return generateAccessToken(userData);
};

module.exports = {
  generateAccessToken,
  generateRefreshToken,
  verifyAccessToken,
  verifyRefreshToken,
  refreshAccessToken
}; 