export default (req, res, next) => {
  // #swagger.ignore = true
  res.hateos_item = (data) => {
    return {
      ...data,
      _links: [
        { rel: "self", href: req.originalUrl, method: req.method },
        { rel: "list", href: req.baseUrl, method: "GET" },
        { rel: "update", href: `${req.baseUrl}/${req.params.id}`, method: "PUT" },
        { rel: "delete", href: `${req.baseUrl}/${req.params.id}`, method: "DELETE" },
      ],
    }
  }

  res.hateos_list = (name, data, totalPages) => {
    // #swagger.ignore = true
    const page = parseInt(req.query._page) || 1;

    return {
      [name]: data.map((item) => ({
        ...item,
        _links: [
          { rel: "self", href: `${req.baseUrl}/${item.id}`, method: "GET" },
        ],
      })),
      _page: {
        current: page,
        total: totalPages,
        size: data.length,
      },
      _links: [
        { rel: "self", href: req.baseUrl, method: "GET" },
        { rel: "create", href: req.baseUrl, method: "POST" },
        { rel: "previous", href: page > 1 ? `${req.baseurl}?_page=${page - 1}` : null, method: "GET" },
        { rel: "next", href: page < totalPages ? `${req.baseurl}?_page=${page + 1}` : null, method: "GET" },
      ],
    }
  }

  next();
}
