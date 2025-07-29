# E-commerce Backend API

A robust Node.js e-commerce backend API with MongoDB integration, built with Express.js and containerized for easy deployment with Podman.

## 🚀 Features

- **RESTful API** with Express.js
- **MongoDB** integration with data validation
- **Rate limiting** and security middleware
- **Health checks** for monitoring
- **Containerized** with Podman/Docker
- **Production-ready** configuration

## 📋 Prerequisites

- Podman (or Docker) installed
- Podman Compose (optional, for multi-container deployment)

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Client Apps   │    │  E-commerce     │    │    MongoDB      │
│   (Frontend)    │◄──►│   Backend API   │◄──►│   Database      │
│                 │    │   (Node.js)     │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🐳 Podman Deployment

### Option 1: Single Container (Backend Only)

```bash
# Build the image
podman build -t ecom-backend .

# Run the container
podman run -d \
  --name ecom-backend \
  -p 4201:4201 \
  -e MONGO_URI="your-mongodb-connection-string" \
  ecom-backend
```

### Option 2: Multi-Container with MongoDB

```bash
# Using podman-compose (recommended)
podman-compose up -d

# Or using podman directly
podman network create ecom-network
podman run -d --name mongodb --network ecom-network -p 27017:27017 mongo:7.0
podman run -d --name ecom-backend --network ecom-network -p 4201:4201 ecom-backend
```

## 🔧 Configuration

### Environment Variables

Copy `env.example` to `.env` and configure:

```bash
cp env.example .env
```

Key variables:
- `PORT`: Application port (default: 4201)
- `MONGO_URI`: MongoDB connection string
- `NODE_ENV`: Environment (development/production)

### MongoDB Setup

The application includes automatic database initialization:
- Collections: `users`, `products`, `orders`
- Data validation schemas
- Performance indexes
- Authentication setup

## 📡 API Endpoints

### Health Check
- `GET /health` - Application health status

### Authentication
- `POST /auth/register` - User registration
- `POST /auth/login` - User login

### Products
- `GET /products` - List all products
- `POST /products` - Create new product
- `GET /products/:id` - Get product by ID
- `PUT /products/:id` - Update product
- `DELETE /products/:id` - Delete product

### Orders
- `GET /orders` - List all orders
- `POST /orders` - Create new order
- `GET /orders/:id` - Get order by ID
- `PUT /orders/:id` - Update order status

## 🔍 Monitoring & Health Checks

The container includes built-in health checks:
- Application health endpoint
- MongoDB connection monitoring
- Automatic restart on failure

## 🛡️ Security Features

- **Rate limiting** to prevent abuse
- **CORS** configuration for cross-origin requests
- **Input validation** and sanitization
- **Non-root user** in container
- **Environment-based** configuration

## 🚀 Development

### Local Development
```bash
npm install
npm run dev
```

### Container Development
```bash
# Build with development dependencies
podman build --target development -t ecom-backend:dev .

# Run with volume mounting for hot reload
podman run -d \
  --name ecom-backend-dev \
  -p 4201:4201 \
  -v $(pwd):/app \
  -e NODE_ENV=development \
  ecom-backend:dev
```

## 📊 Performance Considerations

- **Multi-stage builds** for smaller production images
- **Alpine Linux** base for minimal footprint
- **Dependency caching** for faster builds
- **Database indexes** for query optimization
- **Connection pooling** for MongoDB

## 🔧 Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   podman stop ecom-backend
   podman rm ecom-backend
   ```

2. **MongoDB connection failed**
   - Check MongoDB container is running
   - Verify connection string in environment
   - Ensure network connectivity

3. **Permission denied**
   ```bash
   podman unshare chown 1001:1001 -R .
   ```

### Logs
```bash
# View application logs
podman logs ecom-backend

# Follow logs in real-time
podman logs -f ecom-backend
```

## 🧪 Testing

```bash
# Test the API
curl http://localhost:4201/health

# Test MongoDB connection
curl http://localhost:4201/products
```

## 📈 Production Deployment

For production deployment, consider:
- Using a reverse proxy (nginx)
- Implementing SSL/TLS
- Setting up monitoring (Prometheus/Grafana)
- Using external MongoDB service
- Implementing backup strategies

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the ISC License. 