const router = require('express').Router();
const controller = require('../controllers/taskShareController');
const { authenticate } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/permissionMiddleware');

router.use(authenticate);
router.get('/:id/shares', requireRole('owner', 'editor', 'viewer'), controller.list);
router.post('/:id/shares', requireRole('owner'), controller.create);
router.patch('/:id/shares/:userId', requireRole('owner'), controller.update);
router.delete('/:id/shares/:userId', requireRole('owner'), controller.remove);

module.exports = router;
