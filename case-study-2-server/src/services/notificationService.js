const Notification = require('../models/Notification');

async function createNotification(data) {
  return Notification.create(data);
}

module.exports = { createNotification };
