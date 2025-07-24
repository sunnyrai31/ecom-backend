import express from 'express';
import { connectMongo } from '../Utils/mongo.js';
import { verifyToken } from '../Utils/authMiddleware.js';
const router = express.Router();

router.get('/', verifyToken, async (req, res) => {
  try {
    const db = await connectMongo();
    const cart = await db.collection('carts').find().toArray();
    res.json({cart});
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// POST /cart - create
router.post('/', async (req, res) => {
               try {
                 const db = await connectMongo();
                 const cart = req.body;
                 await db.collection('carts').insertOne(cart);
                 res.status(201).json({ message: 'Carts added', cart });
               } catch (err) {
                 res.status(500).json({ error: err.message });
               }
             });
export default router;