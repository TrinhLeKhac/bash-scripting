# Conda Demo Package

A demonstration package showing how to create conda packages for scientific Python applications.

## Features

- **CLI Interface**: Command-line tools using Click
- **HTTP Requests**: Data fetching with requests library  
- **Data Validation**: Configuration with Pydantic
- **Cross-platform**: Works on Windows, macOS, Linux

## Installation

### From conda (after building)
```bash
# Build the package
conda build .

# Install locally
conda install --use-local conda-demo
```

### From source
```bash
pip install -e .
```

## Usage

### CLI Commands
```bash
# Basic greeting
conda-demo hello --name "Python Developer"

# With debug info
conda-demo hello --name "Developer" --debug

# Fetch data from URL
conda-demo fetch --url https://api.github.com/users/octocat

# Show package info
conda-demo info

# Show help
conda-demo --help
```

## Package Structure
```
conda_project/
├── meta.yaml              # Conda recipe
├── setup.py              # Python package setup
├── conda_demo/           # Source package
│   ├── __init__.py
│   └── cli.py           # CLI implementation
└── README.md            # This file
```

## Dependencies

- **Python**: >=3.8
- **requests**: >=2.28.0 (HTTP client)
- **click**: >=8.0.0 (CLI framework)
- **pydantic**: >=1.10.0 (data validation)

## Building

```bash
# Build conda package
conda build .

# The built package will be in:
# $CONDA_PREFIX/conda-bld/[platform]/conda-demo-1.0.0-*.tar.bz2
```

## Testing

```bash
# Test imports
python -c "import conda_demo; print('Import successful')"

# Test CLI
conda-demo --help
conda-demo info
```

## License

MIT License - see LICENSE file for details.