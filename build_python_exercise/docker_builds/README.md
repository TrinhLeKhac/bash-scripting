# Docker Build Demo

A comprehensive demonstration of Docker containerization strategies for Python applications with multi-stage builds and automated deployment.

## Features

- **Multi-Stage Builds**: Optimized production images with minimal size
- **Development Environment**: Full development setup with debugging tools
- **Security**: Non-root user execution and minimal attack surface
- **Health Checks**: Built-in application health monitoring
- **Build Automation**: Scripts for automated building and deployment

## Quick Start

### Automated Build & Run (One Command)
```bash
# Run automated build script - builds all stages and demos
bash build_and_run.sh
```

### Manual Build (if needed)
```bash
# Build production image
docker build -t demo-app:production --target production .

# Build development image
docker build -t demo-app:development --target development .

# Run production container
docker run -p 8000:8000 demo-app:production
```

## Docker Build Stages

### 1. Builder Stage
- **Purpose**: Compile and build application with all dependencies
- **Base**: `python:3.11-slim`
- **Includes**: Build tools, full Python environment, source compilation
- **Size**: ~500MB (includes build tools)

### 2. Production Stage
- **Purpose**: Minimal runtime environment for deployment
- **Base**: `python:3.11-slim`
- **Includes**: Only runtime dependencies and compiled application
- **Size**: ~150MB (optimized for production)
- **Security**: Non-root user, minimal packages

### 3. Development Stage
- **Purpose**: Full development environment with debugging tools
- **Base**: Builder stage + development tools
- **Includes**: pytest, black, flake8, mypy, jupyter, git, vim
- **Size**: ~800MB (includes all development tools)

## Build Commands

### Production Build
```bash
# Build optimized production image
docker build -t demo-app:production --target production .

# Run production container
docker run -d -p 8000:8000 --name demo-prod demo-app:production

# Check container health
docker ps
docker logs demo-prod
```

### Development Build
```bash
# Build development image with all tools
docker build -t demo-app:dev --target development .

# Run development container with volume mounting
docker run -it -p 8000:8000 -v $(pwd):/app demo-app:dev bash

# Run with auto-reload for development
docker run -it -p 8000:8000 -v $(pwd):/app demo-app:dev
```

### Multi-Architecture Build
```bash
# Build for multiple platforms
docker buildx build --platform linux/amd64,linux/arm64 -t demo-app:multi .

# Push to registry
docker buildx build --platform linux/amd64,linux/arm64 -t myregistry/demo-app:latest --push .
```

## Build Optimization Strategies

### 1. Layer Caching
```dockerfile
# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy source code last (changes frequently)
COPY src/ ./src/
```

### 2. Multi-Stage Benefits
- **Smaller Images**: Production image excludes build tools
- **Security**: Minimal attack surface in production
- **Flexibility**: Different configurations for different environments

### 3. Build Context Optimization
```bash
# Use .dockerignore to exclude unnecessary files
echo "*.pyc\n__pycache__\n.git\nvenv\n*.log" > .dockerignore
```

## Container Management

### Running Containers
```bash
# Production deployment
docker run -d \
  --name demo-app \
  -p 8000:8000 \
  --restart unless-stopped \
  --health-cmd "curl -f http://localhost:8000/health || exit 1" \
  demo-app:production

# Development with live reload
docker run -it \
  --name demo-dev \
  -p 8000:8000 \
  -v $(pwd):/app \
  -e DEBUG=1 \
  demo-app:development
```

### Container Monitoring
```bash
# Check container status
docker ps -a

# View logs
docker logs -f demo-app

# Execute commands in running container
docker exec -it demo-app bash

# Monitor resource usage
docker stats demo-app
```

## Docker Compose Integration

### docker-compose.yml
```yaml
version: '3.8'
services:
  app:
    build:
      context: .
      target: production
    ports:
      - "8000:8000"
    environment:
      - ENV=production
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  app-dev:
    build:
      context: .
      target: development
    ports:
      - "8000:8000"
    volumes:
      - .:/app
    environment:
      - ENV=development
      - DEBUG=1
```

### Compose Commands
```bash
# Start production stack
docker-compose up -d

# Start development environment
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Scale application
docker-compose up --scale app=3
```

## Build Automation Script

### build_and_run.sh Features
- **Automated Building**: Builds all Docker stages automatically
- **Image Optimization**: Cleans up intermediate images
- **Testing**: Runs container health checks
- **Deployment**: Demonstrates production deployment
- **Cleanup**: Removes temporary containers and images

### Usage Examples
```bash
# Full automated build and test
bash build_and_run.sh

# Build specific target
bash build_and_run.sh production

# Build and push to registry
bash build_and_run.sh --push myregistry/demo-app
```

## Security Best Practices

### 1. Non-Root User
```dockerfile
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser
```

### 2. Minimal Base Images
- Use `python:3.11-slim` instead of full `python:3.11`
- Remove unnecessary packages after installation

### 3. Security Scanning
```bash
# Scan image for vulnerabilities
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image demo-app:production
```

## Performance Optimization

### Image Size Comparison
```bash
# Check image sizes
docker images | grep demo-app

# Expected sizes:
# demo-app:production   ~150MB
# demo-app:development  ~800MB
# demo-app:builder      ~500MB
```

### Build Performance
```bash
# Use BuildKit for faster builds
export DOCKER_BUILDKIT=1
docker build --target production .

# Parallel builds
docker buildx build --target production .
```

## Troubleshooting

### Common Issues
```bash
# Build fails - check build context
docker build --no-cache .

# Container won't start - check logs
docker logs container-name

# Permission issues - check user
docker exec -it container-name whoami

# Network issues - check ports
docker port container-name
```

### Debugging
```bash
# Debug build process
docker build --target builder --progress=plain .

# Interactive debugging
docker run -it --entrypoint bash demo-app:production

# Check container filesystem
docker exec -it container-name ls -la /app
```

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Docker Build
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build Docker image
        run: docker build --target production -t ${{ github.repository }}:${{ github.sha }} .
      - name: Run tests
        run: docker run --rm ${{ github.repository }}:${{ github.sha }} pytest
```

### Registry Deployment
```bash
# Tag for registry
docker tag demo-app:production myregistry.com/demo-app:latest

# Push to registry
docker push myregistry.com/demo-app:latest

# Deploy to production
docker pull myregistry.com/demo-app:latest
docker run -d -p 8000:8000 myregistry.com/demo-app:latest
```

## Getting Started

### Prerequisites
```bash
# Check Docker installation
docker --version
docker-compose --version

# If not installed, get Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

### Quick Setup
```bash
# Clone and build
git clone <repository>
cd docker_builds

# One-command build and run
bash build_and_run.sh

# Or manual build
docker build -t demo-app:production --target production .
docker run -p 8000:8000 demo-app:production
```

### Learning Path
1. **Run automated build** to see Docker multi-stage builds in action
2. **Explore Dockerfile** to understand build optimization strategies
3. **Compare image sizes** to see benefits of multi-stage builds
4. **Try development mode** for interactive development
5. **Deploy to production** using optimized production image

## Why Docker?

### Advantages:
- **Consistency**: Same environment across development, testing, production
- **Isolation**: Applications run in isolated containers
- **Scalability**: Easy horizontal scaling with orchestration
- **Portability**: Runs anywhere Docker is supported
- **Efficiency**: Lightweight compared to virtual machines

### Use Cases:
- **Microservices**: Deploy independent services
- **CI/CD**: Consistent build and test environments
- **Cloud Deployment**: Deploy to any cloud provider
- **Development**: Standardized development environments

## License

MIT License - see LICENSE file for details.

## Links

- **Docker Documentation**: https://docs.docker.com/
- **Best Practices**: https://docs.docker.com/develop/dev-best-practices/
- **Multi-stage Builds**: https://docs.docker.com/develop/dev-best-practices/dockerfile_best-practices/