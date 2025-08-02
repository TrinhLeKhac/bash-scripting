# Setuptools Demo

Comprehensive Python packaging demonstration using setuptools - the traditional and widely-used Python packaging tool.

## Overview

This project demonstrates modern Python packaging practices using setuptools, including:
- Package structure with src layout
- CLI application development
- Data processing and machine learning utilities
- Comprehensive testing with pytest
- Automated build and deployment

## Project Structure

```
setuptools_project/
├── src/
│   └── setuptools_demo/
│       ├── __init__.py          # Package initialization
│       ├── cli.py               # Command-line interface
│       ├── core.py              # Core functionality
│       ├── data_processor.py    # Data processing utilities
│       ├── ml_utils.py          # Machine learning helpers
│       └── utils.py             # General utilities
├── tests/
│   ├── test_core.py             # Core functionality tests
│   ├── test_data_processor.py   # Data processing tests
│   └── test_ml_utils.py         # ML utilities tests
├── setup.py                     # Setuptools configuration
├── requirements.txt             # Project dependencies
├── setup_and_build.sh          # Automated build script
├── README.md                    # This documentation
└── LICENSE                      # MIT license
```

## Features

### Core Functionality
- **Traditional setuptools packaging** with setup.py configuration
- **Src layout structure** for better package organization
- **CLI application** with argparse for command-line interaction
- **Data processing utilities** for CSV and JSON handling
- **Machine learning helpers** including:
  - Simple Linear Regression
  - K-Means Clustering
  - Data splitting utilities
  - Model evaluation metrics

### Development Tools
- **Comprehensive testing** with pytest
- **Development dependencies** management
- **Automated build process** with shell script
- **Package distribution** (source and wheel)

## Quick Start

### Using the Automated Build Script

The easiest way to set up and test the project:

```bash
# Make the script executable (if not already)
chmod +x setup_and_build.sh

# Run the complete setup and build process
./setup_and_build.sh
```

**What the script does:**
1. 🧹 Cleans previous builds and virtual environments
2. 📦 Creates fresh virtual environment
3. 📦 Installs dependencies from requirements.txt
4. 📦 Installs package in development mode
5. 🧪 Runs comprehensive test suite with verbose output
6. 🏗️ Builds both source distribution (.tar.gz) and wheel (.whl)
7. 🧪 Tests wheel installation in isolated environment
8. 🎯 Demonstrates CLI functionality

### Manual Installation

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Install in development mode
pip install -e .
```

## Usage Examples

### Command Line Interface

```bash
# Basic greeting
setuptools-demo --name "Developer"

# Data processing
setuptools-demo --process data.csv

# Machine learning workflow
setuptools-demo --train model.pkl

# Show all available options
setuptools-demo --help
```

### Python API

```python
from setuptools_demo.core import greet_user
from setuptools_demo.ml_utils import SimpleLinearRegression
from setuptools_demo.data_processor import CSVProcessor

# Core functionality
result = greet_user("Alice")

# Machine learning
model = SimpleLinearRegression()
model.fit([1, 2, 3, 4], [2, 4, 6, 8])
predictions = model.predict([5, 6])

# Data processing
processor = CSVProcessor()
data = processor.load_csv("data.csv")
```

## Development Workflow

### Running Tests

```bash
# Run all tests with verbose output
python -m pytest tests/ -v

# Run specific test file
python -m pytest tests/test_ml_utils.py -v

# Run with coverage report
python -m pytest tests/ --cov=setuptools_demo
```

### Building Packages

```bash
# Build source distribution and wheel
python setup.py sdist bdist_wheel

# Check built packages
ls dist/
# Output:
# setuptools_demo-1.0.0.tar.gz      # Source distribution
# setuptools_demo-1.0.0-py3-none-any.whl  # Wheel distribution
```

### Package Installation Testing

```bash
# Test wheel installation
pip install dist/setuptools_demo-1.0.0-py3-none-any.whl

# Test source distribution
pip install dist/setuptools_demo-1.0.0.tar.gz
```

## Dependencies

### Core Dependencies
- **requests>=2.28.0** - HTTP library for API calls
- **click>=8.0.0** - Command line interface creation
- **pydantic>=1.10.0** - Data validation and settings

### Optional Dependencies
- **rich>=12.0.0** - Beautiful terminal output
- **typer>=0.7.0** - Modern CLI applications

### Development Dependencies
- **pytest>=6.0.0** - Testing framework
- **wheel>=0.37.0** - Wheel building support

## Testing

The project includes comprehensive tests covering:

- **Core functionality tests** (test_core.py)
- **Data processing tests** (test_data_processor.py)
- **Machine learning tests** (test_ml_utils.py)
  - Linear regression functionality
  - K-means clustering
  - Data splitting utilities
  - Model evaluation metrics
  - Integration workflows

### Test Coverage
- Unit tests for all major components
- Integration tests for complete workflows
- Error handling and edge case testing
- Mock testing for external dependencies

## Build Script Details

The `setup_and_build.sh` script provides a complete automated workflow:

```bash
#!/bin/bash
# Setuptools Project Setup and Build Script

# Key features:
# - Environment isolation with virtual environments
# - Dependency management
# - Automated testing
# - Package building (source + wheel)
# - Installation verification
# - CLI demonstration
```

**Script phases:**
1. **Cleanup**: Removes old builds and environments
2. **Setup**: Creates virtual environment and installs dependencies
3. **Development**: Installs package in editable mode
4. **Testing**: Runs pytest with verbose output
5. **Building**: Creates distribution packages
6. **Verification**: Tests wheel installation
7. **Demo**: Shows CLI functionality

## Setuptools vs Other Tools

### Advantages of Setuptools
- **Mature and stable** - Industry standard for Python packaging
- **Wide compatibility** - Works with all Python versions and platforms
- **Extensive ecosystem** - Supported by all major tools (pip, PyPI, etc.)
- **Flexible configuration** - Supports complex package structures
- **Legacy support** - Can handle older Python projects

### When to Use Setuptools
- Traditional Python projects
- Complex package structures
- Legacy codebase migration
- Maximum compatibility requirements
- Corporate environments with strict tool requirements

## Troubleshooting

### Common Issues

1. **Permission denied on script**
   ```bash
   chmod +x setup_and_build.sh
   ```

2. **Module not found errors**
   ```bash
   pip install -r requirements.txt
   pip install -e .
   ```

3. **Test failures**
   ```bash
   python -m pytest tests/ -v --tb=short
   ```

4. **Build errors**
   ```bash
   pip install --upgrade setuptools wheel
   ```

### Debug Commands

```bash
# Check package installation
pip list | grep setuptools-demo

# Verify CLI installation
which setuptools-demo

# Test import
python -c "import setuptools_demo; print('OK')"

# Check package metadata
python setup.py --name --version --description
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Run the test suite: `python -m pytest tests/ -v`
5. Run the build script: `./setup_and_build.sh`
6. Submit a pull request

## License

MIT License - see LICENSE file for details.

This setuptools demo provides a solid foundation for traditional Python packaging, demonstrating best practices and modern development workflows while maintaining compatibility with the broader Python ecosystem.