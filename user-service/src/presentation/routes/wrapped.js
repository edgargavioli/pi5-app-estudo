const express = require('express');
const router = express.Router();
const wrappedController = require('../controllers/WrappedController');
const { authMiddleware } = require('../../middleware/auth');
const { apiLimiter } = require('../../middleware/rateLimiter');

/**
 * @swagger
 * /api/wrapped/{id}:
 *   get:
 *     summary: Get wrapped user data (aggregated view)
 *     tags: [Wrapped]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: User ID
 *     responses:
 *       200:
 *         description: Wrapped user data retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 user:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: string
 *                     email:
 *                       type: string
 *                     name:
 *                       type: string
 *                     totalPoints:
 *                       type: integer
 *                     achievementsCount:
 *                       type: integer
 *                     totalTransactions:
 *                       type: integer
 *                 achievements:
 *                   type: array
 *                   items:
 *                     type: object
 *                 pointsTransactions:
 *                   type: object
 *                 stats:
 *                   type: object
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: User not found
 */
router.get('/:id', authMiddleware, wrappedController.getUserWrapped);

/**
 * @swagger
 * /api/wrapped/{id}/achievements:
 *   get:
 *     summary: Get user achievements
 *     tags: [Wrapped]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: User ID
 *     responses:
 *       200:
 *         description: User achievements retrieved successfully
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: User not found
 */
router.get('/:id/achievements', authMiddleware, wrappedController.getUserAchievements);

/**
 * @swagger
 * /api/wrapped/{id}/points-history:
 *   get:
 *     summary: Get user points history
 *     tags: [Wrapped]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: User ID
 *     responses:
 *       200:
 *         description: User points history retrieved successfully
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: User not found
 */
router.get('/:id/points-history', authMiddleware, wrappedController.getUserPointsHistory);

/**
 * @swagger
 * /api/wrapped/{id}/html:
 *   get:
 *     summary: Get wrapped as styled HTML page
 *     tags: [Wrapped]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: User ID
 *     responses:
 *       200:
 *         description: Wrapped HTML page
 *         content:
 *           text/html:
 *             schema:
 *               type: string
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: User not found
 */
router.get('/:id/html', authMiddleware, wrappedController.getWrappedHTML);

/**
 * @swagger
 * /api/wrapped/{id}/summary:
 *   get:
 *     summary: Generate wrapped summary (JSON format - image generation disabled)
 *     tags: [Wrapped]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: User ID
 *     responses:
 *       200:
 *         description: Generated wrapped summary data
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 type:
 *                   type: string
 *                 user:
 *                   type: object
 *                 statistics:
 *                   type: object
 *                 message:
 *                   type: string
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: User not found
 */
router.get('/:id/summary', authMiddleware, apiLimiter, wrappedController.getWrappedImage);

module.exports = router; 