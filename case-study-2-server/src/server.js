const mongoose = require('mongoose');
const config = require('./config/database');
const createApp = require('./app');
const app = createApp();

const dns = require('dns');
dns.setServers(['8.8.8.8', '8.8.4.4']);

async function startServer() {
  if (!config.mongoUri) {
    throw new Error('MONGODB_URI is not configured');
  }
  await mongoose.connect(config.mongoUri);
  return app.listen(config.port, () => {
    console.log(`Server running on port ${config.port}`);
  });
}

if (require.main === module) {
  startServer().catch((error) => {
    console.error('Unable to start server:', error);
    process.exitCode = 1;
  });
}

module.exports = { app, startServer };
