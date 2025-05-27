const createHateoasLinks = (req, resource, links = {}) => {
  const baseUrl = `${req.protocol}://${req.get('host')}`;
  const defaultLinks = {
    self: {
      href: `${baseUrl}${req.originalUrl}`,
      method: req.method
    }
  };

  return {
    ...resource,
    _links: {
      ...defaultLinks,
      ...links
    }
  };
};

module.exports = { createHateoasLinks }; 