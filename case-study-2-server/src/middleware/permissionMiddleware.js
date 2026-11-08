const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');

async function getAccess(taskId, userId) {
  const task = await Task.findById(taskId);
  if (!task) return { task: null, role: null };
  if (task.owner.toString() === userId.toString()) {
    return { task, role: 'owner' };
  }

  const share = await TaskShare.findOne({ task: taskId, user: userId });
  return { task, role: share ? share.role : null };
}

function requireRole(...roles) {
  return async (req, res, next) => {
    try {
      const access = await getAccess(
        req.params.id || req.params.taskId,
        req.user._id,
      );
      if (!access.task) {
        return res.status(404).json({ message: 'Task not found' });
      }
      if (!roles.includes(access.role)) {
        return res.status(403).json({
          message: 'Insufficient task permission',
        });
      }

      req.task = access.task;
      req.taskRole = access.role;
      next();
    } catch (error) {
      next(error);
    }
  };
}

module.exports = { getAccess, requireRole };
