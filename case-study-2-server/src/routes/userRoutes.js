const router = require('express').Router();
const controller = require('../controllers/userController');
const { authenticate } = require('../middleware/authMiddleware');

router.use(authenticate);
router.get('/search', controller.search);
router.get('/me', controller.me);
router.patch('/me', controller.updateProfile);
router.patch('/password', controller.changePassword);
router.get('/:id', controller.getById);

module.exports = router;
