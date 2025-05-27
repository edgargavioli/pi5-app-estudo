const express = require('express');
const router = express.Router();
const userController = require('../controllers/UserController');
const { authenticate } = require('../middleware/auth');
const { validateRequest, schemas } = require('../middleware/validation');
const { apiLimiter } = require('../middleware/rateLimiter');

// User Management Routes
router.post('/', apiLimiter, validateRequest(schemas.createUser), userController.create);
router.get('/:id', authenticate, userController.getUserById);
router.put('/:id', authenticate, validateRequest(schemas.updateUser), userController.updateUser);
router.delete('/:id', authenticate, userController.deleteUser);

// User Profile Routes
router.get('/:id/profile', authenticate, userController.getProfile);
router.put('/:id/profile', authenticate, validateRequest(schemas.updateProfile), userController.updateProfile);

module.exports = router; 