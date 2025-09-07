require('dotenv').config();
const jwt = require('jsonwebtoken');

module.exports = function (req, res, next) {
  const header = req.header('Authorization');
  if(!header) return res.status(401).json({ msg: 'No token, authorization denied' });
  const token = header.split(' ')[1];
  if(!token) return res.status(401).json({ msg: 'Invalid token' });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // { id, email }
    next();
  } catch (err) {
    return res.status(401).json({ msg: 'Token is not valid' });
  }
};
