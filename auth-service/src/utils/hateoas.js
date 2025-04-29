const BASE_URL = process.env.BASE_URL || 'http://localhost:3000/api/auth';

/**
 * Gera links HATEOAS para um recurso
 * @param {string} resource - Nome do recurso
 * @param {string} id - ID do recurso (opcional)
 * @returns {Object} Links HATEOAS
 */
const generateResourceLinks = (resource, id = null) => {
  const basePath = `${BASE_URL}/${resource}`;
  const resourcePath = id ? `${basePath}/${id}` : basePath;

  return {
    self: { href: resourcePath },
    collection: { href: basePath }
  };
};

/**
 * Gera links HATEOAS para operações de autenticação
 * @returns {Object} Links HATEOAS
 */
const generateAuthLinks = () => {
  return {
    login: { href: `${BASE_URL}/login`, method: 'POST' },
    register: { href: `${BASE_URL}/register`, method: 'POST' },
    refreshToken: { href: `${BASE_URL}/refresh-token`, method: 'POST' },
    recoverPassword: { href: `${BASE_URL}/recover-password`, method: 'POST' },
    verifyEmail: { href: `${BASE_URL}/verify-email`, method: 'GET' }
  };
};

/**
 * Gera links HATEOAS para operações de usuário autenticado
 * @param {string} userId - ID do usuário
 * @returns {Object} Links HATEOAS
 */
const generateUserLinks = (userId) => {
  return {
    self: { href: `${BASE_URL}/users/${userId}`, method: 'GET' },
    changePassword: { href: `${BASE_URL}/change-password`, method: 'PUT' },
    logout: { href: `${BASE_URL}/logout`, method: 'POST' }
  };
};

/**
 * Gera links HATEOAS para operações de administrador
 * @param {string} userId - ID do usuário alvo
 * @returns {Object} Links HATEOAS
 */
const generateAdminLinks = (userId) => {
  return {
    blockAccount: { 
      href: `${BASE_URL}/block-account`, 
      method: 'PUT',
      body: { userId }
    },
    unblockAccount: { 
      href: `${BASE_URL}/unblock-account`, 
      method: 'PUT',
      body: { userId }
    }
  };
};

module.exports = {
  generateResourceLinks,
  generateAuthLinks,
  generateUserLinks,
  generateAdminLinks
}; 