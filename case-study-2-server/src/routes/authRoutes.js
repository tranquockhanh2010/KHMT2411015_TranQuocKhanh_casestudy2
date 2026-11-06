const router = require('express').Router();
const c = require('../controllers/authController');
const { authenticate } = require('../middleware/authMiddleware');
router.post('/register', c.register); router.post('/login', c.login);
router.get('/me', authenticate, c.me); router.patch('/profile', authenticate, c.updateProfile); router.patch('/change-password', authenticate, c.changePassword);
module.exports = router;
