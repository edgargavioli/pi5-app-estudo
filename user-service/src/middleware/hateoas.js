/**
 * Middleware to add HATEOAS links to responses
 */
const addHateoasLinks = (req, res, next) => {
  const originalJson = res.json;
  
  res.json = function(data) {
    const baseUrl = `${req.protocol}://${req.get('host')}`;
    const links = {
      self: {
        href: `${baseUrl}${req.originalUrl}`
      }
    };

    // Add links based on the resource type and available actions
    if (data.data && data.data.user) {
      links.user = {
        href: `${baseUrl}/api/users/${data.data.user.id}`
      };
      links.wrapped = {
        href: `${baseUrl}/api/wrapped/${data.data.user.id}`
      };
    }

    // Add links to the response
    const response = {
      ...data,
      _links: links
    };

    return originalJson.call(this, response);
  };

  next();
};

module.exports = {
  addHateoasLinks
}; 