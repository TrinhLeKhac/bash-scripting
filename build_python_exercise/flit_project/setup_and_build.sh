#!/bin/bash

# Flit Project Setup and Build Script
# This script automates the complete setup process:
# 1. Creates/recreates virtual environment
# 2. Installs flit and all dependencies
# 3. Builds the package (wheel + source distribution)
# 4. Runs demo to verify functionality

set -euo pipefail  # Exit on error, undefined vars, pipe failures

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$PROJECT_DIR/venv"

echo "🚀 Setting up Flit Project..."

# Remove old virtual environment if it exists to ensure clean setup
if [[ -d "$VENV_DIR" ]]; then
    echo "🗑️  Removing old virtual environment..."
    rm -rf "$VENV_DIR"
fi

# Create fresh virtual environment
echo "📦 Creating virtual environment..."
python3 -m venv "$VENV_DIR"

# Activate the virtual environment for all subsequent operations
source "$VENV_DIR/bin/activate"

# Upgrade pip to latest version for better dependency resolution
echo "⬆️  Upgrading pip..."
pip install --upgrade pip

# Install flit - the modern Python packaging tool
echo "🔧 Installing flit..."
pip install flit

# Install project in development mode with symlinks
# This allows editing source code without reinstalling
echo "📥 Installing project dependencies..."
flit install --symlink

# Build the package - creates both wheel (.whl) and source distribution (.tar.gz)
echo "🏗️  Building package..."
flit build

# Display build results and package information
echo "✅ Build completed!"
echo "📁 Built packages:"
ls -la dist/

# Demonstrate the built CLI application functionality
echo ""
echo "🎯 Demo Usage:"
echo "Command: flit-demo --name 'Developer' --verbose"
flit-demo --name "Developer" --verbose

echo ""
echo "Command: flit-demo --url https://httpbin.org/json"
flit-demo --url https://httpbin.org/json

echo ""
echo "Command: flit-demo --help"
flit-demo --help

echo ""
echo "✨ Setup completed successfully!"
echo "💡 Virtual environment: venv/"
echo "💡 Built packages: dist/"
echo "💡 To activate: source venv/bin/activate"
echo "💡 To install wheel: pip install dist/flit_demo-1.0.0-py3-none-any.whl"