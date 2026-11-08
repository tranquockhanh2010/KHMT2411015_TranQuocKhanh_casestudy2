const router = require('express').Router();
const { authenticate } = require('../middleware/authMiddleware');
const { list } = require('../controllers/emailLogController');
router.use(authenticate);
router.get('/', list);
module.exports = router;
