#!/bin/bash

# ELT Pipeline Runner Script
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

setup_environment() {
    echo "🔧 Setting up ELT environment..."
    mkdir -p data extracted warehouse/{raw,staging,clean,aggregated} logs output
    
    if [[ ! -d "venv" ]]; then
        python3 -m venv venv
    fi
    
    source venv/bin/activate
    pip install -r requirements.txt
    
    # Create sample data
    cat > data/employees.csv << 'EOF'
id,name,age,department,salary
1,John Doe,30,Engineering,75000
2,Jane Smith,28,Marketing,65000
3,Bob Johnson,35,Engineering,85000
EOF
    
    cat > data/products.json << 'EOF'
[
    {"id": 1, "name": "Laptop", "price": 999.99},
    {"id": 2, "name": "Phone", "price": 699.99}
]
EOF
    
    echo "✅ Environment setup completed"
}

run_extract() {
    echo "🔍 Running Extract phase..."
    
    python extract/csv_extractor.py data/employees.csv
    python extract/json_extractor.py data/products.json
    
    echo "✅ Extract phase completed"
}

run_load() {
    echo "📥 Running Load phase..."
    
    python load/warehouse_loader.py --source extracted --target warehouse/raw
    
    echo "✅ Load phase completed"
}

run_transform() {
    echo "🔄 Running Transform phase..."
    
    python transform/data_cleaner.py --input warehouse/raw --output warehouse/clean
    python transform/aggregator.py --input warehouse/clean --output warehouse/aggregated
    
    echo "✅ Transform phase completed"
}

case "${1:-help}" in
    setup)
        setup_environment
        ;;
    extract)
        setup_environment
        run_extract
        ;;
    load)
        setup_environment
        run_extract
        run_load
        ;;
    transform)
        setup_environment
        run_extract
        run_load
        run_transform
        ;;
    all)
        setup_environment
        run_extract
        run_load
        run_transform
        echo "🎉 Complete ELT pipeline finished!"
        ;;
    clean)
        rm -rf venv extracted warehouse logs output
        echo "🧹 Cleanup completed"
        ;;
    *)
        echo "Usage: $0 {setup|extract|load|transform|all|clean}"
        ;;
esac