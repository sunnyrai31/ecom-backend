// MongoDB initialization script
db = db.getSiblingDB('ecom');

// Create collections with validation
db.createCollection('users', {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["email", "passwordHash"],
      properties: {
        email: {
          bsonType: "string",
          pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
        },
        passwordHash: {
          bsonType: "string",
          minLength: 6
        }
      }
    }
  }
});

db.createCollection('products', {
  validator: { 
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "price"],
      properties: {
        name: {
          bsonType: "string",
          minLength: 1
        },
        price: {
          bsonType: "number",
          minimum: 0
        },
        description: {
          bsonType: "string"
        }
      }
    }
  }
});

db.createCollection('orders', {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "products", "total"],
      properties: {
        userId: {
          bsonType: "objectId"
        },
        products: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["productId", "quantity"],
            properties: {
              productId: {
                bsonType: "objectId"
              },
              quantity: {
                bsonType: "number",
                minimum: 1
              }
            }
          }
        },
        total: {
          bsonType: "number",
          minimum: 0
        },
        status: {
          enum: ["pending", "processing", "shipped", "delivered", "cancelled"]
        }
      }
    }
  }
});

// Create indexes for better performance
db.users.createIndex({ "email": 1 }, { unique: true });
db.products.createIndex({ "name": 1 });
db.orders.createIndex({ "userId": 1 });
db.orders.createIndex({ "createdAt": -1 });

// Insert sample data
print('📦 Inserting sample products...');
db.products.insertMany([
  {
    _id: ObjectId(),
    name: "iPhone 15 Pro",
    price: 999.99,
    description: "Latest iPhone with advanced camera system and A17 Pro chip",
    category: "Electronics",
    stock: 50,
    createdAt: new Date()
  },
  {
    _id: ObjectId(),
    name: "MacBook Air M2",
    price: 1199.99,
    description: "Ultra-thin laptop with M2 chip for incredible performance",
    category: "Electronics",
    stock: 25,
    createdAt: new Date()
  },
  {
    _id: ObjectId(),
    name: "Nike Air Max 270",
    price: 150.00,
    description: "Comfortable running shoes with Air Max technology",
    category: "Footwear",
    stock: 100,
    createdAt: new Date()
  },
  {
    _id: ObjectId(),
    name: "Samsung 4K Smart TV",
    price: 799.99,
    description: "55-inch 4K Ultra HD Smart TV with HDR",
    category: "Electronics",
    stock: 15,
    createdAt: new Date()
  },
  {
    _id: ObjectId(),
    name: "Coffee Maker",
    price: 89.99,
    description: "Programmable coffee maker with 12-cup capacity",
    category: "Home & Kitchen",
    stock: 75,
    createdAt: new Date()
  }
]);

print('👥 Inserting sample users...');
db.users.insertMany([
  {
    _id: ObjectId(),
    id: 1,
    name: "John Doe",
    email: "john@example.com",
    passwordHash: "$2b$10$rQZ8K9X2Y1L3M4N5O6P7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1E2F3G4H5I6J",
    role: "customer",
    createdAt: new Date()
  },
  {
    _id: ObjectId(),
    id: 2,
    name: "Jane Smith",
    email: "jane@example.com",
    passwordHash: "$2b$10$rQZ8K9X2Y1L3M4N5O6P7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1E2F3G4H5I6J",
    role: "customer",
    createdAt: new Date()
  },
  {
    _id: ObjectId(),
    id: 3,
    name: "Admin User",
    email: "admin@example.com",
    passwordHash: "$2b$10$rQZ8K9X2Y1L3M4N5O6P7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1E2F3G4H5I6J",
    role: "admin",
    createdAt: new Date()
  }
]);

print('📋 Inserting sample orders...');
const sampleProducts = db.products.find().toArray();
const sampleUsers = db.users.find().toArray();

if (sampleProducts.length > 0 && sampleUsers.length > 0) {
  db.orders.insertMany([
    {
      _id: ObjectId(),
      userId: sampleUsers[0]._id,
      products: [
        {
          productId: sampleProducts[0]._id,
          quantity: 1,
          price: sampleProducts[0].price
        }
      ],
      total: sampleProducts[0].price,
      status: "pending",
      createdAt: new Date()
    },
    {
      _id: ObjectId(),
      userId: sampleUsers[1]._id,
      products: [
        {
          productId: sampleProducts[1]._id,
          quantity: 1,
          price: sampleProducts[1].price
        },
        {
          productId: sampleProducts[2]._id,
          quantity: 2,
          price: sampleProducts[2].price
        }
      ],
      total: sampleProducts[1].price + (sampleProducts[2].price * 2),
      status: "processing",
      createdAt: new Date()
    }
  ]);
}

print('✅ MongoDB database initialized successfully with sample data');
print('📊 Sample data summary:');
print('   - Products: ' + db.products.countDocuments());
print('   - Users: ' + db.users.countDocuments());
print('   - Orders: ' + db.orders.countDocuments()); 