const EmailLog = require('../models/EmailLog');

// Logs are intentionally restricted to messages addressed to the authenticated user.
async function list(req, res, next) {
  try {
    const filter = { to: req.user.email };
    if (req.query.status) filter.status = req.query.status;
    res.json(await EmailLog.find(filter).select('-body').sort({ createdAt: -1 }).limit(100));
  } catch (error) { next(error); }
}

module.exports = { list };
