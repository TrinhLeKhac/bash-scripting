#!/bin/bash

# SBT Project Build and Run Script
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="sbt-demo"

echo "🚀 SBT Scala Project Build and Run Script"

# Function to install SBT automatically
install_sbt() {
    echo "🔧 Installing SBT..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            echo "📦 Installing SBT via Homebrew..."
            brew install sbt
        else
            echo "❌ Homebrew not found. Installing Homebrew first..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            brew install sbt
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        echo "📦 Installing SBT on Linux..."
        if command -v apt-get &> /dev/null; then
            # Ubuntu/Debian
            echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
            curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
            sudo apt-get update
            sudo apt-get install -y sbt
        elif command -v yum &> /dev/null; then
            # CentOS/RHEL
            curl -L https://www.scala-sbt.org/sbt-rpm.repo > sbt-rpm.repo
            sudo mv sbt-rpm.repo /etc/yum.repos.d/
            sudo yum install -y sbt
        else
            echo "❌ Unsupported Linux distribution. Please install SBT manually."
            exit 1
        fi
    else
        echo "❌ Unsupported OS: $OSTYPE"
        echo "Please install SBT manually from: https://www.scala-sbt.org/download.html"
        exit 1
    fi
}

# Function to check if SBT is installed
check_sbt() {
    if ! command -v sbt &> /dev/null; then
        echo "❌ SBT is not installed."
        read -p "🤔 Would you like to install SBT automatically? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_sbt
        else
            echo "Please install SBT manually:"
            echo "   macOS: brew install sbt"
            echo "   Linux: https://www.scala-sbt.org/download.html"
            exit 1
        fi
    fi
    echo "✅ SBT version: $(sbt --version | head -n1)"
}

# Function to clean previous builds
clean_build() {
    echo "🧹 Cleaning previous builds..."
    sbt clean
    rm -rf target/ project/target/ project/project/
}

# Function to compile the project
compile_project() {
    echo "🔨 Compiling Scala project..."
    sbt -warn compile
}

# Function to run tests
run_tests() {
    echo "🧪 Running tests..."
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
    echo "📦 Creating assembly JAR..."
    sbt -warn assembly
    echo "✅ Assembly JAR created: target/scala-*/sbt-demo.jar"
}

# Function to run the application
run_application() {
    echo "🏃 Running application..."
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

# Function to run JAR directly
run_jar() {
    local jar_file="target/scala-*/sbt-demo.jar"
    if [[ -f $jar_file ]]; then
        echo "🏃 Running JAR file..."
        case "${1:-default}" in
            "file")
                java -jar $jar_file --file "${2:-}"
                ;;
            "data")
                java -jar $jar_file --data "${2:-}"
                ;;
            "help")
                java -jar $jar_file --help
                ;;
            "default"|*)
                java -jar $jar_file
                ;;
        esac
    else
        echo "❌ JAR file not found. Run 'assembly' first."
        exit 1
    fi
}

# Function to format code
format_code() {
    echo "🎨 Formatting code..."
    sbt -warn scalafmt
}

# Function to check for dependency updates
check_updates() {
    echo "🔍 Checking for dependency updates..."
    sbt dependencyUpdates
}

# Function to show project info
show_info() {
    echo "📋 Project Information:"
    echo "  Name: $PROJECT_NAME"
    echo "  Directory: $PROJECT_DIR"
    echo "  Scala Version: $(sbt 'print scalaVersion' 2>/dev/null | tail -n1)"
    echo "  SBT Version: $(sbt sbtVersion 2>/dev/null | tail -n1)"
    echo ""
    echo "📁 Project Structure:"
    find . -type f -name "*.scala" -o -name "*.sbt" | head -10
}

# Function to create sample data file
create_sample_data() {
    echo "📄 Creating sample data file..."
    cat > data/sample_data.csv << 'EOF'
1,2,3,4,5
6,7,8,9,10
-1,-2,3,4
11,12,13
-5,-6,7,8,9
EOF
    echo "✅ Sample data created: sample_data.csv"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  install-sbt    - Install SBT automatically"
    echo "  build          - Clean, compile, and test the project"
    echo "  compile        - Compile the project only"
    echo "  test           - Run tests only"
    echo "  coverage       - Run tests with coverage report"
    echo "  assembly       - Create assembly JAR"
    echo "  run [args]     - Run application with SBT"
    echo "  jar [args]     - Run assembly JAR directly"
    echo "  format         - Format code with scalafmt"
    echo "  updates        - Check for dependency updates"
    echo "  info           - Show project information"
    echo "  sample         - Create sample data file"
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
    echo "  $0 run file sample_data.csv"
    echo "  $0 run data \"1,2,3,4,5\""
    echo "  $0 jar help"
}

# Main script logic
case "${1:-help}" in
    "build")
        check_sbt
        clean_build
        compile_project
        run_tests
        echo "✅ Build completed successfully!"
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
        run_application "${2:-default}" "${3:-}"
        ;;
    "jar")
        run_jar "${2:-default}" "${3:-}"
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
    "install-sbt")
        install_sbt
        ;;
    "help"|*)
        show_usage
        ;;
esac