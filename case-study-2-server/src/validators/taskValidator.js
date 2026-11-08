const priorities = ['Low', 'Medium', 'High'];
const statuses = ['Pending', 'InProgress', 'Completed'];

function validateTaskInput(input) {
  if (input.title !== undefined && !String(input.title).trim()) {
    return 'Title is required';
  }
  if (input.priority !== undefined && !priorities.includes(input.priority)) {
    return 'Invalid priority';
  }
  if (input.status !== undefined && !statuses.includes(input.status)) {
    return 'Invalid status';
  }
  for (const key of ['startDate', 'dueDate']) {
    if (input[key] !== undefined && input[key] !== null && Number.isNaN(new Date(input[key]).getTime())) {
      return `Invalid ${key}`;
    }
  }
  if (input.startDate && input.dueDate && new Date(input.startDate) > new Date(input.dueDate)) {
    return 'Start date must be before due date';
  }
  return null;
}

function normalizeTaskInput(input) {
  const value = { ...input };
  const priorityMap = { low: 'Low', medium: 'Medium', high: 'High' };
  const statusMap = { todo: 'Pending', pending: 'Pending', in_progress: 'InProgress', inprogress: 'InProgress', completed: 'Completed', done: 'Completed' };
  if (typeof value.priority === 'string') value.priority = priorityMap[value.priority.toLowerCase()] || value.priority;
  if (typeof value.status === 'string') value.status = statusMap[value.status.toLowerCase()] || value.status;
  return value;
}

module.exports = { validateTaskInput, normalizeTaskInput, priorities, statuses };
