const express = require('express');
const router = express.Router();
const { authenticate } = require('../../infrastructure/middlewares/auth');
const {
  getAllUsers,
  getUserById,
  updateUser,
  deleteUser
} = require('./UserController');

// All routes are protected with authentication
router.use(authenticate);

router.get('/', getAllUsers);
router.get('/:id', getUserById);
router.put('/:id', updateUser);
router.delete('/:id', deleteUser);

module.exports = router; 