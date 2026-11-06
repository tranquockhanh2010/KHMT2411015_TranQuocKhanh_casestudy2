const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const config = require('../config/database');
const { validateCredentials } = require('../validators/authValidator');

function publicUser(user) {
  const value = user.toObject ? user.toObject() : { ...user };
  delete value.passwordHash;
  value.displayName = value.name;
  value.username = value.name;
  return value;
}

function hashPassword(password) {
  return bcrypt.hash(password, 12);
}

function comparePassword(password, passwordHash) {
  return bcrypt.compare(password, passwordHash);
}

function createToken(user) {
  return jwt.sign(
    { sub: user._id.toString(), email: user.email },
    config.jwtSecret,
    { expiresIn: config.jwtExpiresIn },
  );
}

async function register(req, res, next) {
  try {
    const name = req.body.name || req.body.displayName || req.body.username;
    const { email, password } = req.body;
    const validationError = validateCredentials({ email, password });
    if (!name || validationError) {
      return res.status(400).json({
        message: !name ? 'Name is required' : validationError,
      });
    }
    const user = await User.create({ name, email, passwordHash: await hashPassword(password) });
    res.status(201).json({ user: publicUser(user), token: createToken(user) });
  } catch (e) { next(e); }
}
async function login(req, res, next) {
  try {
    const user = await User.findOne({ email: String(req.body.email || req.body.username || '').toLowerCase() }).select('+passwordHash');
    if (!user || !(await comparePassword(req.body.password || '', user.passwordHash))) return res.status(401).json({ message: 'Invalid email or password' });
    res.json({ user: publicUser(user), token: createToken(user) });
  } catch (e) { next(e); }
}
async function me(req, res) { res.json({ user: publicUser(req.user) }); }
async function updateProfile(req, res, next) {
  try {
    const allowed = {};
    if (req.body.name !== undefined || req.body.displayName !== undefined || req.body.username !== undefined) {
      allowed.name = req.body.name || req.body.displayName || req.body.username;
    }
    if (req.body.email !== undefined) allowed.email = req.body.email;
    const user = await User.findByIdAndUpdate(req.user._id, allowed, { new: true, runValidators: true });
    res.json({ user: publicUser(user) });
  } catch (e) { next(e); }
}
async function changePassword(req, res, next) {
  try {
    const user = await User.findById(req.user._id).select('+passwordHash');
    if (!(await comparePassword(req.body.currentPassword || '', user.passwordHash))) return res.status(400).json({ message: 'Current password is incorrect' });
    if (!req.body.newPassword || req.body.newPassword.length < 6) return res.status(400).json({ message: 'New password must be at least 6 characters' });
    user.passwordHash = await hashPassword(req.body.newPassword); await user.save();
    res.json({ message: 'Password changed successfully' });
  } catch (e) { next(e); }
}
module.exports = { register, login, me, updateProfile, changePassword };
