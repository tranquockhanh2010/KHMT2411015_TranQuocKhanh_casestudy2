const router = require('express').Router();
const controller = require('../controllers/assignmentController');
const { authenticate } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/permissionMiddleware');

router.use(authenticate);
router.get('/:id/assignees', requireRole('owner', 'editor', 'viewer'), controller.list);
router.post('/:id/assignees', requireRole('owner'), controller.assign);
router.patch('/:id/assignees/:userId', requireRole('owner'), controller.update);
router.delete('/:id/assignees/:userId', requireRole('owner'), controller.remove);

module.exports = router;
