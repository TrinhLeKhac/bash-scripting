#!/bin/bash
"""
Spark Demo Runner Script
Demonstrates various Spark applications with sample data
"""

set -euo pipefail

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
SPARK_HOME=${SPARK_HOME:-"/opt/spark"}
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="$PROJECT_DIR/demo_data"
OUTPUT_DIR="$PROJECT_DIR/demo_output"
JAR_DIR="$PROJECT_DIR/spark_sbt/target/scala-2.12"

echo -e "${BLUE}🚀 Spark Demo Runner${NC}"
echo "=================================="

# Check if Spark is available
if ! command -v spark-submit &> /dev/null; then
    echo -e "${RED}❌ spark-submit not found. Please install Apache Spark.${NC}"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to run Spark application
run_spark_app() {
    local app_class=$1
    local jar_file=$2
    local input_file=$3
    local output_dir=$4
    local app_name=$5
    
    echo -e "${BLUE}📊 Running $app_name...${NC}"
    
    # Clean output directory
    rm -rf "$output_dir"
    
    spark-submit \
        --class "$app_class" \
        --master "local[*]" \
        --driver-memory 2g \
        --executor-memory 1g \
        --conf spark.sql.adaptive.enabled=true \
        --conf spark.sql.adaptive.coalescePartitions.enabled=true \
        "$jar_file" \
        "$input_file" \
        "$output_dir"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $app_name completed successfully${NC}"
        echo -e "${YELLOW}📁 Output saved to: $output_dir${NC}"
    else
        echo -e "${RED}❌ $app_name failed${NC}"
        return 1
    fi
}

# Function to create sample text data for WordCount
create_sample_text() {
    local output_file="$DATA_DIR/sample_text.txt"
    
    cat > "$output_file" << 'EOF'
Apache Spark is a unified analytics engine for large-scale data processing.
Spark provides high-level APIs in Java, Scala, Python and R.
Spark runs on Hadoop, Apache Mesos, Kubernetes, standalone, or in the cloud.
It can access diverse data sources including HDFS, Alluxio, Apache Cassandra, Apache HBase, Apache Hive, and hundreds of other data sources.
Spark SQL is Apache Spark's module for working with structured data.
Spark Streaming makes it easy to build scalable fault-tolerant streaming applications.
MLlib is Apache Spark's scalable machine learning library.
GraphX is Apache Spark's API for graphs and graph-parallel computation.
Spark runs everywhere from laptops to clusters with thousands of nodes.
Apache Spark achieves high performance for both batch and streaming data.
EOF
    
    echo -e "${GREEN}📝 Created sample text file: $output_file${NC}"
}

# Function to display results
show_results() {
    local output_dir=$1
    local result_type=$2
    
    echo -e "${BLUE}📋 $result_type Results:${NC}"
    
    if [ -d "$output_dir" ]; then
        # Find CSV files and display first few lines
        find "$output_dir" -name "*.csv" -type f | head -5 | while read -r file; do
            echo -e "${YELLOW}📄 $file:${NC}"
            head -10 "$file" | sed 's/^/   /'
            echo ""
        done
        
        # Find Parquet files
        parquet_files=$(find "$output_dir" -name "*.parquet" -type f | wc -l)
        if [ "$parquet_files" -gt 0 ]; then
            echo -e "${YELLOW}📦 Found $parquet_files Parquet files${NC}"
        fi
    else
        echo -e "${RED}❌ Output directory not found: $output_dir${NC}"
    fi
}

# Main execution
main() {
    echo -e "${BLUE}🔧 Setting up demo environment...${NC}"
    
    # Check if JAR file exists
    JAR_FILE=$(find "$JAR_DIR" -name "*assembly*.jar" | head -1)
    if [ -z "$JAR_FILE" ]; then
        echo -e "${RED}❌ Assembly JAR not found. Please build the project first:${NC}"
        echo -e "${YELLOW}   cd spark_sbt && sbt assembly${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Found JAR file: $JAR_FILE${NC}"
    
    # Create sample data
    create_sample_text
    
    # Demo 1: WordCount
    echo -e "\n${BLUE}🔤 Demo 1: Word Count Analysis${NC}"
    run_spark_app \
        "com.example.WordCount" \
        "$JAR_FILE" \
        "$DATA_DIR/sample_text.txt" \
        "$OUTPUT_DIR/wordcount" \
        "WordCount"
    
    show_results "$OUTPUT_DIR/wordcount" "Word Count"
    
    # Demo 2: Data Analytics (if sales data exists)
    if [ -f "$DATA_DIR/sales_data.csv" ]; then
        echo -e "\n${BLUE}📊 Demo 2: Sales Data Analytics${NC}"
        run_spark_app \
            "com.example.DataAnalytics" \
            "$JAR_FILE" \
            "$DATA_DIR/sales_data.csv" \
            "$OUTPUT_DIR/analytics" \
            "Data Analytics"
        
        show_results "$OUTPUT_DIR/analytics" "Sales Analytics"
    else
        echo -e "${YELLOW}⚠️  Sales data not found, skipping analytics demo${NC}"
    fi
    
    # Demo 3: ML Pipeline (if we have ML data)
    echo -e "\n${BLUE}🤖 Demo 3: Machine Learning Pipeline${NC}"
    
    # Create sample ML data
    create_ml_sample_data
    
    run_spark_app \
        "com.example.MLPipeline" \
        "$JAR_FILE" \
        "$DATA_DIR/ml_sample.csv" \
        "$OUTPUT_DIR/ml_pipeline" \
        "ML Pipeline"
    
    show_results "$OUTPUT_DIR/ml_pipeline" "ML Pipeline"
    
    # Summary
    echo -e "\n${GREEN}🎉 All demos completed!${NC}"
    echo -e "${BLUE}📁 Results are available in: $OUTPUT_DIR${NC}"
    echo -e "${YELLOW}💡 You can explore the output files to see the results${NC}"
}

# Function to create sample ML data
create_ml_sample_data() {
    local output_file="$DATA_DIR/ml_sample.csv"
    
    cat > "$output_file" << 'EOF'
feature1,feature2,feature3,label
1.2,2.3,3.1,0
2.1,1.8,2.9,1
3.2,3.5,1.2,0
1.8,2.1,3.8,1
2.9,1.5,2.2,0
3.1,3.2,1.8,1
1.5,2.8,3.5,0
2.5,1.9,2.1,1
3.8,3.1,1.5,0
1.9,2.5,3.2,1
2.2,1.2,2.8,0
3.5,3.8,1.1,1
1.1,2.2,3.9,0
2.8,1.1,2.5,1
3.9,3.9,1.8,0
EOF
    
    echo -e "${GREEN}🧠 Created sample ML data: $output_file${NC}"
}

# Function to show usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -c, --clean    Clean output directory before running"
    echo ""
    echo "Environment Variables:"
    echo "  SPARK_HOME     Path to Spark installation (default: /opt/spark)"
    echo ""
    echo "Examples:"
    echo "  $0              # Run all demos"
    echo "  $0 --clean      # Clean and run all demos"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -c|--clean)
            echo -e "${YELLOW}🧹 Cleaning output directory...${NC}"
            rm -rf "$OUTPUT_DIR"
            shift
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

# Run main function
main