const Notification = require('../models/Notification');
async function list(req, res, next) {
  try {
    const notifications = await Notification.find({ user: req.user._id }).sort({ createdAt: -1 });
    res.json(notifications.map((item) => ({ ...item.toObject(), isRead: item.read })));
  } catch (e) { next(e); }
}
async function unreadCount(req, res, next) {
  try {
    const count = await Notification.countDocuments({ user: req.user._id, $or: [{ read: false }, { read: { $exists: false } }] });
    res.json({ count });
  } catch (e) { next(e); }
}
async function markRead(req, res, next) {
  try {
    const n = await Notification.findOneAndUpdate({ _id: req.params.id, user: req.user._id }, { read: true }, { new: true });
    if (!n) return res.status(404).json({ message: 'Notification not found' });
    res.json({ ...n.toObject(), isRead: true });
  } catch (e) { next(e); }
}
async function markAllRead(req, res, next) {
  try {
    await Notification.updateMany({ user: req.user._id, $or: [{ read: false }, { read: { $exists: false } }] }, { read: true });
    res.json({ message: 'Notifications marked as read' });
  } catch (e) { next(e); }
}
module.exports = { list, unreadCount, markRead, markAllRead };
