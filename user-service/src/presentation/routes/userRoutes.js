const express = require('express');
const userController = require('../controllers/UserController');
const StreakController = require('../controllers/StreakController');
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

/**
 * @swagger
 * /api/users/{id}/fcm-token:
 *   patch:
 *     summary: Update user FCM token for push notifications
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
 *             type: object
 *             required:
 *               - fcmToken
 *             properties:
 *               fcmToken:
 *                 type: string
 *                 description: Firebase Cloud Messaging token for push notifications
 *                 example: "foHKBFb7RoyIMBiRrmZp5X:APA91bGhMUSZbfsHMiqXX7ECYYSTVpmxnn3D2crjtE4OjT4qdgahxfKkuWZJBU74KWdvUxOP_BcfzHZb2-9q7EVWNVyWzwb8S37gLTB9n17r4EbRFgGXJNA"
 *     responses:
 *       200:
 *         description: FCM token updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               allOf:
 *                 - $ref: '#/components/schemas/HATEOASResponse'
 *                 - type: object
 *                   properties:
 *                     message:
 *                       type: string
 *                       example: "FCM token updated successfully"
 *                     data:
 *                       type: object
 *                       properties:
 *                         fcmToken:
 *                           type: string
 *                           description: Updated FCM token
 *       400:
 *         description: Bad request - invalid FCM token format
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "fail"
 *                 message:
 *                   type: string
 *                   example: "FCM token is required and must be a valid string"
 *       401:
 *         description: Unauthorized - invalid or missing JWT token
 *       403:
 *         description: Forbidden - can only update own FCM token
 *       404:
 *         description: User not found
 *       500:
 *         description: Internal server error
 */
router.patch('/:id/fcm-token', authMiddleware, userRateLimit, userController.updateFcmToken);

/**
 * @swagger
 * /api/users/{id}/points:
 *   post:
 *     summary: Add points to user
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
 *             type: object
 *             required:
 *               - points
 *               - reason
 *             properties:
 *               points:
 *                 type: integer
 *                 minimum: 1
 *                 description: Number of points to add
 *                 example: 50
 *               reason:
 *                 type: string
 *                 description: Reason for adding points
 *                 example: "Sessão de estudo concluída"
 *               type:
 *                 type: string
 *                 enum: [ADD, REMOVE]
 *                 default: ADD
 *                 description: Type of transaction
 *     responses:
 *       200:
 *         description: Points added successfully
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
 *                       example: "Successfully added 50 points"
 *       400:
 *         description: Bad request - invalid points or reason
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - can only add points to own account
 *       404:
 *         description: User not found
 */
router.post('/:id/points', authMiddleware, userRateLimit, userController.addPoints);

/**
 * @swagger
 * /users/gamification/sessao:
 *   post:
 *     summary: Processar XP de finalização de sessão de estudo
 *     tags: [Gamificação]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - tempoEstudoMinutos
 *             properties:
 *               tempoEstudoMinutos:
 *                 type: number
 *                 description: Tempo de estudo em minutos
 *               isAgendada:
 *                 type: boolean
 *                 description: Se a sessão é agendada
 *               metaTempo:
 *                 type: number
 *                 description: Meta de tempo em minutos
 *               cumpriuPrazo:
 *                 type: boolean
 *                 description: Se cumpriu o prazo agendado
 *               questoesAcertadas:
 *                 type: number
 *                 description: Número de questões acertadas
 *               totalQuestoes:
 *                 type: number
 *                 description: Total de questões respondidas
 *               sessionId:
 *                 type: string
 *                 description: ID da sessão para referência
 *     responses:
 *       200:
 *         description: XP processado com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 usuario:
 *                   $ref: '#/components/schemas/User'
 *                 xpAdicionado:
 *                   type: number
 *                 pontosTotal:
 *                   type: number
 *                 level:
 *                   type: number
 *                 subiumLevel:
 *                   type: boolean
 *                 detalhamentoXp:
 *                   type: object
 *                   properties:
 *                     xpBase:
 *                       type: number
 *                     xpTempo:
 *                       type: number
 *                     xpQuestoes:
 *                       type: number
 *                     multiplicador:
 *                       type: number
 *                     bonus:
 *                       type: number
 *                     detalhes:
 *                       type: array
 *                       items:
 *                         type: string
 *       400:
 *         description: Dados inválidos
 *       401:
 *         description: Não autorizado
 *       500:
 *         description: Erro interno do servidor */
router.post('/gamification/sessao', authMiddleware, userController.processarXpSessao);

// ==================== STREAK ROUTES ====================

/**
 * @swagger
 * /api/users/{id}/streak:
 *   get:
 *     summary: Obter informações da sequência de estudos do usuário
 *     tags: [Streaks]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: ID do usuário
 *     responses:
 *       200:
 *         description: Informações da sequência obtidas com sucesso
 *       401:
 *         description: Não autorizado
 *       404:
 *         description: Usuário não encontrado
 */
router.get('/:id/streak', authMiddleware, userRateLimit, StreakController.getStreak);

/**
 * @swagger
 * /api/users/{id}/streak:
 *   put:
 *     summary: Atualizar sequência de estudos (adicionar tempo estudado)
 *     tags: [Streaks]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: ID do usuário
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               studyMinutes:
 *                 type: integer
 *                 description: Minutos de estudo para adicionar
 *                 minimum: 1
 *               timezone:
 *                 type: string
 *                 description: Fuso horário do usuário
 *                 default: "America/Sao_Paulo"
 *             required:
 *               - studyMinutes
 *     responses:
 *       200:
 *         description: Sequência atualizada com sucesso
 *       400:
 *         description: Dados inválidos
 *       401:
 *         description: Não autorizado
 *       404:
 *         description: Usuário não encontrado
 */
router.put('/:id/streak', authMiddleware, userRateLimit, StreakController.updateStreak);

/**
 * @swagger
 * /api/users/{id}/streak/achievements:
 *   get:
 *     summary: Obter conquistas de sequência do usuário
 *     tags: [Streaks]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: ID do usuário
 *     responses:
 *       200:
 *         description: Conquistas obtidas com sucesso
 *       401:
 *         description: Não autorizado
 *       404:
 *         description: Usuário não encontrado
 */
router.get('/:id/streak/achievements', authMiddleware, userRateLimit, StreakController.getAchievements);

module.exports = router;