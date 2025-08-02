# Flit Demo Package

A lightweight demonstration of modern Python packaging using Flit.

## Features

- **Lightweight CLI**: Simple command-line interface with Click
- **HTTP Requests**: Data fetching capabilities with requests
- **Modern Packaging**: Uses pyproject.toml and Flit build system
- **Type Hints**: Full type annotation support
- **Cross-platform**: Works on Windows, macOS, Linux

## Quick Start

### Automated Setup & Build (One Command)
```bash
# Run automated setup script - creates venv, installs dependencies, builds and demos
bash setup_and_build.sh
```

### Manual Setup (if needed)
```bash
python3 -m venv venv
source venv/bin/activate
pip install flit
flit install --symlink
flit build
```

### Install from Wheel (Production Deployment)

#### Check Built Packages
```bash
# List built packages and check wheel file info
ls -la dist/ && echo "Wheel file info:" && file dist/*.whl
```

#### Install from Wheel
```bash
# Or install in a fresh environment
python3 -m venv production_env
source production_env/bin/activate
pip install dist/flit_demo-1.0.0-py3-none-any.whl
```

#### Why Install from Wheel?

**Advantages of wheel installation:**
- **Faster Installation**: Pre-built binary, no compilation needed
- **Production Ready**: Stable, tested package for deployment
- **Dependency Isolation**: Clean installation without development dependencies
- **Portable**: Can be distributed and installed on any compatible system
- **Consistent**: Same package across different environments
- **Offline Installation**: Can be installed without internet access

**Use Cases:**
- **Production Deployment**: Install on servers without build tools
- **Distribution**: Share package with other developers/users
- **CI/CD Pipelines**: Fast, reliable installation in automated workflows
- **Docker Images**: Lightweight installation in containers

## Usage

### Basic Commands
```bash
# Simple greeting
flit-demo --name "Python Developer"

# Fetch data from URL
flit-demo --url https://httpbin.org/json

# Verbose output
flit-demo --name "Developer" --verbose

# Fetch with verbose
flit-demo --url https://api.github.com/users/octocat --verbose

# Show help
flit-demo --help
```

### Example Output
```bash
$ flit-demo --name "Flit User" --url https://httpbin.org/json --verbose
Flit Demo v1.0.0
Author: Demo Author
Hello, Flit User!
Fetching data from: https://httpbin.org/json
Status: 200
Content-Type: application/json
Response data:
  slideshow: {'author': 'Yours Truly', 'date': 'date of publication', 'slides': [{'title': 'Wake up to WonderWidgets!', 'type': 'all'}, {'items': ['Why <em>WonderWidgets</em> are great', 'Who <em>buys</em> WonderWidgets'], 'title': 'Overview', 'type': 'all'}], 'title': 'Sample Slide Show'}
Demo completed successfully!
```

## Package Structure
```
flit_project/
├── pyproject.toml           # Modern packaging configuration
├── LICENSE                  # MIT license
├── README.md               # This documentation
├── flit_demo/              # Source package
│   └── __init__.py         # Main module with CLI
└── tests/                  # Test directory (optional)
```

## Development

### Install Development Dependencies
```bash
# Activate virtual environment
source venv/bin/activate

# Install with test dependencies
flit install --symlink --extras test

# Install with dev dependencies  
flit install --symlink --extras dev

# Install all optional dependencies
flit install --symlink --extras test,dev
```

### Build and Test
```bash
# Run tests
pytest

# Format code
black flit_demo/

# Type checking
mypy flit_demo/

# Build package
flit build

# Check build results
ls -la dist/
# flit_demo-1.0.0-py3-none-any.whl
# flit_demo-1.0.0.tar.gz
```

## Dependencies

### Runtime
- **Python**: >=3.8
- **requests**: >=2.28.0 (HTTP client)
- **click**: >=8.0.0 (CLI framework)

### Development (Optional)
- **pytest**: >=7.0.0 (testing)
- **pytest-cov**: >=4.0.0 (coverage)
- **black**: >=22.0.0 (code formatting)
- **flake8**: >=5.0.0 (linting)
- **mypy**: >=1.0.0 (type checking)

## Why Flit?

### Advantages over setuptools:
- **Simpler**: No setup.py needed, just pyproject.toml
- **Faster**: Lightweight build process
- **Modern**: Uses PEP 517/518 standards
- **Clean**: Automatic version from `__version__`
- **Minimal**: Less boilerplate code

### Comparison:
```python
# setup.py (old way) - ~50 lines
from setuptools import setup
setup(
    name="flit-demo",
    version="1.0.0",
    # ... many more lines
)

# pyproject.toml (modern way) - ~20 lines
[project]
name = "flit-demo"
dependencies = ["requests>=2.28.0", "click>=8.0.0"]
```

## License

MIT License - see LICENSE file for details.

## Links

- **Home**: https://github.com/example/flit-demo
- **Documentation**: https://flit-demo.readthedocs.io
- **Flit Documentation**: https://flit.pypa.io/