import { MongoClient } from 'mongodb';
import dotenv from 'dotenv';

dotenv.config();

const uri = process.env.MONGO_URI;
const client = new MongoClient(uri, { useUnifiedTopology: true });

let db;

export async function connectMongo() {
  if (db) return db;

  try {
    await client.connect();
    db = client.db(); // defaults to db name from URI
    console.log('🧠 Connected to MongoDB');
    return db;
  } catch (err) {
    console.error('❌ MongoDB connection failed:', err.message);
    throw err;
  }
}
