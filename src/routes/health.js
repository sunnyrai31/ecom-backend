import express from 'express';
import { connectMongo } from '../Utils/mongo.js';

const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const db = await connectMongo();
    const health = await db.collection('health').find().toArray();
    res.json({health});
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

export default router;