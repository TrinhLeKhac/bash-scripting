# Conda Demo Package

A demonstration of conda packaging for scientific Python applications with automated build system.

## Features

- **Scientific CLI**: Command-line interface with Click
- **Data Validation**: Input validation with Pydantic
- **HTTP Requests**: Data fetching capabilities with requests
- **Conda Packaging**: Cross-platform conda package distribution
- **Scientific Dependencies**: Optimized for scientific computing workflows
- **Cross-platform**: Works on Windows, macOS, Linux

## Quick Start

### Automated Setup & Build (One Command)
```bash
# Run automated setup script - creates conda env, installs dependencies, builds and demos
bash setup_and_build.sh
```

### Manual Setup (if needed)
```bash
# Install Anaconda or Miniconda first
curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh

# Create conda environment
conda create -n conda-demo-env python=3.11 conda-build
conda activate conda-demo-env

# Install dependencies and build
pip install requests click pydantic
pip install -e .
conda build .
```

### Install from Built Package (Production Deployment)

#### Check Built Packages
```bash
# List built packages and check conda package info
ls -la conda-dist/ && echo "Package info:" && conda search --use-local conda-demo
```

#### Install from Conda Package
```bash
# Create production environment
conda create -n production-env python=3.11
conda activate production-env

# Install from local build
conda install ./conda-dist/linux-64/conda-demo-1.0.0-py311_0.tar.bz2
```

#### Why Install from Conda Package?

**Advantages of conda package installation:**
- **Binary Dependencies**: Pre-compiled binaries, no compilation needed
- **Environment Isolation**: Complete dependency management including system libraries
- **Scientific Optimized**: Optimized builds for NumPy, SciPy, pandas ecosystem
- **Cross-Platform**: Same package works across different operating systems
- **Reproducible**: Exact dependency versions locked
- **Offline Installation**: Can be installed without internet access

**Use Cases:**
- **Scientific Computing**: Deploy on HPC clusters and research environments
- **Production Servers**: Install on servers without build tools
- **Distribution**: Share packages with other researchers/developers
- **CI/CD Pipelines**: Fast, reliable installation in automated workflows
- **Docker Images**: Lightweight installation in containers

## Usage

### Basic Commands
```bash
# Simple greeting
conda-demo hello --name "Python Developer"

# Greeting with debug info
conda-demo hello --name "Developer" --debug

# Fetch data from URL
conda-demo fetch --url https://httpbin.org/json

# Fetch from custom URL
conda-demo fetch --url https://api.github.com/users/octocat

# Show package info
conda-demo info

# Show help
conda-demo --help
```

### Example Output
```bash
$ conda-demo hello --name "Conda User" --debug
Hello, Conda User!
Debug mode: True
Version: 1.0.0

$ conda-demo fetch --url https://httpbin.org/json
Fetching data from: https://httpbin.org/json
Response received:
Status: 200
Content-Type: application/json
JSON Data:
  slideshow: {'author': 'Yours Truly', 'date': 'date of publication', 'slides': [...]}
```

## Package Structure
```
conda_project/
├── meta.yaml              # Conda package metadata
├── setup.py               # Python package setup
├── setup_and_build.sh     # Automated build script
├── LICENSE                # MIT license
├── README.md             # This documentation
└── conda_demo/           # Source package
    ├── __init__.py       # Package initialization
    └── cli.py            # CLI implementation
```

## Development

### Install Development Dependencies
```bash
conda activate conda-demo-env
pip install -e .

# Optional: Install testing tools
conda install pytest pytest-cov
```

### Build and Test
```bash
# Build package
conda build . --output-folder ./conda-dist

# Test installation
conda create -n test-env python=3.11
conda activate test-env
conda install ./conda-dist/linux-64/conda-demo-1.0.0-py311_0.tar.bz2

# Check build results
ls -la conda-dist/
# conda-demo-1.0.0-py311_0.tar.bz2
```

## Dependencies

### Runtime
- **Python**: >=3.8
- **requests**: >=2.28.0 (HTTP client)
- **click**: >=8.0.0 (CLI framework)
- **pydantic**: >=1.10.0 (data validation)

### Build
- **conda-build**: Package building
- **setuptools**: Python packaging
- **anaconda-client**: Package uploading (optional)

## Why Conda?

### Advantages over pip:
- **Binary Dependencies**: Handles complex C/C++/Fortran libraries automatically
- **Environment Management**: Complete isolation including system libraries
- **Scientific Ecosystem**: Optimized for NumPy, SciPy, pandas, matplotlib
- **Cross-Platform**: Same environment across Windows, macOS, Linux
- **Performance**: Pre-compiled binaries for faster installation

### Comparison:
```python
# pip (Python only)
pip install numpy scipy pandas  # May need compilation

# conda (Python + optimized binaries)
conda install numpy scipy pandas  # Pre-compiled, faster
```

## Getting Started

### Prerequisites
```bash
# Check conda installation
conda --version

# If not installed, get Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
```

### Quick Setup
```bash
# Clone and setup
git clone <repository>
cd conda_project

# One-command setup
bash setup_and_build.sh

# Or manual setup
conda create -n conda-demo-env python=3.11 conda-build
conda activate conda-demo-env
pip install -e .
```

### Learning Path
1. **Run automated setup** to see conda packaging in action
2. **Explore meta.yaml** to understand conda package configuration
3. **Compare with pip/flit** to see different packaging approaches
4. **Build custom packages** for your scientific computing needs
5. **Deploy to conda channels** for distribution

## License

MIT License - see LICENSE file for details.

## Links

- **Home**: https://github.com/example/conda-demo
- **Documentation**: https://conda-demo.readthedocs.io
- **Conda Documentation**: https://docs.conda.io/