const express = require('express');
const authRoutes = require('./routes/authRoutes');
const taskRoutes = require('./routes/taskRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const emailLogRoutes = require('./routes/emailLogRoutes');
const userRoutes = require('./routes/userRoutes');
const statisticsRoutes = require('./routes/statisticsRoutes');
const assignmentRoutes = require('./routes/assignmentRoutes');
const taskShareRoutes = require('./routes/taskShareRoutes');
const { notFound, errorHandler } = require('./middleware/errorMiddleware');

function createApp() {
  const app = express();
  app.use(express.json({ limit: '1mb' }));
  app.get('/', (req, res) => {
    res.json({ message: 'Task Manager API is running' });
  });
  app.get('/health', (req, res) => res.json({ status: 'ok' }));
  app.use('/api/auth', authRoutes);
  app.use('/api/tasks', taskRoutes);
  app.use('/api/notifications', notificationRoutes);
  app.use('/api/email-logs', emailLogRoutes);
  app.use('/api/users', userRoutes);
  app.use('/api/statistics', statisticsRoutes);
  app.use('/api/tasks', assignmentRoutes);
  app.use('/api/tasks', taskShareRoutes);
  app.use(notFound);
  app.use(errorHandler);
  return app;
}

module.exports = createApp;
