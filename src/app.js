
import { connectMongo } from './Utils/mongo.js';
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import healthRoutes from './routes/health.js';
import productRoutes from './routes/products.js';
import orderRoutes from './routes/orders.js';               
import authRoutes from './routes/auth.js';
import { globalRateLimiter } from './middlewares/rateLimiter.js';
import { enforceJsonType } from './middlewares/requestType.js';
import { rejectEmptyBody } from './middlewares/sanity.js';


dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());
app.use(globalRateLimiter);
app.use(enforceJsonType);
app.use(rejectEmptyBody);

app.use('/health', healthRoutes);
app.use('/products', productRoutes);
app.use('/orders', orderRoutes);
app.use('/auth', authRoutes);
app.get('/', (req, res) => {
  res.send('🔥 Ecom backend is alive and breathing!');
});

app.listen(PORT, () => {
  console.log(`⚡ Server running at http://localhost:${PORT}`);
});
const startServer = async () => {
               try {
                 await connectMongo();
                 app.listen(PORT, () => {
                   console.log(`⚡ Server running at http://localhost:${PORT}`);
                 });
               } catch (err) {
                 console.error('❌ Startup failed:', err.message);
               }
             };
             
             startServer();