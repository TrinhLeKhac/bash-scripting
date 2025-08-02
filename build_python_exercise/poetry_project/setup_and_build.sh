#!/bin/bash

# Poetry Project Setup and Build Script
# This script automates the complete Poetry build process:
# 1. Creates/recreates virtual environment using Poetry
# 2. Installs dependencies and builds package with Poetry
# 3. Tests the package installation and functionality
# 4. Runs demo to verify CLI works correctly

set -euo pipefail  # Exit on error, undefined vars, pipe failures

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NAME="poetry-demo"

echo "🚀 Setting up Poetry Project..."

# Add Poetry to PATH if it exists
export PATH="$HOME/.local/bin:$PATH"

# Check if poetry is available
if ! command -v poetry &> /dev/null; then
    echo "❌ Poetry not found. Please install Poetry first:"
    echo "curl -sSL https://install.python-poetry.org | python3 -"
    echo "Then restart your shell or run: export PATH=\"\$HOME/.local/bin:\$PATH\""
    exit 1
fi

echo "🔧 Poetry version: $(poetry --version)"

# Clean previous builds and virtual environment
echo "🧹 Cleaning previous builds..."
rm -rf dist/ build/ *.egg-info/ .coverage htmlcov/ .venv/

# Configure poetry virtual environment trong project folder
echo "📦 Configuring Poetry for in-project .venv..."
poetry config virtualenvs.in-project true
poetry config virtualenvs.create true

# Install dependencies
echo "📦 Installing dependencies..."
poetry install

# Show environment info
echo "📋 Environment information:"
poetry env info

# Run tests
echo "🧪 Running tests..."
poetry run pytest -v

# Run linting and formatting (non-blocking)
echo "🔍 Running code quality checks..."
if poetry run black --check src/ tests/; then
    echo "✅ Black formatting check passed"
else
    echo "⚠️  Black formatting issues found, continuing..."
fi

if poetry run mypy src/; then
    echo "✅ MyPy type checking passed"
else
    echo "⚠️  MyPy type checking issues found, continuing..."
fi

# Build the package
echo "🏗️  Building package with Poetry..."
poetry build

# Get the built package info
echo "📦 Built packages:"
ls -la dist/

# Test installation from wheel
echo "🧪 Testing wheel installation..."
WHEEL_FILE=$(ls dist/*.whl | head -n 1)
if [[ -n "$WHEEL_FILE" ]]; then
    # Create test environment and install wheel
    python3 -m venv test_env
    source test_env/bin/activate
    pip install "$WHEEL_FILE"
    
    echo "✅ Wheel installation successful"
    deactivate
    rm -rf test_env
else
    echo "❌ No wheel file found"
fi

# Demonstrate the built CLI application functionality
echo ""
echo "🎯 Demo Usage:"
echo "Command: poetry run poetry-demo --name 'Developer' --verbose"
poetry run poetry-demo --name "Developer" --verbose

echo ""
echo "Command: poetry run poetry-demo --url https://httpbin.org/json"
poetry run poetry-demo --url https://httpbin.org/json

echo ""
echo "Command: poetry run poetry-demo --help"
poetry run poetry-demo --help

# Show package info
echo ""
echo "📋 Package Information:"
poetry show --tree

echo ""
echo "✨ Setup completed successfully!"
echo "💡 Package built: $(ls dist/*.whl | head -n 1)"
echo "💡 To run CLI: poetry run poetry-demo --name 'Your Name'"
echo "💡 To run tests: poetry run pytest"
echo "💡 To format code: poetry run black ."
echo "💡 To install wheel: pip install $(ls dist/*.whl | head -n 1)"