# Exercise 3: Multi-Language Project Manager

## Objective
Create a unified Makefile that manages a project containing Python, Node.js, and shell scripts with proper dependency management, testing, and deployment.

## Project Structure
```
multi_lang_project/
├── python/
│   ├── src/
│   │   ├── __init__.py
│   │   ├── main.py
│   │   └── utils.py
│   ├── tests/
│   │   └── test_main.py
│   ├── requirements.txt
│   └── setup.py
├── nodejs/
│   ├── src/
│   │   ├── index.js
│   │   └── lib/
│   │       └── helper.js
│   ├── tests/
│   │   └── test.js
│   ├── package.json
│   └── package-lock.json
├── shell/
│   ├── scripts/
│   │   ├── deploy.sh
│   │   ├── backup.sh
│   │   └── monitor.sh
│   └── tests/
│       └── test_scripts.sh
├── docker/
│   ├── Dockerfile.python
│   ├── Dockerfile.nodejs
│   └── docker-compose.yml
├── docs/
├── build/
└── Makefile
```

## Requirements

### Environment Management
1. **Python Environment**: Create and manage virtual environments
2. **Node.js Environment**: Install and manage npm dependencies
3. **Shell Environment**: Validate shell script syntax
4. **Docker Environment**: Build and manage containers
5. **Cross-Language Communication**: Enable inter-service communication

### Build and Test Features
1. **Python**: Install dependencies, run tests with pytest, lint with flake8
2. **Node.js**: Install packages, run tests with jest, lint with eslint
3. **Shell**: Validate syntax with shellcheck, run functional tests
4. **Integration Tests**: Test communication between components
5. **Performance Tests**: Benchmark each component

### Deployment Features
1. **Containerization**: Build Docker images for each component
2. **Orchestration**: Deploy with docker-compose
3. **Environment Configs**: Separate configs for dev/staging/prod
4. **Health Checks**: Verify all services are running
5. **Rollback**: Ability to rollback to previous version

## Expected Targets

```bash
make setup          # Setup all environments
make install        # Install all dependencies
make test           # Run all tests
make lint           # Lint all code
make build          # Build all components
make docker-build   # Build all Docker images
make deploy         # Deploy all services
make health-check   # Check service health
make clean          # Clean all artifacts
make docs           # Generate documentation
```

## Sample Files to Create

### python/src/main.py
```python
#!/usr/bin/env python3
"""Main Python application module."""

import sys
import json
from utils import get_system_info

def main():
    """Main application entry point."""
    print("Python service starting...")
    info = get_system_info()
    print(json.dumps(info, indent=2))
    return 0

if __name__ == "__main__":
    sys.exit(main())
```

### nodejs/src/index.js
```javascript
#!/usr/bin/env node
/**
 * Main Node.js application
 */

const express = require('express');
const { getSystemInfo } = require('./lib/helper');

const app = express();
const PORT = process.env.PORT || 3000;

app.get('/health', (req, res) => {
    res.json({ status: 'healthy', service: 'nodejs' });
});

app.get('/info', (req, res) => {
    res.json(getSystemInfo());
});

app.listen(PORT, () => {
    console.log(`Node.js service running on port ${PORT}`);
});
```

### shell/scripts/deploy.sh
```bash
#!/bin/bash
# Deployment script

set -euo pipefail

ENVIRONMENT=${1:-development}
VERSION=${2:-latest}

echo "Deploying version $VERSION to $ENVIRONMENT"

# Deployment logic here
case $ENVIRONMENT in
    development)
        echo "Deploying to development environment"
        ;;
    staging)
        echo "Deploying to staging environment"
        ;;
    production)
        echo "Deploying to production environment"
        ;;
    *)
        echo "Unknown environment: $ENVIRONMENT"
        exit 1
        ;;
esac
```

## Multi-Language Integration

### Communication Patterns
1. **HTTP APIs**: Node.js serves REST API, Python consumes it
2. **Message Queues**: Use Redis/RabbitMQ for async communication
3. **Shared Databases**: Common data storage
4. **File System**: Shared volumes for data exchange
5. **Environment Variables**: Configuration sharing

### Testing Strategy
1. **Unit Tests**: Test each language component separately
2. **Integration Tests**: Test cross-language communication
3. **Contract Tests**: Verify API contracts between services
4. **End-to-End Tests**: Full workflow testing
5. **Performance Tests**: Load testing across all services

## Testing Your Makefile

1. Run `make setup` to initialize all environments
2. Test individual components: `make test-python`, `make test-nodejs`
3. Test integration: `make test-integration`
4. Build containers: `make docker-build`
5. Deploy locally: `make deploy-local`
6. Run health checks: `make health-check`

## Advanced Challenges

1. **Microservices Architecture**: Deploy as separate services
2. **Service Discovery**: Implement service registration/discovery
3. **Monitoring**: Add logging, metrics, and tracing
4. **CI/CD Pipeline**: Integrate with Jenkins/GitHub Actions
5. **Security Scanning**: Scan dependencies for vulnerabilities
6. **Load Balancing**: Add load balancer configuration