# Wheel Builds Demo

Comprehensive Python wheel building demonstration focusing on modern wheel distribution and packaging.

## Overview

This project demonstrates wheel-focused Python packaging, including:
- Direct wheel building with modern tools
- Optimized wheel distribution
- Cross-platform wheel compatibility
- Wheel metadata and entry points
- Automated wheel testing and validation

## Project Structure

```
wheel_builds/
├── src/
│   └── wheel_demo/
│       ├── __init__.py          # Package initialization
│       ├── cli.py               # Command-line interface
│       ├── core.py              # Core functionality
│       ├── utils.py             # Utilities
│       └── wheel_tools.py       # Wheel-specific tools
├── tests/
│   ├── test_core.py             # Core functionality tests
│   ├── test_utils.py            # Utilities tests
│   └── test_wheel_tools.py      # Wheel tools tests
├── pyproject.toml               # Modern Python packaging config
├── requirements.txt             # Project dependencies
├── build_wheels.sh              # Automated wheel build script
├── README.md                    # This documentation
└── LICENSE                      # MIT license
```

## Features

### Wheel-Specific Features
- **Modern pyproject.toml configuration** for wheel building
- **Optimized wheel metadata** and tags
- **Cross-platform wheel support** (universal wheels)
- **Wheel validation tools** and integrity checks
- **Entry points** for CLI applications

### Development Tools
- **Direct wheel building** with build module
- **Wheel inspection utilities**
- **Automated testing** with pytest
- **Wheel distribution** and installation testing

## Quick Start

### Using the Automated Build Script

```bash
# Make the script executable
chmod +x build_wheels.sh

# Run the complete wheel build process
./build_wheels.sh
```

**What the script does:**
1. 🧹 Cleans previous builds and environments
2. 📦 Creates virtual environment
3. 📦 Installs build dependencies
4. 🏗️ Builds wheels using modern build tools
5. 🔍 Validates wheel integrity
6. 🧪 Tests wheel installation
7. 🎯 Demonstrates CLI functionality

### Manual Wheel Building

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install build dependencies
pip install build wheel

# Build wheel
python -m build --wheel

# Install wheel
pip install dist/*.whl
```

## Usage Examples

### Command Line Interface

```bash
# Wheel information
wheel-demo info --file data.txt

# Wheel validation
wheel-demo validate --wheel dist/wheel_demo-1.0.0-py3-none-any.whl

# Utility functions
wheel-demo utils --hash "hello world"

# Show help
wheel-demo --help
```

### Python API

```python
from wheel_demo.core import WheelProcessor
from wheel_demo.wheel_tools import WheelValidator
from wheel_demo.utils import hash_string

# Core functionality
processor = WheelProcessor()
result = processor.process_data([1, 2, 3, 4, 5])

# Wheel validation
validator = WheelValidator()
is_valid = validator.validate_wheel("path/to/wheel.whl")

# Utilities
hash_value = hash_string("test data")
```

## Development Workflow

### Building Wheels

```bash
# Build wheel only
python -m build --wheel

# Build both source and wheel
python -m build

# Check built wheels
ls dist/
# Output:
# wheel_demo-1.0.0-py3-none-any.whl
```

### Testing Wheels

```bash
# Run all tests
python -m pytest tests/ -v

# Test specific functionality
python -m pytest tests/test_wheel_tools.py -v

# Test with coverage
python -m pytest tests/ --cov=wheel_demo
```

### Wheel Validation

```bash
# Check wheel contents
python -m zipfile -l dist/wheel_demo-1.0.0-py3-none-any.whl

# Validate wheel
python -m wheel unpack dist/wheel_demo-1.0.0-py3-none-any.whl

# Install and test
pip install dist/wheel_demo-1.0.0-py3-none-any.whl
wheel-demo --help
```

## Dependencies

### Build Dependencies
- **build>=0.8.0** - Modern Python build system
- **wheel>=0.37.0** - Wheel building support
- **setuptools>=65.0.0** - Package building tools

### Runtime Dependencies
- **click>=8.0.0** - Command line interface
- **requests>=2.28.0** - HTTP requests
- **hashlib** - Built-in hashing utilities

### Development Dependencies
- **pytest>=6.0.0** - Testing framework
- **pytest-cov>=4.0.0** - Coverage reporting

## Wheel Building Details

### Modern Build System

The project uses `pyproject.toml` with the modern build system:

```toml
[build-system]
requires = ["setuptools>=65.0.0", "wheel>=0.37.0"]
build-backend = "setuptools.build_meta"

[project]
name = "wheel-demo"
version = "1.0.0"
description = "Wheel building demonstration"
```

### Build Script Features

The `build_wheels.sh` script provides:

1. **Environment Setup**: Clean virtual environment
2. **Modern Building**: Uses `python -m build` instead of setup.py
3. **Wheel Validation**: Checks wheel integrity
4. **Cross-platform**: Builds universal wheels
5. **Testing**: Validates installation and functionality

## Wheel vs Other Formats

### Advantages of Wheels
- **Faster installation** - Pre-built, no compilation needed
- **Consistent** - Same wheel works across compatible platforms
- **Metadata rich** - Contains detailed package information
- **Cacheable** - Can be cached by pip for faster installs
- **Secure** - Signed wheels for integrity verification

### When to Use Wheels
- Distribution to end users
- CI/CD pipelines
- Package repositories (PyPI)
- Corporate package management
- Cross-platform deployment

## Troubleshooting

### Common Issues

1. **Build failures**
   ```bash
   pip install --upgrade build wheel setuptools
   ```

2. **Wheel validation errors**
   ```bash
   python -m wheel unpack dist/*.whl
   ```

3. **Installation issues**
   ```bash
   pip install --force-reinstall dist/*.whl
   ```

### Debug Commands

```bash
# Check wheel contents
python -m zipfile -l dist/*.whl

# Validate wheel format
python -c "import wheel; print('Wheel support OK')"

# Test CLI installation
which wheel-demo

# Check package metadata
pip show wheel-demo
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Run the test suite: `python -m pytest tests/ -v`
5. Build wheels: `./build_wheels.sh`
6. Submit a pull request

## License

MIT License - see LICENSE file for details.

This wheel builds demo showcases modern Python packaging with focus on wheel distribution, providing efficient and reliable package deployment across different platforms and environments.