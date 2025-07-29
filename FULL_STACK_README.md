# Full Stack E-commerce Application

A complete e-commerce application with React frontend and Node.js backend, fully containerized with Docker/Podman support and Kubernetes deployment ready.

## 📁 Project Structure

```
FullStack/
├── ecom-frontend/           # React frontend application
│   ├── Dockerfile          # Frontend container configuration
│   ├── podman-compose.yml  # Frontend service (Podman)
│   └── src/                # React source code
├── ecom-backend/           # Node.js backend application
│   ├── Dockerfile          # Backend container configuration
│   ├── podman-compose.yml  # Backend service (Podman)
│   ├── deploy.sh          # Podman deployment script
│   ├── k8s/               # Kubernetes manifests
│   │   ├── deploy.sh      # Kubernetes deployment script
│   │   ├── README.md      # Kubernetes documentation
│   │   └── *.yaml         # Kubernetes manifests
│   └── src/               # Backend source code
├── LICENSE                 # MIT License
└── README.md              # This file
```

## 🚀 Quick Start

### Prerequisites
- Podman or Docker installed
- Node.js 18+ (for local development)

### Frontend (React)
```bash
cd ecom-frontend

# Using Podman (Recommended)
podman-compose up -d

# Access at: http://localhost:4202
```

### Backend (Node.js)
```bash
cd ecom-backend

# Using Podman (Recommended)
podman-compose up -d

# Access API at: http://localhost:4201
```

### Kubernetes Deployment
```bash
cd ecom-backend/k8s
./deploy.sh
```

## 🌐 Application URLs

- **Frontend**: http://localhost:4202
- **Backend API**: http://localhost:4201
- **MongoDB**: localhost:27017

## 📚 API Endpoints

### Backend API (Port 4201)
- `GET /health` - Health check
- `GET /products` - Get all products
- `GET /auth/*` - Authentication endpoints
- `GET /orders/*` - Order management endpoints

## 🛠️ Technologies Used

### Frontend
- **React** - User interface
- **serve** - Simple HTTP server for production
- **Podman** - Container runtime

### Backend
- **Node.js** - Runtime environment
- **Express** - Web framework
- **MongoDB** - Database
- **JWT** - Authentication
- **Podman** - Container runtime

### Infrastructure
- **Podman** - Containerization
- **Kubernetes** - Orchestration
- **MongoDB** - Database

## 🔧 Development

### Local Development
1. **Frontend**: React development server with hot reload
2. **Backend**: Node.js development with nodemon
3. **Database**: MongoDB with persistent storage

### Production
- **Frontend**: Containerized with serve (simple HTTP server)
- **Backend**: Containerized with optimized Node.js
- **Database**: MongoDB with persistent storage

## 🐳 Containerization

### Frontend Container
- **Base Image**: node:18-alpine
- **Server**: serve (simple HTTP server)
- **Port**: 4202
- **Build**: Multi-stage build for optimized production image

### Backend Container
- **Base Image**: node:18-alpine
- **Framework**: Express.js
- **Port**: 4201
- **Database**: MongoDB (external container)

## ☸️ Kubernetes Deployment

The application includes complete Kubernetes manifests for:
- **Namespace**: ecommerce
- **MongoDB**: Deployment, Service, PVC, ConfigMap
- **Backend**: Deployment, Service, ConfigMap
- **Frontend**: Deployment, Service
- **Ingress**: Nginx Ingress for external access

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 TODO

- [ ] Add authentication UI
- [ ] Implement shopping cart
- [ ] Add payment integration
- [ ] Implement order management
- [ ] Add admin dashboard
- [ ] Implement search functionality
- [ ] Add product categories
- [ ] Implement user reviews 