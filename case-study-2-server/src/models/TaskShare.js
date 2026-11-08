const mongoose = require('mongoose');

const taskShareSchema = new mongoose.Schema({
  task: { type: mongoose.Schema.Types.ObjectId, ref: 'Task', required: true },
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  role: { type: String, enum: ['editor', 'viewer'], default: 'viewer' },
  primary: { type: Boolean, default: false },
  sharedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
}, { timestamps: true });
taskShareSchema.index({ task: 1, user: 1 }, { unique: true });
module.exports = mongoose.model('TaskShare', taskShareSchema);
