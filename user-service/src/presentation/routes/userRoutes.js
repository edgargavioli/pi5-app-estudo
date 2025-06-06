const express = require('express');
const userController = require('../controllers/UserController');
const { authMiddleware } = require('../../middleware/auth');
const { validateRequest, schemas } = require('../../middleware/validation');
const { userRateLimit } = require('../../middleware/rateLimiter');

const router = express.Router();

/**
 * @swagger
 * components:
 *   schemas:
 *     User:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *           description: The user's unique identifier
 *         email:
 *           type: string
 *           format: email
 *           description: The user's email address
 *         name:
 *           type: string
 *           description: The user's full name
 *         points:
 *           type: integer
 *           description: The user's points balance
 *         isEmailVerified:
 *           type: boolean
 *           description: Whether the user's email is verified
 *         lastLogin:
 *           type: string
 *           format: date-time
 *           description: The user's last login timestamp
 *     UserUpdate:
 *       type: object
 *       properties:
 *         email:
 *           type: string
 *           format: email
 *           description: New email address
 *         name:
 *           type: string
 *           description: New name
 *         password:
 *           type: string
 *           minLength: 8
 *           description: New password
 *     ProfileImage:
 *       type: object
 *       properties:
 *         imageBase64:
 *           type: string
 *           description: Base64 encoded image data
 *       required:
 *         - imageBase64
 *     HATEOASResponse:
 *       type: object
 *       properties:
 *         data:
 *           type: object
 *         _links:
 *           type: object
 *           description: HATEOAS navigation links
 *   tags:
 *     - name: Users
 *       description: User management endpoints
 */

/**
 * @swagger
 * /api/users/{id}:
 *   get:
 *     summary: Get user profile
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: User ID
 *     responses:
 *       200:
 *         description: User profile retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               allOf:
 *                 - $ref: '#/components/schemas/HATEOASResponse'
 *                 - type: object
 *                   properties:
 *                     data:
 *                       $ref: '#/components/schemas/User'
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - can only access own profile
 *       404:
 *         description: User not found
 */
router.get('/:id', authMiddleware, userRateLimit, userController.getUser);

/**
 * @swagger
 * /api/users/{id}:
 *   put:
 *     summary: Update user profile
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: User ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/UserUpdate'
 *     responses:
 *       200:
 *         description: User updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               allOf:
 *                 - $ref: '#/components/schemas/HATEOASResponse'
 *                 - type: object
 *                   properties:
 *                     data:
 *                       $ref: '#/components/schemas/User'
 *                     message:
 *                       type: string
 *       400:
 *         description: Bad request - validation error
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - can only update own profile
 *       404:
 *         description: User not found
 */
router.put('/:id', authMiddleware, validateRequest(schemas.updateProfile), userRateLimit, userController.updateUser);

/**
 * @swagger
 * /api/users/{id}:
 *   delete:
 *     summary: Delete user account
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: User ID
 *     responses:
 *       200:
 *         description: User deleted successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 _links:
 *                   type: object
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - can only delete own account
 *       404:
 *         description: User not found
 */
router.delete('/:id', authMiddleware, userRateLimit, userController.deleteUser);

/**
 * @swagger
 * /api/users/{id}/image:
 *   post:
 *     summary: Upload/update profile image
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: User ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ProfileImage'
 *     responses:
 *       200:
 *         description: Profile image updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               allOf:
 *                 - $ref: '#/components/schemas/HATEOASResponse'
 *                 - type: object
 *                   properties:
 *                     message:
 *                       type: string
 *       400:
 *         description: Bad request - invalid image format
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - can only update own image
 *       404:
 *         description: User not found
 */
router.post('/:id/image', authMiddleware, userRateLimit, userController.updateProfileImage);

/**
 * @swagger
 * /api/users/{id}/image:
 *   get:
 *     summary: Get user profile image
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: User ID
 *     responses:
 *       200:
 *         description: Profile image retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               allOf:
 *                 - $ref: '#/components/schemas/HATEOASResponse'
 *                 - type: object
 *                   properties:
 *                     data:
 *                       $ref: '#/components/schemas/ProfileImage'
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - can only access own image
 *       404:
 *         description: User or image not found
 */
router.get('/:id/image', authMiddleware, userRateLimit, userController.getProfileImage);

module.exports = router; 