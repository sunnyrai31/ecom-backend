import express from 'express';
import { connectMongo } from '../Utils/mongo.js';

const router = express.Router();

// GET /products - list with filters
router.get('/', async (req, res) => {
  try {
    const db = await connectMongo();
    const { category, minPrice, maxPrice, skip = 0, limit = 10 } = req.query;

    const query = {};
    if (category) query.category = category;
    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = parseFloat(minPrice);
      if (maxPrice) query.price.$lte = parseFloat(maxPrice);
    }

    const products = await db.collection('products')
      .find(query)
      .skip(parseInt(skip))
      .limit(parseInt(limit))
      .toArray();

    res.json(products);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /products/:id - single product
router.get('/:id', async (req, res) => {
  try {
    const db = await connectMongo();
    const product = await db.collection('products').findOne({ id: parseInt(req.params.id) });
    if (!product) return res.status(404).json({ error: 'Product not found' });
    res.json(product);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /products - create
router.post('/', async (req, res) => {
  try {
    const db = await connectMongo();
    const product = req.body;
    await db.collection('products').insertOne(product);
    res.status(201).json({ message: 'Product added', product });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT /products/:id - update
router.put('/:id', async (req, res) => {
  try {
    const db = await connectMongo();
    const result = await db.collection('products').updateOne(
      { id: parseInt(req.params.id) },
      { $set: req.body }
    );
    if (result.matchedCount === 0) return res.status(404).json({ error: 'Product not found' });
    res.json({ message: 'Product updated' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE /products/:id
router.delete('/:id', async (req, res) => {
  try {
    const db = await connectMongo();
    const result = await db.collection('products').deleteOne({ id: parseInt(req.params.id) });
    if (result.deletedCount === 0) return res.status(404).json({ error: 'Product not found' });
    res.json({ message: 'Product deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
