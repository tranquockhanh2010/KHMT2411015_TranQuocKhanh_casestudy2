const User = require('../models/User');
const bcrypt = require('bcryptjs');

function publicUser(user) {
  const value = user.toObject ? user.toObject() : { ...user };
  delete value.passwordHash;
  value.displayName = value.name;
  value.username = value.name;
  return value;
}

async function search(req, res, next) {
  try {
    const query = String(req.query.q || '').trim();
    if (!query) return res.json([]);
    const matcher = new RegExp(query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');
    const users = await User.find({
      $or: [{ name: matcher }, { email: matcher }],
    }).select('name email').limit(20);
    res.json(users);
  } catch (error) {
    next(error);
  }
}

async function getById(req, res, next) {
  try {
    const user = await User.findById(req.params.id).select('name email');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (error) {
    next(error);
  }
}

async function me(req, res) {
  res.json({ user: publicUser(req.user) });
}

async function updateProfile(req, res, next) {
  try {
    const changes = {};
    if (req.body.name !== undefined || req.body.displayName !== undefined || req.body.username !== undefined) {
      changes.name = req.body.name || req.body.displayName || req.body.username;
    }
    if (req.body.email !== undefined) changes.email = req.body.email;
    const user = await User.findByIdAndUpdate(req.user._id, changes, { new: true, runValidators: true });
    res.json({ user: publicUser(user) });
  } catch (error) { next(error); }
}

async function changePassword(req, res, next) {
  try {
    const user = await User.findById(req.user._id).select('+passwordHash');
    if (!user || !(await bcrypt.compare(req.body.currentPassword || '', user.passwordHash))) {
      return res.status(400).json({ message: 'Current password is incorrect' });
    }
    if (!req.body.newPassword || String(req.body.newPassword).length < 6) {
      return res.status(400).json({ message: 'New password must be at least 6 characters' });
    }
    user.passwordHash = await bcrypt.hash(req.body.newPassword, 12);
    await user.save();
    res.json({ message: 'Password changed successfully' });
  } catch (error) { next(error); }
}

module.exports = { search, getById, me, updateProfile, changePassword };
