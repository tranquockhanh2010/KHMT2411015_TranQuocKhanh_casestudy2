function validateCredentials({ email, password }) {
  if (!email || !String(email).includes('@')) {
    return 'A valid email is required';
  }
  if (!password || String(password).length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}

module.exports = { validateCredentials };
