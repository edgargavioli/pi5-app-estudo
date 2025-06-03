const express = require('express');
const router = express.Router();
const wrappedController = require('../controllers/WrappedController');
const { authMiddleware } = require('../../middleware/auth');
const multer = require('multer');
const { apiLimiter } = require('../../middleware/rateLimiter');

// Configure multer for memory storage and image filtering
const upload = multer({
  storage: multer.memoryStorage(),
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only images are allowed.'), false);
    }
  }
});

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
 * /api/wrapped/{id}/image:
 *   post:
 *     summary: Generate wrapped image with custom background
 *     tags: [Wrapped]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               background:
 *                 type: string
 *                 format: binary
 *             required:
 *               - background
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: User ID
 *     responses:
 *       200:
 *         description: Generated wrapped image (PNG)
 *         content:
 *           image/png:
 *             schema:
 *               type: string
 *               format: binary
 *       400:
 *         description: Invalid file type or missing file
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 *       404:
 *         description: User not found
 */
router.post('/:id/image', authMiddleware, apiLimiter, upload.single('background'), wrappedController.getWrappedImage);

module.exports = router; 