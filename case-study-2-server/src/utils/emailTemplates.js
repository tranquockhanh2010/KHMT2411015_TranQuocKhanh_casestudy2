function taskShared({senderName, taskTitle}) {
  return {
    subject: `Task shared: ${taskTitle}`,
    text: `${senderName} shared the task "${taskTitle}" with you.`,
  };
}

module.exports = { taskShared };
