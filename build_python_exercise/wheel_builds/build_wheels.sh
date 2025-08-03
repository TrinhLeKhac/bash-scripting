#!/bin/bash

# Wheel Builds Project Setup and Build Script
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NAME="wheel-demo"

echo "🚀 Setting up Wheel Builds Project..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf build/ dist/ *.egg-info/ .coverage htmlcov/ venv/ test_env/

# Create virtual environment
echo "📦 Creating virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install build dependencies
echo "📦 Installing build dependencies..."
pip install --upgrade pip
pip install build wheel setuptools>=65.0.0
pip install -r requirements.txt

# Install package in development mode
echo "📦 Installing package in development mode..."
pip install -e .

# Create wheel-demo executable
echo "🔧 Creating wheel-demo executable..."
cat > wheel-demo << 'EOF'
#!/bin/bash
# Auto-generated wheel-demo executable
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_PATH="$SCRIPT_DIR/venv"

if [[ -f "$VENV_PATH/bin/wheel-demo" ]]; then
    "$VENV_PATH/bin/wheel-demo" "$@"
else
    echo "Error: wheel-demo not found in virtual environment"
    echo "Please run ./build_wheels.sh first"
    exit 1
fi
EOF

chmod +x wheel-demo
echo "✅ Created executable: ./wheel-demo"

# Note: To use wheel-demo globally, add to PATH manually:
# export PATH="$PROJECT_DIR:$PATH"
echo "💡 To use globally: export PATH=\"$PROJECT_DIR:\$PATH\""

# Run tests
echo "🧪 Running tests..."
python -m pytest tests/ -v

# Build wheels using modern build system
echo "🏗️  Building wheels with modern build tools..."
python -m build --wheel

# Validate wheel integrity
echo "🔍 Validating wheel integrity..."
WHEEL_FILE=$(ls dist/*.whl | head -n 1)
if [[ -n "$WHEEL_FILE" ]]; then
    echo "📋 Wheel contents:"
    python -m zipfile -l "$WHEEL_FILE"
    
    echo ""
    echo "📊 Wheel metadata:"
    python -c "
import sys
sys.path.insert(0, 'src')
from wheel_demo.wheel_tools import WheelValidator
validator = WheelValidator()
print(f'Wheel file: $WHEEL_FILE')
print(f'Valid wheel: {validator.validate_wheel_file(\"$WHEEL_FILE\")}')
"
fi

# Test wheel installation
echo "🧪 Testing wheel installation..."
if [[ -n "$WHEEL_FILE" ]]; then
    (
        python3 -m venv test_env
        source test_env/bin/activate
        pip install "$WHEEL_FILE"
        
        echo "✅ Wheel installation successful"
        echo "🧪 Testing CLI availability..."
        wheel-demo --help > /dev/null && echo "✅ CLI working correctly"
    )
    rm -rf test_env
fi

# Demonstrate functionality
echo ""
echo "🎯 Demo Usage:"
echo "Command: wheel-demo info --text 'Hello World'"
wheel-demo info --text "Hello World"

echo ""
echo "Command: wheel-demo utils --hash 'test data'"
wheel-demo utils --hash "test data"

echo ""
echo "Command: wheel-demo validate --check-format"
wheel-demo validate --check-format

echo ""
echo "Command: wheel-demo --help"
wheel-demo --help

echo ""
echo "✨ Wheel build completed successfully!"
echo "💡 Wheel built: $(ls dist/*.whl | head -n 1)"
echo "💡 To install: pip install $(ls dist/*.whl | head -n 1)"
echo "💡 To run CLI: wheel-demo info --text 'Your Text'"
echo "💡 Executable created: ./wheel-demo (works without activating venv)"
echo "💡 To use globally: export PATH=\"$PROJECT_DIR:\$PATH\""

echo ""
echo "🎆 Testing standalone executable:"
echo "Command: ./wheel-demo info --text 'Standalone Test'"
./wheel-demo info --text "Standalone Test"

echo ""
echo "🌟 Testing venv CLI directly:"
echo "Command: venv/bin/wheel-demo info --text 'Direct Test'"
venv/bin/wheel-demo info --text "Direct Test"

# Show wheel information
echo ""
echo "📊 Wheel Information:"
python -c "
import os
wheel_file = '$(ls dist/*.whl | head -n 1)'
if os.path.exists(wheel_file):
    size = os.path.getsize(wheel_file)
    print(f'File: {wheel_file}')
    print(f'Size: {size:,} bytes')
    print(f'Type: Universal Python wheel')
"