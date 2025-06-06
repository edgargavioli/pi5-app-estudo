import { Router } from 'express';
import materiaRoutes from './materiaRoutes.js';
import provaRoutes from './provaRoutes.js';
import sessaoEstudoRoutes from './sessaoEstudoRoutes.js';

const router = Router();

router.use('/materias', materiaRoutes);
router.use('/provas', provaRoutes);
router.use('/sessoes-estudo', sessaoEstudoRoutes);

export default router; 