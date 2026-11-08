const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');
const User = require('../models/User');
const ActivityLog = require('../models/TaskActivity');
const Notification = require('../models/Notification');
const { logActivity } = require('../services/taskService');
const { sendEmail } = require('../services/emailService');
const { validateTaskInput, normalizeTaskInput } = require('../validators/taskValidator');
const { taskShared } = require('../utils/emailTemplates');

async function list(req, res, next) {
  try {
    const shares = await TaskShare.find({ user: req.user._id }).select('task');
    const ids = shares.map((s) => s.task);
    const requestedScope = String(req.query.scope || 'all').toLowerCase();
    const scope = requestedScope === 'assigned' ? 'shared' : requestedScope;
    const ownership = scope === 'owned' ? [{ owner: req.user._id }]
      : scope === 'shared' ? [{ _id: { $in: ids } }]
        : [{ owner: req.user._id }, { _id: { $in: ids } }];
    const filter = { $or: ownership };
    const normalized = normalizeTaskInput(req.query);
    ['status', 'priority', 'category'].forEach((key) => { if (normalized[key]) filter[key] = normalized[key]; });
    if (req.query.search) {
      const escaped = String(req.query.search).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      filter.$and = [{ $or: [{ title: new RegExp(escaped, 'i') }, { description: new RegExp(escaped, 'i') }] }];
    }
    if (req.query.startDateFrom) filter.startDate = { ...(filter.startDate || {}), $gte: new Date(req.query.startDateFrom) };
    if (req.query.dueDateFrom) filter.dueDate = { ...(filter.dueDate || {}), $gte: new Date(req.query.dueDateFrom) };
    if (req.query.dueDateTo) filter.dueDate = { ...(filter.dueDate || {}), $lte: new Date(req.query.dueDateTo) };
    const sortFields = new Set(['createdAt', 'updatedAt', 'title', 'priority', 'status', 'startDate', 'dueDate']);
    const requestedSort = req.query.sortBy || req.query.sort;
    const sortField = sortFields.has(requestedSort) ? requestedSort : 'createdAt';
    const direction = String(req.query.order || req.query.sortOrder || 'desc').toLowerCase() === 'asc' ? 1 : -1;
    const limit = Math.min(Math.max(Number(req.query.limit) || 100, 1), 200);
    const tasks = await Task.find(filter).populate('owner', 'name email').sort({ [sortField]: direction }).limit(limit);
    res.json(tasks);
  } catch (e) { next(e); }
}
async function create(req, res, next) {
  try {
    const input = normalizeTaskInput(req.body);
    const validationError = validateTaskInput(input);
    if (validationError) return res.status(400).json({ message: validationError });
    const task = await Task.create({ ...input, owner: req.user._id });
    await logActivity(task, req.user, 'created');
    res.status(201).json(task);
  } catch (e) { next(e); }
}
async function get(req, res) { res.json(req.task); }
async function update(req, res, next) {
  try {
    const body = { ...req.body };
    if (req.params && req.params.id && req.body.newStatus !== undefined && body.status === undefined) body.status = req.body.newStatus;
    const allowed = {}; ['title', 'description', 'category', 'priority', 'status', 'startDate', 'dueDate'].forEach((key) => { if (body[key] !== undefined) allowed[key] = body[key]; });
    Object.assign(allowed, normalizeTaskInput(allowed));
    const validationError = validateTaskInput(allowed);
    if (validationError) return res.status(400).json({ message: validationError });
    Object.assign(req.task, allowed); await req.task.save(); await logActivity(req.task, req.user, 'updated', allowed); res.json(req.task);
  } catch (e) { next(e); }
}
async function remove(req, res, next) { try { await req.task.deleteOne(); await TaskShare.deleteMany({ task: req.task._id }); await ActivityLog.deleteMany({ task: req.task._id }); res.status(204).send(); } catch (e) { next(e); } }
async function shares(req, res, next) {
  try { res.json(await TaskShare.find({ task: req.task._id }).populate('user', 'name email').populate('sharedBy', 'name email')); } catch (e) { next(e); }
}
async function share(req, res, next) {
  try {
    const emails = Array.isArray(req.body.emails) ? req.body.emails : [req.body.email];
    const uniqueEmails = [...new Set(emails.filter(Boolean).map((email) => String(email).toLowerCase().trim()))];
    if (!uniqueEmails.length) return res.status(400).json({ message: 'At least one email is required' });
    const users = await User.find({ email: { $in: uniqueEmails } });
    const found = new Set(users.map((user) => user.email));
    const missing = uniqueEmails.filter((email) => !found.has(email));
    const shares = [];
    for (const user of users) {
      if (user._id.equals(req.task.owner)) continue;
      const share = await TaskShare.findOneAndUpdate(
        { task: req.task._id, user: user._id },
        { role: req.body.role || 'viewer', primary: req.body.primary === true, sharedBy: req.user._id },
        { upsert: true, new: true, runValidators: true },
      );
      if (share.primary) await TaskShare.updateMany({ task: req.task._id, _id: { $ne: share._id } }, { primary: false });
      await Notification.create({ user: user._id, type: 'task_shared', title: 'Task shared with you', message: `${req.user.name} shared "${req.task.title}"`, data: { taskId: req.task._id } });
      try {
        const email = taskShared({
          senderName: req.user.name,
          taskTitle: req.task.title,
        });
        await sendEmail({
          to: user.email,
          ...email,
        });
      } catch (error) {
        console.error('Unable to send task sharing email:', error);
      }
      shares.push(await share.populate('user', 'name email'));
    }
    res.status(201).json({ shares, missing });
  } catch (e) { next(e); }
}
async function updateShare(req, res, next) {
  try {
    const changes = {};
    if (req.body.role !== undefined) changes.role = req.body.role;
    if (req.body.primary !== undefined) changes.primary = Boolean(req.body.primary);
    const share = await TaskShare.findOneAndUpdate({ task: req.task._id, user: req.params.userId }, changes, { new: true, runValidators: true }).populate('user', 'name email');
    if (!share) return res.status(404).json({ message: 'Assignee not found' });
    if (share.primary) await TaskShare.updateMany({ task: req.task._id, _id: { $ne: share._id } }, { primary: false });
    await Notification.create({ user: share.user._id || share.user, type: 'assignment_updated', title: 'Task assignment updated', message: `Your access to "${req.task.title}" was updated`, data: { taskId: req.task._id } });
    res.json(share);
  } catch (e) { next(e); }
}
async function unshare(req, res, next) {
  try {
    const removed = await TaskShare.findOneAndDelete({ task: req.task._id, user: req.params.userId });
    if (!removed) return res.status(404).json({ message: 'Assignee not found' });
    await Notification.create({ user: removed.user, type: 'task_unshared', title: 'Task access revoked', message: `Your access to "${req.task.title}" was revoked`, data: { taskId: req.task._id } });
    res.status(204).send();
  } catch (e) { next(e); }
}
async function activity(req, res, next) { try { res.json(await ActivityLog.find({ task: req.task._id }).populate('user', 'name email').sort({ createdAt: -1 })); } catch (e) { next(e); } }
module.exports = { list, create, get, update, remove, shares, share, updateShare, unshare, activity };
