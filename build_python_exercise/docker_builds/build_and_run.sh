#!/bin/bash

# Docker Build and Run Script
# This script automates the complete Docker build process:
# 1. Builds all Docker stages (builder, production, development)
# 2. Tests container functionality and health checks
# 3. Demonstrates different deployment scenarios
# 4. Cleans up temporary resources

set -euo pipefail  # Exit on error, undefined vars, pipe failures

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="demo-app"
REGISTRY="${REGISTRY:-localhost:5000}"

echo "🐳 Starting Docker Build Process..."

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker first."
    exit 1
fi

# Function to build specific target
build_target() {
    local target=$1
    local tag="${IMAGE_NAME}:${target}"
    
    echo "🏗️  Building ${target} stage..."
    docker build --target "$target" -t "$tag" .
    
    # Get image size
    local size=$(docker images --format "table {{.Size}}" "$tag" | tail -n 1)
    echo "📦 Built $tag - Size: $size"
}

# Function to test container
test_container() {
    local tag=$1
    local container_name="test-${tag//[^a-zA-Z0-9]/-}"
    
    echo "🧪 Testing container: $tag"
    
    # Run container in background
    docker run -d --name "$container_name" -p 8000:8000 "$tag" || {
        echo "❌ Failed to start container $tag"
        return 1
    }
    
    # Wait for container to start
    sleep 5
    
    # Check if container is running
    if docker ps | grep -q "$container_name"; then
        echo "✅ Container $container_name is running"
        
        # Test health endpoint (if available)
        if curl -f http://localhost:8000/health &>/dev/null; then
            echo "✅ Health check passed"
        else
            echo "⚠️  Health check not available or failed"
        fi
    else
        echo "❌ Container $container_name failed to start"
        docker logs "$container_name"
    fi
    
    # Cleanup test container
    docker stop "$container_name" &>/dev/null || true
    docker rm "$container_name" &>/dev/null || true
}

# Function to show image comparison
show_image_comparison() {
    echo ""
    echo "📊 Image Size Comparison:"
    echo "========================"
    docker images | grep "$IMAGE_NAME" | awk '{printf "%-30s %s\n", $1":"$2, $7}'
    echo ""
}

# Function to cleanup old images
cleanup_images() {
    echo "🧹 Cleaning up old images..."
    
    # Remove dangling images
    docker image prune -f &>/dev/null || true
    
    # Remove old versions of our images
    docker images | grep "$IMAGE_NAME" | grep -v "latest\|production\|development" | awk '{print $3}' | xargs -r docker rmi -f &>/dev/null || true
    
    echo "✅ Cleanup completed"
}

# Main build process
main() {
    local target="${1:-all}"
    
    case "$target" in
        "production"|"prod")
            build_target "production"
            test_container "${IMAGE_NAME}:production"
            ;;
        "development"|"dev")
            build_target "development"
            echo "🔧 Development image built. Run with: docker run -it -v \$(pwd):/app ${IMAGE_NAME}:development bash"
            ;;
        "builder")
            build_target "builder"
            echo "🔨 Builder image created for multi-stage builds"
            ;;
        "all"|*)
            echo "🚀 Building all Docker stages..."
            
            # Build all stages
            build_target "builder"
            build_target "production"
            build_target "development"
            
            # Test production image
            test_container "${IMAGE_NAME}:production"
            
            # Show comparison
            show_image_comparison
            
            # Demonstrate usage
            echo ""
            echo "🎯 Usage Examples:"
            echo "=================="
            echo "# Run production container:"
            echo "docker run -d -p 8000:8000 --name demo-prod ${IMAGE_NAME}:production"
            echo ""
            echo "# Run development container:"
            echo "docker run -it -p 8000:8000 -v \$(pwd):/app ${IMAGE_NAME}:development bash"
            echo ""
            echo "# Check container logs:"
            echo "docker logs demo-prod"
            echo ""
            echo "# Stop and remove containers:"
            echo "docker stop demo-prod && docker rm demo-prod"
            ;;
    esac
    
    # Optional cleanup
    if [[ "${CLEANUP:-true}" == "true" ]]; then
        cleanup_images
    fi
    
    echo ""
    echo "✨ Docker build process completed!"
    echo "💡 Images built: $(docker images | grep "$IMAGE_NAME" | wc -l)"
    echo "💡 To push to registry: docker tag ${IMAGE_NAME}:production ${REGISTRY}/${IMAGE_NAME}:latest"
    echo "💡 To run production: docker run -p 8000:8000 ${IMAGE_NAME}:production"
}

# Handle script arguments
if [[ $# -eq 0 ]]; then
    main "all"
else
    main "$1"
fi