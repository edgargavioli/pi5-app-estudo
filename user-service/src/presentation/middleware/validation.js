const Joi = require('joi');

const schemas = {
  register: Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().min(6).required(),
    name: Joi.string().required()
  }),

  login: Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().required()
  }),

  googleAuth: Joi.object({
    token: Joi.string().required()
  }),

  forgotPassword: Joi.object({
    email: Joi.string().email().required()
  }),

  resetPassword: Joi.object({
    token: Joi.string().required(),
    password: Joi.string().min(6).required()
  })
};

const validateRequest = (schemaOrKey) => {
  return (req, res, next) => {
    let schema = schemaOrKey;
    if (typeof schemaOrKey === 'string') {
      schema = schemas[schemaOrKey];
    }
    if (!schema) {
      return res.status(400).json({
        status: 'error',
        message: `Validation schema not found`
      });
    }
    const { error } = schema.validate(req.body);
    if (error) {
      return res.status(400).json({
        status: 'error',
        message: error.details[0].message
      });
    }
    next();
  };
};

module.exports = {
  validateRequest
}; 