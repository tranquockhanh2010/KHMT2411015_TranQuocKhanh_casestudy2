const taskController = require('./taskController');

module.exports = {
  list: taskController.shares,
  assign: taskController.share,
  update: taskController.updateShare,
  remove: taskController.unshare,
};
