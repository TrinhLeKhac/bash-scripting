#!/bin/bash

# Conda Project Setup and Build Script
# This script automates the complete conda package setup process:
# 1. Creates/recreates conda environment
# 2. Installs dependencies and builds conda package
# 3. Tests the package installation and functionality
# 4. Runs demo to verify CLI works correctly

set -euo pipefail  # Exit on error, undefined vars, pipe failures

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_NAME="conda-demo-env"

echo "🚀 Setting up Conda Project..."

# Check if conda is available
if ! command -v conda &> /dev/null; then
    echo "❌ Conda not found. Please install Anaconda or Miniconda first."
    exit 1
fi

# Remove old environment if it exists
if conda env list | grep -q "$ENV_NAME"; then
    echo "🗑️  Removing old conda environment..."
    conda env remove -n "$ENV_NAME" -y
fi

# Create fresh conda environment with Python and build tools
echo "📦 Creating conda environment..."
conda create -n "$ENV_NAME" python=3.11 conda-build anaconda-client -y

# Activate the environment
echo "🔧 Activating environment..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate "$ENV_NAME"

# Install package dependencies
echo "📥 Installing package dependencies..."
pip install requests click pydantic

# Install package in development mode
echo "🔗 Installing package in development mode..."
pip install -e .

# Build conda package
echo "🏗️  Building conda package..."
conda build . --output-folder ./conda-dist

# Get the built package path
PACKAGE_PATH=$(conda build . --output)
echo "📦 Built package: $PACKAGE_PATH"

# Install the built package in a test environment
echo "🧪 Testing package installation..."
conda create -n "test-$ENV_NAME" python=3.11 -y
conda activate "test-$ENV_NAME"
conda install "$PACKAGE_PATH" -y

# Display build results
echo "✅ Build completed!"
echo "📁 Built packages:"
ls -la conda-dist/

# Demonstrate the built CLI application functionality
echo ""
echo "🎯 Demo Usage:"
echo "Command: conda-demo hello --name 'Developer' --debug"
conda-demo hello --name "Developer" --debug

echo ""
echo "Command: conda-demo fetch --url https://httpbin.org/json"
conda-demo fetch --url https://httpbin.org/json

echo ""
echo "Command: conda-demo info"
conda-demo info

echo ""
echo "Command: conda-demo --help"
conda-demo --help

echo ""
echo "✨ Setup completed successfully!"
echo "💡 Conda environment: $ENV_NAME"
echo "💡 Built packages: conda-dist/"
echo "💡 To activate: conda activate $ENV_NAME"
echo "💡 To install: conda install ./conda-dist/linux-64/conda-demo-1.0.0-py311_0.tar.bz2"