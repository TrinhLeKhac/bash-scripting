#!/bin/bash

# Setuptools Project Setup and Build Script
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NAME="setuptools-demo"

echo "🚀 Setting up Setuptools Project..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf build/ dist/ *.egg-info/ .coverage htmlcov/ venv/

# Create virtual environment
echo "📦 Creating virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install dependencies
echo "📦 Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Install package in development mode
echo "📦 Installing package in development mode..."
pip install -e .

# Run tests
echo "🧪 Running tests..."
python -m pytest tests/ -v

# Build package
echo "🏗️  Building package with setuptools..."
python setup.py sdist bdist_wheel

# Test installation from wheel
echo "🧪 Testing wheel installation..."
WHEEL_FILE=$(ls dist/*.whl | head -n 1)
if [[ -n "$WHEEL_FILE" ]]; then
    (
        python3 -m venv test_env
        source test_env/bin/activate
        pip install "$WHEEL_FILE"
        echo "✅ Wheel installation successful"
    )
    rm -rf test_env
fi

# Demonstrate functionality
echo ""
echo "🎯 Demo Usage:"
echo "Command: setuptools-demo calc 10 5 --operation add"
setuptools-demo calc 10 5 --operation add

echo ""
echo "Command: setuptools-demo process 1 2 3 4 5"
setuptools-demo process 1 2 3 4 5

echo ""
echo "Command: setuptools-demo --help"
setuptools-demo --help

echo ""
echo "✨ Setup completed successfully!"
echo "💡 Package built: $(ls dist/*.whl | head -n 1)"
echo "💡 To run CLI: setuptools-demo calc 10 5 or setuptools-demo process 1 2 3"