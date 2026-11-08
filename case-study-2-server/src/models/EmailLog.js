const mongoose = require('mongoose');
module.exports = mongoose.model('EmailLog', new mongoose.Schema({
  to: { type: String, required: true }, subject: String, body: String,
  status: { type: String, enum: ['sent', 'mocked', 'failed'], required: true },
  error: String, sentAt: { type: Date, default: Date.now },
}, { timestamps: true }));
