# Poetry Demo

Modern Python packaging demonstration using Poetry.

## Features

- Modern Python packaging with Poetry
- CLI application with Click
- Data validation with Pydantic
- HTTP requests with requests library
- Comprehensive testing with pytest
- Code formatting with Black
- Type checking with MyPy

## Installation

```bash
poetry install
```

## Usage

```bash
# Basic usage
poetry run poetry-demo --name "Your Name"

# With URL fetching
poetry run poetry-demo --url https://httpbin.org/json

# Verbose output
poetry run poetry-demo --name "Developer" --verbose

# Show help
poetry run poetry-demo --help
```

## Development

```bash
# Install dependencies
poetry install

# Run tests
poetry run pytest

# Format code
poetry run black .

# Type checking
poetry run mypy src/

# Build package
poetry build
```