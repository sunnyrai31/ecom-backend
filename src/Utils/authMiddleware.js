import jwt from 'jsonwebtoken';
const SECRET = 'gearshift-top-secret';

export const verifyToken = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ error: 'Missing token' });

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, SECRET);
    req.user = decoded; // inject user info into request
    next();
  } catch (err) {
    res.status(401).json({ error: 'Invalid token' });
  }
};
