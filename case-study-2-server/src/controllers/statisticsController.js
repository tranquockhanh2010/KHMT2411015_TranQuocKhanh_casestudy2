const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');

async function tasks(req, res, next) {
  try {
    const shared = await TaskShare.find({ user: req.user._id }).select('task');
    const result = await Task.aggregate([
      { $match: { $or: [{ owner: req.user._id }, { _id: { $in: shared.map((item) => item.task) } }] } },
      { $group: { _id: '$status', count: { $sum: 1 } } },
      { $sort: { _id: 1 } },
    ]);
    const totals = result.reduce((sum, item) => sum + item.count, 0);
    const now = new Date();
    const deadlines = await Task.countDocuments({
      $or: [{ owner: req.user._id }, { _id: { $in: shared.map((item) => item.task) } }],
      dueDate: { $gte: now, $lte: new Date(now.getTime() + 7 * 86400000) },
      status: { $ne: 'Completed' },
    });
    res.json({ byStatus: result, total: totals, upcomingDeadlines: deadlines });
  } catch (error) {
    next(error);
  }
}

async function assignments(req, res, next) {
  try {
    const result = await TaskShare.aggregate([
      { $match: { user: req.user._id } },
      { $group: { _id: '$role', count: { $sum: 1 } } },
    ]);
    res.json({ byRole: result, total: result.reduce((sum, item) => sum + item.count, 0) });
  } catch (error) { next(error); }
}

async function deadlines(req, res, next) {
  try {
    const shared = await TaskShare.find({ user: req.user._id }).select('task');
    const tasks = await Task.find({
      $or: [{ owner: req.user._id }, { _id: { $in: shared.map((item) => item.task) } }],
      dueDate: { $exists: true },
      status: { $ne: 'Completed' },
    }).sort({ dueDate: 1 });
    res.json(tasks);
  } catch (error) { next(error); }
}

module.exports = { tasks, assignments, deadlines };
