# Hatch Demo Package

A comprehensive demonstration of modern Python packaging using Hatch build system with automated development workflow and advanced tooling integration.

## Features

- **Modern Build System**: Uses Hatch for packaging and environment management
- **CLI Application**: Command-line interface with Click and data validation
- **Data Validation**: Input validation with Pydantic models
- **HTTP Requests**: Data fetching capabilities with requests
- **Code Quality**: Integrated linting, formatting, and type checking
- **Testing**: Automated testing with pytest and coverage
- **Environment Management**: Isolated development environments with Hatch

## Quick Start

### Automated Setup & Build (One Command)
```bash
# Run automated setup script - creates environments, builds and demos
bash setup_and_build.sh
```

### Manual Setup (if needed)
```bash
# Install Hatch
pip install hatch

# Create environment and install dependencies
hatch env create
hatch -e default run pip install -e .

# Build package
hatch build
```

### Install from Built Package (Production Deployment)

#### Check Built Packages
```bash
# List built packages and check package metadata
ls -la dist/ && echo "Package metadata:" && hatch project metadata
```

#### Install from Wheel
```bash
# Install from wheel in fresh environment
pip install dist/hatch_demo-1.0.0-py3-none-any.whl

# Or create isolated environment
hatch env create production
hatch -e production run pip install dist/hatch_demo-1.0.0-py3-none-any.whl
```

#### Why Install from Hatch-built Package?

**Advantages of Hatch packaging:**
- **Modern Standards**: Uses latest PEP 517/518 build standards
- **Environment Isolation**: Complete dependency management with Hatch environments
- **Development Workflow**: Integrated testing, linting, and formatting
- **Reproducible Builds**: Consistent builds across different systems
- **Metadata Rich**: Comprehensive package metadata and configuration
- **Tool Integration**: Seamless integration with modern Python tooling

**Use Cases:**
- **Modern Development**: Streamlined development workflow with integrated tools
- **CI/CD Pipelines**: Standardized build and test processes
- **Package Distribution**: Professional package distribution to PyPI
- **Team Development**: Consistent development environments across team
- **Quality Assurance**: Built-in code quality and testing tools

## Usage

### Basic Commands
```bash
# Simple greeting
hatch-demo --name "Python Developer"

# Fetch data from URL
hatch-demo --url https://httpbin.org/json

# Verbose output with configuration details
hatch-demo --name "Developer" --verbose

# Fetch with verbose output
hatch-demo --url https://api.github.com/users/octocat --verbose

# Show help and version
hatch-demo --help
hatch-demo --version
```

### Example Output
```bash
$ hatch-demo --name "Hatch User" --url https://httpbin.org/json --verbose
Hatch Demo v1.0.0
Configuration: {'name': 'Hatch User', 'url': 'https://httpbin.org/json', 'verbose': True}
Hello, Hatch User!
Fetching data from: https://httpbin.org/json
Status: 200
Content-Type: application/json
Response data:
  slideshow: {'author': 'Yours Truly', 'date': 'date of publication', 'slides': [...]}
Demo completed successfully!
```

## Package Structure
```
hatch_project/
├── pyproject.toml           # Modern packaging configuration with Hatch
├── setup_and_build.sh       # Automated build script
├── README.md               # This documentation
└── src/hatch_demo/         # Source package
    ├── __init__.py         # Package initialization
    ├── __about__.py        # Version information
    └── cli.py              # CLI implementation
```

## Development

### Hatch Environment Management
```bash
# Create default environment
hatch env create

# Show all environments
hatch env show

# Run commands in specific environment
hatch -e default run python --version
hatch -e lint run black --version

# Remove environment
hatch env remove default
```

### Development Workflow
```bash
# Install in development mode
hatch -e default run pip install -e .

# Run tests
hatch run test

# Run tests with coverage
hatch run test-cov

# Format code
hatch run lint:fmt

# Run all linting checks
hatch run lint:all

# Type checking
hatch run lint:typing
```

### Build and Test
```bash
# Build package (wheel + sdist)
hatch build

# Build only wheel
hatch build --target wheel

# Build only source distribution
hatch build --target sdist

# Check build results
ls -la dist/
# hatch_demo-1.0.0-py3-none-any.whl
# hatch_demo-1.0.0.tar.gz
```

## Dependencies

### Runtime
- **Python**: >=3.8
- **requests**: >=2.28.0 (HTTP client)
- **click**: >=8.0.0 (CLI framework)
- **pydantic**: >=1.10.0 (data validation)

### Optional Dependencies
- **CLI extras**: rich, typer (enhanced CLI features)
- **Development**: pytest, black, ruff, mypy (development tools)
- **Documentation**: sphinx, sphinx-rtd-theme (documentation)

### Build System
- **Hatch**: Modern Python packaging and environment management
- **Hatchling**: Build backend for Hatch

## Why Hatch?

### Advantages over traditional tools:
- **Modern Standards**: Built on PEP 517/518 standards
- **Environment Management**: Integrated virtual environment management
- **Tool Integration**: Built-in support for testing, linting, formatting
- **Reproducible**: Consistent builds and environments
- **Configuration**: Single pyproject.toml configuration file
- **Performance**: Fast builds and environment creation

### Comparison:
```python
# Traditional approach
pip install virtualenv
virtualenv venv
source venv/bin/activate
pip install -e .
pip install pytest black mypy
python -m pytest
black .
mypy .

# Hatch approach
hatch env create
hatch run test
hatch run lint:fmt
hatch run lint:all
```

## Advanced Features

### Environment Matrix
```bash
# Test across multiple Python versions
hatch run +py=3.8,3.9,3.10,3.11 test

# Run in specific environment
hatch -e lint run black --check .
```

### Custom Scripts
```bash
# Defined in pyproject.toml [tool.hatch.envs.default.scripts]
hatch run test           # Run pytest
hatch run test-cov       # Run with coverage
hatch run cov-report     # Generate coverage report
```

### Build Customization
```toml
[tool.hatch.build.targets.wheel]
packages = ["src/hatch_demo"]

[tool.hatch.build.targets.sdist]
include = ["/src", "/tests"]
```

## Code Quality

### Integrated Tools
- **Black**: Code formatting
- **Ruff**: Fast Python linter
- **MyPy**: Static type checking
- **Pytest**: Testing framework
- **Coverage**: Code coverage analysis

### Quality Commands
```bash
# Format code
hatch run lint:fmt

# Check style
hatch run lint:style

# Type checking
hatch run lint:typing

# Run all quality checks
hatch run lint:all
```

## Testing

### Test Commands
```bash
# Run tests
hatch run test

# Run with coverage
hatch run test-cov

# Generate HTML coverage report
hatch run cov-html

# View coverage report
open htmlcov/index.html
```

### Test Configuration
- **pytest**: Test runner with advanced features
- **pytest-cov**: Coverage integration
- **Configuration**: Defined in pyproject.toml

## Getting Started

### Prerequisites
```bash
# Check Python version
python --version  # Should be >=3.8

# Install Hatch
pip install hatch

# Verify installation
hatch --version
```

### Quick Setup
```bash
# Clone and setup
git clone <repository>
cd hatch_project

# One-command setup
bash setup_and_build.sh

# Or manual setup
hatch env create
hatch -e default run pip install -e .
hatch build
```

### Learning Path
1. **Run automated setup** to see Hatch in action
2. **Explore pyproject.toml** to understand modern Python packaging
3. **Try environment management** with different Hatch environments
4. **Use integrated tools** for development workflow
5. **Build and distribute** packages with professional tooling

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Test and Build
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.8", "3.9", "3.10", "3.11"]
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      - name: Install Hatch
        run: pip install hatch
      - name: Run tests
        run: hatch run test
      - name: Build package
        run: hatch build
```

### Publishing to PyPI
```bash
# Build package
hatch build

# Publish to PyPI (requires authentication)
hatch publish

# Publish to test PyPI
hatch publish --repo test
```

## License

MIT License - see LICENSE file for details.

## Links

- **Hatch Documentation**: https://hatch.pypa.io/
- **Modern Python Packaging**: https://packaging.python.org/
- **PEP 517**: https://peps.python.org/pep-0517/
- **PEP 518**: https://peps.python.org/pep-0518/