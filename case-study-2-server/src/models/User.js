const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true, maxlength: 120 },
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  passwordHash: { type: String, required: true, select: false },
  isActive: { type: Boolean, default: true },
}, { timestamps: true, toJSON: { transform: (doc, ret) => { delete ret.passwordHash; return ret; } } });

module.exports = mongoose.model('User', userSchema);
