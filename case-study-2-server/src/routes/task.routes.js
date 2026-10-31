const express = require('express');
const Task = require('../models/task.model');

const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const tasks = await Task.find().sort({ createdAt: -1 });
    res.status(200).json(tasks);
  } catch (error) {
    console.error('Unable to fetch tasks:', error);
    res.status(500).json({
      message: 'Không thể lấy danh sách công việc',
    });
  }
});

module.exports = router;

