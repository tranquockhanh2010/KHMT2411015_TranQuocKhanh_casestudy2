const router = require('express').Router();
const controller = require('../controllers/statisticsController');
const { authenticate } = require('../middleware/authMiddleware');

router.use(authenticate);
router.get('/tasks', controller.tasks);
router.get('/assignments', controller.assignments);
router.get('/deadlines', controller.deadlines);
router.get('/', controller.tasks);

module.exports = router;
