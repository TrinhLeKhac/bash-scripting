# Exercise 4: Docker Multi-Stage Build System

## Objective
Create an advanced Makefile that manages Docker multi-stage builds, container orchestration, testing in containers, and deployment across different environments.

## Project Structure
```
docker_project/
├── app/
│   ├── src/
│   │   ├── main.go
│   │   ├── handlers/
│   │   └── models/
│   ├── tests/
│   │   └── main_test.go
│   ├── Dockerfile
│   └── go.mod
├── database/
│   ├── migrations/
│   │   ├── 001_initial.sql
│   │   └── 002_users.sql
│   ├── seeds/
│   │   └── sample_data.sql
│   └── Dockerfile
├── nginx/
│   ├── nginx.conf
│   ├── ssl/
│   └── Dockerfile
├── monitoring/
│   ├── prometheus/
│   │   └── prometheus.yml
│   ├── grafana/
│   │   └── dashboards/
│   └── docker-compose.monitoring.yml
├── docker-compose.yml
├── docker-compose.test.yml
├── docker-compose.prod.yml
├── .dockerignore
└── Makefile
```

## Requirements

### Multi-Stage Build Features
1. **Build Stage**: Compile application with all build tools
2. **Test Stage**: Run tests in isolated environment
3. **Security Scan**: Scan images for vulnerabilities
4. **Production Stage**: Minimal runtime image
5. **Debug Stage**: Development image with debugging tools

### Container Management
1. **Image Building**: Build all service images
2. **Layer Optimization**: Minimize image sizes and layers
3. **Caching**: Optimize build cache usage
4. **Registry Management**: Push/pull from container registry
5. **Image Tagging**: Semantic versioning and environment tags

### Testing in Containers
1. **Unit Tests**: Run tests inside containers
2. **Integration Tests**: Test service interactions
3. **Load Tests**: Performance testing with containers
4. **Security Tests**: Container security scanning
5. **Smoke Tests**: Quick deployment verification

### Orchestration Features
1. **Development**: Local development with hot reload
2. **Testing**: Isolated test environment
3. **Staging**: Production-like staging environment
4. **Production**: Optimized production deployment
5. **Monitoring**: Observability stack deployment

## Expected Targets

```bash
make build          # Build all images
make build-dev      # Build development images
make build-prod     # Build production images
make test           # Run all tests in containers
make test-unit      # Run unit tests
make test-integration # Run integration tests
make security-scan  # Scan images for vulnerabilities
make deploy-dev     # Deploy to development
make deploy-staging # Deploy to staging
make deploy-prod    # Deploy to production
make logs           # View service logs
make shell          # Open shell in container
make clean          # Clean containers and images
```

## Sample Files to Create

### app/Dockerfile (Multi-stage)
```dockerfile
# Build stage
FROM golang:1.19-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY src/ ./src/
RUN CGO_ENABLED=0 GOOS=linux go build -o main ./src/

# Test stage
FROM builder AS tester
COPY tests/ ./tests/
RUN go test -v ./tests/...

# Security scan stage
FROM builder AS security
RUN apk add --no-cache git
RUN go install github.com/securecodewarrior/gosec/v2/cmd/gosec@latest
RUN gosec ./src/...

# Production stage
FROM alpine:3.18 AS production
RUN apk --no-cache add ca-certificates tzdata
WORKDIR /root/
COPY --from=builder /app/main .
EXPOSE 8080
CMD ["./main"]

# Development stage
FROM golang:1.19-alpine AS development
WORKDIR /app
RUN go install github.com/cosmtrek/air@latest
COPY go.mod go.sum ./
RUN go mod download
EXPOSE 8080
CMD ["air"]
```

### docker-compose.yml
```yaml
version: '3.8'

services:
  app:
    build:
      context: ./app
      target: ${BUILD_TARGET:-production}
    ports:
      - "8080:8080"
    environment:
      - DB_HOST=database
      - DB_PORT=5432
    depends_on:
      - database
    volumes:
      - ${APP_VOLUME:-/dev/null}:/app
    networks:
      - app-network

  database:
    build: ./database
    environment:
      - POSTGRES_DB=appdb
      - POSTGRES_USER=appuser
      - POSTGRES_PASSWORD=apppass
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - app-network

  nginx:
    build: ./nginx
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - app
    networks:
      - app-network

volumes:
  db_data:

networks:
  app-network:
    driver: bridge
```

### app/src/main.go
```go
package main

import (
    "fmt"
    "log"
    "net/http"
    "os"
)

func healthHandler(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    fmt.Fprintf(w, `{"status": "healthy", "service": "app"}`)
}

func main() {
    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }

    http.HandleFunc("/health", healthHandler)
    
    log.Printf("Server starting on port %s", port)
    log.Fatal(http.ListenAndServe(":"+port, nil))
}
```

## Multi-Stage Build Strategy

### Stage Optimization
1. **Base Image Selection**: Choose minimal base images
2. **Layer Caching**: Order instructions for optimal caching
3. **Multi-Architecture**: Build for different CPU architectures
4. **Build Arguments**: Parameterize builds for flexibility
5. **Security Hardening**: Remove unnecessary packages and users

### Testing Strategy
1. **Parallel Testing**: Run tests in parallel containers
2. **Test Data Management**: Seed test databases
3. **Test Isolation**: Ensure tests don't interfere
4. **Coverage Reporting**: Generate test coverage reports
5. **Performance Benchmarks**: Track performance metrics

## Testing Your Makefile

1. Build development environment: `make build-dev`
2. Run unit tests: `make test-unit`
3. Start development stack: `make deploy-dev`
4. Run integration tests: `make test-integration`
5. Build production images: `make build-prod`
6. Deploy to staging: `make deploy-staging`
7. Run security scans: `make security-scan`

## Advanced Challenges

1. **Kubernetes Deployment**: Add Kubernetes manifests
2. **Helm Charts**: Package application as Helm chart
3. **GitOps**: Implement GitOps deployment workflow
4. **Service Mesh**: Integrate with Istio or Linkerd
5. **Observability**: Add distributed tracing
6. **Chaos Engineering**: Add chaos testing capabilities
7. **Blue-Green Deployment**: Implement zero-downtime deployments