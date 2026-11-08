function validate(validateInput) {
  return (req, res, next) => {
    const message = validateInput(req.body);
    if (message) return res.status(400).json({ message });
    next();
  };
}

module.exports = { validate };
