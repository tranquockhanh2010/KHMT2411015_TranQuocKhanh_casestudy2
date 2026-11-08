const nodemailer = require('nodemailer');
const config = require('../config/email');
const EmailLog = require('../models/EmailLog');

const configured = Boolean(config.host && config.user && config.pass);
const transporter = configured ? nodemailer.createTransport({
  host: config.host, port: config.port, secure: config.secure,
  auth: { user: config.user, pass: config.pass },
}) : null;

async function sendEmail({ to, subject, text, html }) {
  if (!configured) {
    const log = await EmailLog.create({ to, subject, body: text || html, status: 'mocked' });
    return { mocked: true, log };
  }
  try {
    await transporter.sendMail({ from: config.from, to, subject, text, html });
    const log = await EmailLog.create({ to, subject, body: text || html, status: 'sent' });
    return { mocked: false, log };
  } catch (error) {
    await EmailLog.create({ to, subject, body: text || html, status: 'failed', error: error.message });
    throw error;
  }
}
module.exports = { sendEmail };
