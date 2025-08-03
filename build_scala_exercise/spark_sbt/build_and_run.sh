#!/bin/bash

# Spark SBT Project Build and Run Script
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="spark-sbt-demo"

echo "🚀 Spark SBT Project Build and Run Script"

# Function to check and setup Java environment
check_java() {
    local java_version=$(java -version 2>&1 | head -n1 | cut -d'"' -f2 | cut -d'.' -f1)
    echo "📋 Current Java version: $java_version"
    
    if [[ "$java_version" -gt 17 ]]; then
        echo "⚠️  Java $java_version detected. Spark works best with Java 11 or 17."
        
        # Check if Java 11 is available
        if [[ -d "/opt/homebrew/opt/openjdk@11" ]]; then
            echo "🔧 Found Java 11, switching to it..."
            export JAVA_HOME="/opt/homebrew/opt/openjdk@11"
            export PATH="$JAVA_HOME/bin:$PATH"
            echo "✅ Switched to Java 11: $(java -version 2>&1 | head -n1)"
        elif [[ -d "/usr/lib/jvm/java-11-openjdk" ]]; then
            echo "🔧 Found Java 11, switching to it..."
            export JAVA_HOME="/usr/lib/jvm/java-11-openjdk"
            export PATH="$JAVA_HOME/bin:$PATH"
            echo "✅ Switched to Java 11: $(java -version 2>&1 | head -n1)"
        else
            echo "💡 Installing Java 11 for better Spark compatibility..."
            if command -v brew &> /dev/null; then
                brew install openjdk@11
                export JAVA_HOME="/opt/homebrew/opt/openjdk@11"
                export PATH="$JAVA_HOME/bin:$PATH"
                echo "✅ Java 11 installed and configured"
            else
                echo "❌ Please install Java 11 manually for better Spark compatibility"
                echo "   Or continue with current Java (may have compatibility issues)"
            fi
        fi
    else
        echo "✅ Java version compatible with Spark"
    fi
}

# Function to setup Spark environment
setup_spark_env() {
    # Set Spark-specific JVM options for Java compatibility
    export SPARK_SUBMIT_OPTS="--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.base/sun.nio.cs=ALL-UNNAMED --add-opens=java.base/sun.util.calendar=ALL-UNNAMED --add-opens=java.security.jgss/sun.security.krb5=ALL-UNNAMED"
    
    # Set Hadoop user to avoid permission issues
    export HADOOP_USER_NAME="$USER"
    
    # Disable Hadoop native library warnings
    export HADOOP_OPTS="-Djava.library.path=/opt/hadoop/lib/native"
    
    echo "🔧 Spark environment configured"
}

# Function to check if SBT is installed
check_sbt() {
    if ! command -v sbt &> /dev/null; then
        echo "❌ SBT is not installed. Please install SBT first."
        echo "   macOS: brew install sbt"
        echo "   Linux: https://www.scala-sbt.org/download.html"
        exit 1
    fi
    echo "✅ SBT version: $(sbt --version | head -n1)"
}

# Function to check if Spark is available (optional)
check_spark() {
    if command -v spark-submit &> /dev/null; then
        echo "✅ Spark available: $(spark-submit --version 2>&1 | head -n1)"
    else
        echo "⚠️  Spark not found in PATH. Using embedded Spark in local mode."
    fi
}

# Function to clean previous builds
clean_build() {
    echo "🧹 Cleaning previous builds..."
    sbt -warn clean
    rm -rf target/ project/target/ project/project/
}

# Function to compile the project
compile_project() {
    echo "🔨 Compiling Spark Scala project..."
    sbt -warn compile
}

# Function to run tests
run_tests() {
    echo "🧪 Running Spark tests..."
    sbt -warn test
}

# Function to run test coverage
run_coverage() {
    echo "📊 Running test coverage..."
    sbt -warn coverage test coverageReport
    echo "📋 Coverage report generated in target/scala-*/scoverage-report/"
}

# Function to create assembly JAR
create_assembly() {
    echo "📦 Creating Spark assembly JAR..."
    sbt -warn assembly
    echo "✅ Assembly JAR created: target/scala-*/spark-sbt-demo.jar"
}

# Function to run the Spark application with SBT
run_spark_application() {
    echo "🏃 Running Spark application with SBT..."
    case "${1:-default}" in
        "file")
            if [[ -n "${2:-}" ]]; then
                sbt -warn "run --file $2"
            else
                echo "❌ Please provide a file path"
                exit 1
            fi
            ;;
        "data")
            if [[ -n "${2:-}" ]]; then
                sbt -warn "run --data $2"
            else
                echo "❌ Please provide comma-separated data"
                exit 1
            fi
            ;;
        "help")
            sbt -warn "run --help"
            ;;
        "default"|*)
            sbt -warn run
            ;;
    esac
}

# Function to run JAR with spark-submit
run_spark_submit() {
    local jar_file="target/scala-*/spark-sbt-demo.jar"
    if [[ -f $jar_file ]]; then
        echo "🏃 Running with spark-submit..."
        case "${1:-default}" in
            "file")
                spark-submit --class com.example.sparksbt.SparkDataProcessor \
                    --master local[*] \
                    --driver-memory 2g \
                    --executor-memory 2g \
                    $jar_file --file "${2:-}"
                ;;
            "data")
                spark-submit --class com.example.sparksbt.SparkDataProcessor \
                    --master local[*] \
                    --driver-memory 2g \
                    --executor-memory 2g \
                    $jar_file --data "${2:-}"
                ;;
            "help")
                spark-submit --class com.example.sparksbt.SparkDataProcessor \
                    --master local[*] \
                    $jar_file --help
                ;;
            "default"|*)
                spark-submit --class com.example.sparksbt.SparkDataProcessor \
                    --master local[*] \
                    --driver-memory 2g \
                    --executor-memory 2g \
                    $jar_file
                ;;
        esac
    else
        echo "❌ JAR file not found. Run 'assembly' first."
        exit 1
    fi
}

# Function to format code
format_code() {
    echo "🎨 Formatting Spark code..."
    sbt -warn scalafmt
}

# Function to check for dependency updates
check_updates() {
    echo "🔍 Checking for dependency updates..."
    sbt dependencyUpdates
}

# Function to show project info
show_info() {
    echo "📋 Spark Project Information:"
    echo "  Name: $PROJECT_NAME"
    echo "  Directory: $PROJECT_DIR"
    echo "  Scala Version: $(sbt 'print scalaVersion' 2>/dev/null | tail -n1)"
    echo "  SBT Version: $(sbt sbtVersion 2>/dev/null | tail -n1)"
    echo ""
    echo "📁 Project Structure:"
    find . -type f -name "*.scala" -o -name "*.sbt" | head -10
    echo ""
    echo "📊 Data Files:"
    ls -la data/ 2>/dev/null || echo "  No data directory found"
}

# Function to create sample data files
create_sample_data() {
    echo "📄 Creating Spark sample data files..."
    mkdir -p data
    
    cat > data/spark_sample.csv << 'EOF'
1,2,3,4,5
10,20,30,40,50
-5,-10,15,25
100,200,-50,75
0,1,-1,2,-2
EOF
    
    echo "✅ Sample data created in data/ directory"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  setup          - Setup Java environment for Spark"
    echo "  build          - Clean, compile, and test the project"
    echo "  compile        - Compile the project only"
    echo "  test           - Run tests only"
    echo "  coverage       - Run tests with coverage report"
    echo "  assembly       - Create assembly JAR"
    echo "  run [args]     - Run Spark application with SBT"
    echo "  spark [args]   - Run JAR with spark-submit"
    echo "  format         - Format code with scalafmt"
    echo "  updates        - Check for dependency updates"
    echo "  info           - Show project information"
    echo "  sample         - Create sample data files"
    echo "  clean          - Clean build artifacts"
    echo "  help           - Show this help"
    echo ""
    echo "Run arguments:"
    echo "  default        - Run with sample data"
    echo "  file <path>    - Process CSV file"
    echo "  data <nums>    - Process comma-separated numbers"
    echo "  help           - Show application help"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 run file data/spark_sample.csv"
    echo "  $0 run data \"1,2,3,4,5,-1,-2\""
    echo "  $0 spark file data/large_dataset.csv"
    echo "  $0 assembly && $0 spark help"
}

# Setup environment before running commands
check_java
setup_spark_env

# Main script logic
case "${1:-help}" in
    "setup")
        echo "🔧 Java and Spark environment setup completed!"
        echo "💡 Current Java: $(java -version 2>&1 | head -n1)"
        echo "💡 JAVA_HOME: ${JAVA_HOME:-Not set}"
        ;;
    "build")
        check_sbt
        clean_build
        compile_project
        echo "✅ Spark build completed successfully!"
        ;;
    "compile")
        check_sbt
        compile_project
        ;;
    "test")
        check_sbt
        run_tests
        ;;
    "coverage")
        check_sbt
        run_coverage
        ;;
    "assembly")
        check_sbt
        create_assembly
        ;;
    "run")
        check_sbt
        run_spark_application "${2:-default}" "${3:-}"
        ;;
    "spark")
        check_spark
        run_spark_submit "${2:-default}" "${3:-}"
        ;;
    "format")
        check_sbt
        format_code
        ;;
    "updates")
        check_sbt
        check_updates
        ;;
    "info")
        check_sbt
        show_info
        ;;
    "sample")
        create_sample_data
        ;;
    "clean")
        check_sbt
        clean_build
        ;;
    "help"|*)
        show_usage
        ;;
esac