# Bash Scripting Comprehensive Guide

## Overview
This comprehensive guide covers bash scripting from basic concepts to advanced system administration, including automated cronjobs, 15 hands-on exercises, and Makefile automation. Perfect for learning practical bash scripting through real-world examples.

## Project Structure
```
bash_scripting/
├── scripts/                    # Main bash scripts (8 scripts)
├── data/                      # Sample CSV data files
├── cronjob/                   # Automated data crawling project
├── exercises/                 # 15 comprehensive practice exercises
├── makefile_exercises/        # 5 Makefile automation exercises
└── README.md                  # This comprehensive guide
```

## Basic Scripts

### 1. Basic Script (basic_script.sh)
Learn fundamental bash scripting concepts:
```bash
cd scripts && bash basic_script.sh 5
```
**Covers:** Variables, conditionals, loops, functions, arrays, string manipulation

### 2. Install Me (install_me.sh)
Simulate program installation with user confirmation:
```bash
cd scripts && bash install_me.sh
```
**Covers:** User input, conditional processing, string comparison

### 3. Calculate Frequencies (calculate_frequency.sh)
Calculate frequency of flower species in CSV data:
```bash
cd scripts && bash calculate_frequency.sh ../data
```
**Covers:** File processing, arrays, data analysis, loops

## Advanced Scripts

### 4. File Monitor (file_monitor.sh)
Monitor file changes with advanced features:
```bash
cd scripts && bash file_monitor.sh ../data/data1.csv 2
```
**Features:** Real-time monitoring, logging, color output, configurable intervals

### 5. CSV Processor (csv_processor.sh)
Process and analyze CSV data interactively:
```bash
cd scripts && bash csv_processor.sh ../data/data1.csv interactive
```
**Features:** Statistical analysis, data filtering, interactive menus

### 6. System Monitor (system_monitor.sh)
Monitor system resources continuously:
```bash
cd scripts && bash system_monitor.sh 3
```
**Features:** CPU/Memory/Disk monitoring, CSV logging, color-coded alerts

### 7. Backup Manager (backup_manager.sh)
Comprehensive backup management system:
```bash
cd scripts && bash backup_manager.sh ../data ./backups
```
**Features:** Automated backups, compression, restoration, cleanup

### 8. Log Analyzer (log_analyzer.sh)
Analyze log files for patterns and statistics:
```bash
cd scripts && bash log_analyzer.sh sample.log
```
**Features:** Pattern detection, statistical analysis, report generation

## Cronjob Automation Project

### Overview
Automated data crawling using cron jobs, bash scripts, and Python. Downloads the Iris dataset every minute and maintains detailed logs.

### Quick Start
```bash
cd cronjob

# Setup and test
chmod +x run.sh
./run.sh

# Install cron job
crontab -e
# Add: * * * * * cd /path/to/cronjob && /bin/bash run.sh >> logs/iris.log 2>&1

# Monitor execution
tail -f logs/iris.log logs/crawler.log
```

### Project Components
- **run.sh**: Main orchestration script (environment setup, execution)
- **crawl.py**: Python data crawler with pandas processing
- **requirements.txt**: Python dependencies (pandas==2.1.4)
- **craw_cron.txt**: Cron job configuration
- **logs/**: Execution and application logs
- **myenv/**: Python virtual environment (auto-created)

### Key Features
- **Automated Environment Setup**: Creates Python virtual environment
- **Data Processing**: Downloads and validates data with pandas
- **Comprehensive Logging**: Tracks all operations and errors
- **Resource Management**: Automatic cleanup of downloaded files
- **Error Handling**: Robust exception handling and recovery

## Practice Exercises (15 Comprehensive Exercises)

### Basic Level (1-5)
```bash
cd exercises

# Calculator Script
bash solutions/exercise_1_solution.sh 10 + 5

# File Organizer
bash solutions/exercise_2_solution.sh /path/to/directory

# Password Generator
bash solutions/exercise_3_solution.sh --length 16 --count 3

# System Information
bash solutions/exercise_4_solution.sh --all

# Text File Analyzer
bash solutions/exercise_5_solution.sh document.txt --words --top 10
```

### Intermediate Level (6-10)
```bash
# Directory Tree Generator
bash solutions/exercise_6_solution.sh . --depth 3 --size

# Process Monitor
bash solutions/exercise_7_solution.sh --monitor firefox

# Network Checker
bash solutions/exercise_8_solution.sh --ping google.com

# Log Rotator
bash solutions/exercise_9_solution.sh --file app.log --size 100M

# Database Backup
bash solutions/exercise_10_solution.sh --type mysql --db myapp
```

### Advanced Level (11-15)
```bash
# Server Health Check
bash solutions/exercise_11_solution.sh --local --dashboard

# Deployment Script
bash solutions/exercise_12_solution.sh --app myapp --env production --version v1.2.3

# Configuration Manager
bash solutions/exercise_13_solution.sh --env production --generate

# Performance Analyzer
bash solutions/exercise_14_solution.sh --monitor --duration 300

# Automated Testing
bash solutions/exercise_15_solution.sh --test-dir tests/ --parallel
```

### Exercise Features
- **Comprehensive error handling** and input validation
- **Color-coded output** and progress indicators
- **Cross-platform compatibility**
- **Interactive modes** and help messages
- **Modular functions** and configuration files

## Makefile Exercises (5 Build Automation Exercises)

### Exercise Overview
```bash
cd makefile_exercises

# Exercise 1: Basic C Project Build System
make -f exercise_1/Makefile

# Exercise 2: Web Development Build Pipeline
make -f exercise_2/Makefile deploy

# Exercise 3: Multi-Language Project Manager
make -f exercise_3/Makefile all

# Exercise 4: Docker Multi-Stage Build System
make -f exercise_4/Makefile docker-build

# Exercise 5: Cross-Platform Package Manager
make -f exercise_5/Makefile package-all
```

### Learning Objectives
- Master Makefile syntax and dependency management
- Implement cross-platform builds and pattern rules
- Create reusable build templates
- Integrate with Docker and CI/CD pipelines

## Key Bash Concepts and Patterns

### Variables and Parameters
```bash
# Variable assignment and expansion
name="John"
echo "Hello, ${name}!"
echo "Length: ${#name}"

# Command line arguments
echo "Script: $0, First arg: $1, All args: $@, Count: $#"
```

### Conditionals and Loops
```bash
# Numeric and string comparisons
if (( num > 10 )) && [[ "$str" == "hello" ]]; then
    echo "Conditions met"
fi

# File tests
if [[ -f "$file" ]]; then
    echo "File exists"
fi

# Loops
for i in {1..10}; do echo "Number: $i"; done
while read -r line; do echo "Line: $line"; done < file.txt
```

### Functions and Arrays
```bash
# Function with local variables
my_function() {
    local param=$1
    echo $((param * 2))
}

# Arrays
fruits=("apple" "banana" "orange")
for fruit in "${fruits[@]}"; do
    echo "Fruit: $fruit"
done
```

### Error Handling and Logging
```bash
# Error handling
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Logging function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}
```

## Build and Deployment

### Makefile Commands
```bash
# Build all components
make build

# Deploy to staging/production
make deploy

# Run CI pipeline
make ci

# Clean build artifacts
make clean
```

### Development Workflow
```bash
# Setup development environment
make setup

# Run tests
make test

# Format code
make format

# Generate documentation
make docs
```

## Monitoring and Troubleshooting

### Log Analysis
```bash
# Monitor cronjob execution
tail -f cronjob/logs/iris.log cronjob/logs/crawler.log

# Search for errors across all logs
grep -r -i "error\|exception\|fail" . --include="*.log"

# Analyze script performance
bash -x scripts/system_monitor.sh 1
```

### Debugging Tips
```bash
# Enable debug mode
set -x  # Enable debugging
bash -x script.sh  # Debug specific script

# Syntax checking
bash -n script.sh  # Check syntax without execution

# Validate environment
env | grep -E "(PATH|HOME|USER)"
```

### Common Issues and Solutions
1. **Permission denied**: `chmod +x script.sh`
2. **Command not found**: Check PATH and install required tools
3. **Cron job not running**: Check cron service and environment variables
4. **Python environment issues**: Recreate virtual environment

## Security Best Practices

### File Permissions
```bash
# Secure script files
chmod 750 *.sh
chmod 640 *.txt *.md

# Secure directories
chmod 750 logs/ backups/
```

### Input Validation
```bash
# Validate user input
if [[ ! "$input" =~ ^[a-zA-Z0-9]+$ ]]; then
    echo "Invalid input format"
    exit 1
fi
```

### Environment Isolation
- Use Python virtual environments for package isolation
- Separate configuration files for different environments
- Implement proper logging and audit trails

## Performance Optimization

### Resource Management
- Automatic cleanup of temporary files
- Efficient memory usage with streaming processing
- Parallel execution where appropriate
- Configurable execution intervals

### Monitoring
- Real-time system resource monitoring
- Performance benchmarking tools
- Automated alerting for resource thresholds
- Comprehensive logging for performance analysis

## Getting Started

### Prerequisites
```bash
# Check required tools
python3 --version
bash --version
make --version
git --version
```

### Quick Setup
```bash
# Clone and setup
git clone <repository>
cd bash_scripting

# Make scripts executable
chmod +x scripts/*.sh

# Test basic functionality
cd scripts && bash basic_script.sh 5

# Setup cronjob (optional)
cd cronjob && chmod +x run.sh && ./run.sh

# Try exercises
cd exercises && bash solutions/exercise_1_solution.sh 10 + 5
```

### Learning Path
1. **Start with basic scripts** (1-3) to understand fundamentals
2. **Progress to advanced scripts** (4-8) for real-world applications
3. **Setup cronjob automation** for practical scheduling experience
4. **Complete exercises 1-5** for basic bash mastery
5. **Tackle exercises 6-10** for intermediate skills
6. **Master exercises 11-15** for advanced system administration
7. **Learn Makefile automation** for build system expertise

This comprehensive guide provides everything needed to master bash scripting from basic concepts to advanced automation and system administration tasks.