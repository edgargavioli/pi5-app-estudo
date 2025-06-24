import { Router } from 'express';
import { SessaoEstudoController } from '../controllers/SessaoEstudoController.js';

const router = Router();
const sessaoEstudoController = new SessaoEstudoController();

router.post('/', sessaoEstudoController.create);
router.get('/', sessaoEstudoController.getAll);
router.get('/agendadas', sessaoEstudoController.getAgendadas);
router.get('/estatisticas', sessaoEstudoController.getEstatisticas);
router.get('/:id', sessaoEstudoController.getById);
router.put('/:id', sessaoEstudoController.update);
router.delete('/:id', sessaoEstudoController.delete);

export default router;