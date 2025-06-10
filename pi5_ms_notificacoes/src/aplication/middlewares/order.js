export default (req, _, next) => {
  // #swagger.ignore = true
  if (!!req.query._order) {
    const [field, direction = "asc"] = req.query._order.split(" ");

    req.query._order = {
      [field]: direction,
    };
  }

  next();
}
