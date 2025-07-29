# E-commerce Full Stack Application

A complete e-commerce application with React frontend, Node.js backend, and MongoDB database, containerized for Kubernetes deployment.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │    MongoDB      │
│   (React)       │◄──►│   (Node.js)     │◄──►│   (Database)    │
│   Port: 3000    │    │   Port: 4201    │    │   Port: 27017   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🐳 Containerization

### Frontend Container
- **Base Image**: `node:18-alpine` (builder) + `nginx:alpine` (production)
- **Multi-stage build** for optimized production image
- **Nginx** serves static files with proper caching and security headers
- **Health checks** for container monitoring

### Backend Container
- **Base Image**: `node:18-alpine`
- **Non-root user** for security
- **Health checks** via `/health` endpoint
- **Environment-based configuration**

## 🚀 Deployment Options

### 1. Docker Compose (Development)
```bash
# Deploy all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### 2. Individual Services
```bash
# Frontend only
cd ecom-frontend
docker-compose up -d

# Backend only
cd ecom-backend
docker-compose up -d
```

### 3. Kubernetes (Production)
```bash
# Deploy to Kubernetes
./deploy.sh

# Check status
kubectl get pods -n ecommerce
kubectl get services -n ecommerce
```

## 📁 Project Structure

```
FullStack/
├── ecom-frontend/           # React frontend
│   ├── Dockerfile          # Frontend container config
│   ├── nginx.conf          # Nginx configuration
│   ├── docker-compose.yml  # Frontend service
│   └── src/                # React source code
├── ecom-backend/           # Node.js backend
│   ├── Dockerfile          # Backend container config
│   ├── docker-compose.yml  # Backend service
│   └── src/                # Backend source code
├── k8s/                    # Kubernetes manifests
│   ├── namespace.yaml      # Ecommerce namespace
│   ├── mongodb-*.yaml      # MongoDB deployment
│   ├── backend-*.yaml      # Backend deployment
│   ├── frontend-*.yaml     # Frontend deployment
│   └── ingress.yaml        # Ingress configuration
├── docker-compose.yml      # Full application
├── deploy.sh              # Deployment script
└── README.md              # This file
```

## 🔧 Configuration

### Environment Variables

#### Frontend
- `NODE_ENV`: Production/development mode
- `REACT_APP_API_URL`: Backend API URL

#### Backend
- `NODE_ENV`: Production/development mode
- `PORT`: Server port (default: 4201)
- `MONGO_URI`: MongoDB connection string

#### MongoDB
- `MONGO_INITDB_ROOT_USERNAME`: Admin username
- `MONGO_INITDB_ROOT_PASSWORD`: Admin password
- `MONGO_INITDB_DATABASE`: Database name

## 🌐 API Endpoints

### Products
- `GET /products` - List all products
- `GET /products/:id` - Get single product
- `POST /products` - Create product
- `PUT /products/:id` - Update product
- `DELETE /products/:id` - Delete product

### Authentication
- `POST /auth/register` - Register user
- `POST /auth/login` - Login user
- `GET /auth/me` - Get user profile

### Orders
- `GET /orders` - Get cart items
- `POST /orders` - Add to cart

### Health
- `GET /health` - Health check

## 🔍 Monitoring & Health Checks

### Docker Health Checks
- **Frontend**: HTTP GET to `/health`
- **Backend**: HTTP GET to `/health`
- **MongoDB**: Container process health

### Kubernetes Probes
- **Liveness Probe**: Detects dead containers
- **Readiness Probe**: Ensures traffic routing
- **Startup Probe**: Handles slow startup

## 📊 Resource Requirements

### Development
- **Frontend**: 128Mi RAM, 100m CPU
- **Backend**: 256Mi RAM, 250m CPU
- **MongoDB**: 256Mi RAM, 250m CPU

### Production
- **Frontend**: 256Mi RAM, 200m CPU
- **Backend**: 512Mi RAM, 500m CPU
- **MongoDB**: 512Mi RAM, 500m CPU

## 🔒 Security Features

### Container Security
- Non-root users
- Minimal base images (Alpine Linux)
- Security headers in nginx
- Resource limits

### Network Security
- Internal service communication
- Ingress for external access
- CORS configuration
- Rate limiting

## 🚀 CI/CD Pipeline

### Build Process
1. **Frontend**: Build React app → Create nginx image
2. **Backend**: Build Node.js app → Create production image
3. **Database**: Use official MongoDB image

### Deployment Process
1. Create namespace
2. Deploy MongoDB with persistent storage
3. Deploy backend with health checks
4. Deploy frontend with health checks
5. Configure ingress for external access

## 🐛 Troubleshooting

### Common Issues

#### Container Won't Start
```bash
# Check logs
docker logs <container-name>
kubectl logs <pod-name> -n ecommerce

# Check resource usage
docker stats
kubectl top pods -n ecommerce
```

#### Database Connection Issues
```bash
# Check MongoDB status
kubectl exec -it deployment/mongodb -n ecommerce -- mongo

# Check backend logs
kubectl logs deployment/ecom-backend -n ecommerce
```

#### Frontend Not Loading
```bash
# Check frontend logs
kubectl logs deployment/ecom-frontend -n ecommerce

# Check ingress
kubectl get ingress -n ecommerce
```

### Useful Commands

```bash
# View all resources
kubectl get all -n ecommerce

# Port forward for debugging
kubectl port-forward service/frontend-service 3000:80 -n ecommerce
kubectl port-forward service/backend-service 4201:4201 -n ecommerce

# Scale deployments
kubectl scale deployment ecom-frontend --replicas=3 -n ecommerce
kubectl scale deployment ecom-backend --replicas=3 -n ecommerce

# Update images
kubectl set image deployment/ecom-frontend ecom-frontend=ecom-frontend:v2 -n ecommerce
```

## 📈 Scaling

### Horizontal Pod Autoscaler
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ecom-backend-hpa
  namespace: ecommerce
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ecom-backend
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## 🔄 Updates & Rollbacks

### Rolling Updates
```bash
# Update deployment
kubectl set image deployment/ecom-backend ecom-backend=ecom-backend:v2 -n ecommerce

# Check rollout status
kubectl rollout status deployment/ecom-backend -n ecommerce

# Rollback if needed
kubectl rollout undo deployment/ecom-backend -n ecommerce
```

## 📝 Best Practices

1. **Always use specific image tags** in production
2. **Implement proper health checks** for all services
3. **Use resource limits** to prevent resource exhaustion
4. **Implement proper logging** for debugging
5. **Use secrets** for sensitive data in production
6. **Regular security updates** of base images
7. **Monitor application metrics** and logs
8. **Implement proper backup strategies** for databases

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with Docker Compose
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License. 