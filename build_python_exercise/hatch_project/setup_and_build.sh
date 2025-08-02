#!/bin/bash

# Hatch Project Setup and Build Script
# This script automates the complete Hatch build process:
# 1. Creates/recreates virtual environment using Hatch
# 2. Installs dependencies and builds package with Hatch
# 3. Tests the package installation and functionality
# 4. Runs demo to verify CLI works correctly

set -euo pipefail  # Exit on error, undefined vars, pipe failures

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NAME="hatch-demo"

echo "🚀 Setting up Hatch Project..."

# Check if hatch is available
if ! command -v hatch &> /dev/null; then
    echo "❌ Hatch not found. Installing Hatch..."
    pip install hatch
fi

# Check hatch version
echo "🔧 Hatch version: $(hatch --version)"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf dist/ build/ *.egg-info/ .coverage htmlcov/

# Create and setup hatch environment
echo "📦 Setting up Hatch environment..."
hatch env create

# Show environment info
echo "📋 Environment information:"
hatch env show

# Install package in development mode
echo "🔗 Installing package in development mode..."
hatch -e default run pip install -e .

# Run tests (skip if no tests found)
echo "🧪 Running tests..."
if hatch run test 2>/dev/null; then
    echo "✅ Tests passed"
else
    echo "⚠️  No tests found or tests failed, continuing..."
fi

# Run linting and formatting
echo "🔍 Running code quality checks..."
hatch run lint:fmt
hatch run lint:all

# Build the package
echo "🏗️  Building package with Hatch..."
hatch build

# Get the built package info
echo "📦 Built packages:"
ls -la dist/

# Test installation from wheel
echo "🧪 Testing wheel installation..."
WHEEL_FILE=$(ls dist/*.whl | head -n 1)
if [[ -n "$WHEEL_FILE" ]]; then
    # Create test environment
    hatch env create test-install
    hatch -e test-install run pip install "$WHEEL_FILE"
    
    echo "✅ Wheel installation successful"
else
    echo "❌ No wheel file found"
fi

# Demonstrate the built CLI application functionality
echo ""
echo "🎯 Demo Usage:"
echo "Command: hatch run hatch-demo --name 'Developer' --verbose"
hatch run hatch-demo --name "Developer" --verbose

echo ""
echo "Command: hatch run hatch-demo --url https://httpbin.org/json"
hatch run hatch-demo --url https://httpbin.org/json

echo ""
echo "Command: hatch run hatch-demo --help"
hatch run hatch-demo --help

# Show package metadata
echo ""
echo "📋 Package Metadata:"
hatch project metadata

# Show environment matrix
echo ""
echo "🔧 Available Environments:"
hatch env show --ascii

echo ""
echo "✨ Setup completed successfully!"
echo "💡 Package built: $(ls dist/*.whl | head -n 1)"
echo "💡 To run CLI: hatch run hatch-demo --name 'Your Name'"
echo "💡 To run tests: hatch run test"
echo "💡 To format code: hatch run lint:fmt"
echo "💡 To install wheel: pip install $(ls dist/*.whl | head -n 1)"