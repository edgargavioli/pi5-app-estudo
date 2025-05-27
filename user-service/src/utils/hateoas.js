/**
 * Creates HATEOAS links for API responses
 * @param {Object} req - Express request object
 * @param {Object} links - Object containing link definitions
 * @returns {Object} Object containing HATEOAS links
 */
const createHateoasLinks = (req, links) => {
  const baseUrl = `${req.protocol}://${req.get('host')}`;
  const result = {};

  for (const [rel, link] of Object.entries(links)) {
    result[rel] = {
      href: `${baseUrl}${link.href}`,
      method: link.method || 'GET'
    };
  }

  return result;
};

/**
 * Creates pagination links for list endpoints
 * @param {Object} req - Express request object
 * @param {number} totalPages - Total number of pages
 * @param {number} currentPage - Current page number
 * @returns {Object} Object containing pagination links
 */
const createPaginationLinks = (req, totalPages, currentPage) => {
  const baseUrl = `${req.protocol}://${req.get('host')}${req.path}`;
  const query = new URLSearchParams(req.query);
  
  const links = {
    self: {
      href: `${baseUrl}?${query.toString()}`
    }
  };

  if (currentPage > 1) {
    query.set('page', currentPage - 1);
    links.prev = {
      href: `${baseUrl}?${query.toString()}`
    };
  }

  if (currentPage < totalPages) {
    query.set('page', currentPage + 1);
    links.next = {
      href: `${baseUrl}?${query.toString()}`
    };
  }

  return links;
};

module.exports = {
  createHateoasLinks,
  createPaginationLinks
}; 