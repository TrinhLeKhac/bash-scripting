#!/bin/bash

# Script to run Python and PySpark examples
# Usage: ./run_examples.sh [example_name]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Setup environment
setup_environment() {
    print_status "Setting up environment..."
    
    # Create virtual environment if not exists
    if [ ! -d "venv" ]; then
        print_status "Creating Python virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Install dependencies
    print_status "Installing dependencies..."
    pip install -r requirements.txt
    
    # Create data and output directories
    mkdir -p data output
    
    print_status "Environment ready!"
}

# Generate sample data
generate_data() {
    print_status "Generating sample data..."
    source venv/bin/activate
    cd python_examples
    python data_generator.py 1000
    cd ..
}

# Run Python examples
run_python_examples() {
    print_status "Running Python examples..."
    source venv/bin/activate
    
    cd python_examples
    print_status "Running pandas analysis..."
    python pandas_analysis.py ../data/sample_data.csv
    cd ..
}

# Run PySpark examples
run_pyspark_examples() {
    print_status "Running PySpark examples..."
    source venv/bin/activate
    
    cd pyspark_examples
    
    print_status "Running WordCount..."
    python wordcount.py ../data/sample_text.txt
    
    print_status "Running Data Analysis..."
    python data_analysis.py ../data/sample_data.csv
    
    print_status "Running ETL Pipeline..."
    python etl_pipeline.py ../data/sample_data.csv ../output/etl_result
    
    cd ..
}

# Show help
show_help() {
    echo "Usage: ./run_examples.sh [command]"
    echo ""
    echo "Commands:"
    echo "  setup     - Setup environment"
    echo "  data      - Generate sample data"
    echo "  python    - Run Python examples"
    echo "  pyspark   - Run PySpark examples"
    echo "  all       - Run all examples"
    echo "  clean     - Clean temporary files"
    echo "  help      - Show help"
}

# Clean up
clean_up() {
    print_status "Cleaning temporary files..."
    rm -rf output/* data/* venv/
    print_status "Cleanup completed!"
}

# Main execution
case "${1:-all}" in
    "setup")
        setup_environment
        ;;
    "data")
        generate_data
        ;;
    "python")
        run_python_examples
        ;;
    "pyspark")
        run_pyspark_examples
        ;;
    "all")
        setup_environment
        generate_data
        run_python_examples
        run_pyspark_examples
        print_status "All examples completed!"
        ;;
    "clean")
        clean_up
        ;;
    "help"|*)
        show_help
        ;;
esac