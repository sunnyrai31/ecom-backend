import express from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { connectMongo } from '../Utils/mongo.js';
import { verifyToken } from '../Utils/authMiddleware.js';
const router = express.Router();
const SECRET = 'gearshift-top-secret'; // 🔐 You can move this to env

// 🔐 POST /register
router.post('/register', async (req, res) => {
  const { name, email, password } = req.body;
  const db = await connectMongo();
  const users = db.collection('users');

  const existing = await users.findOne({ email });
  if (existing) return res.status(409).json({ error: 'User already exists' });

  const passwordHash = await bcrypt.hash(password, 10);
  const newUser = {
    id: Date.now(), // you can use uuid if you want
    name,
    email,
    passwordHash,
    role: 'customer',
    createdAt: new Date()
  };

  await users.insertOne(newUser);
  res.status(201).json({ message: 'User registered successfully' });
});

// 🔑 POST /login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const db = await connectMongo();
  const users = db.collection('users');

  const user = await users.findOne({ email });
  if (!user) return res.status(401).json({ error: 'Invalid credentials' });

  const match = await bcrypt.compare(password, user.passwordHash);
  if (!match) return res.status(401).json({ error: 'Invalid credentials' });

  const token = jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    SECRET,
    { expiresIn: '2h' }
  );

  res.json({ token });
});
router.get('/me', verifyToken, async (req, res) => {
  const db = await connectMongo();
  const user = await db.collection('users').findOne({ id: req.user.id }, { projection: { passwordHash: 0 } });

  if (!user) return res.status(404).json({ error: 'User not found' });

  res.json({ user });
});

export default router;
