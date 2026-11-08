const taskController = require('./taskController');

module.exports = {
  list: taskController.shares,
  create: taskController.share,
  update: taskController.updateShare,
  remove: taskController.unshare,
};
