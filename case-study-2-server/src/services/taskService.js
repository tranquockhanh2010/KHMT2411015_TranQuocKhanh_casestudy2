const ActivityLog = require('../models/TaskActivity');
async function logActivity(task, user, action, details) {
  return ActivityLog.create({ task: task._id || task, user: user._id || user, action, details });
}
module.exports = { logActivity };
