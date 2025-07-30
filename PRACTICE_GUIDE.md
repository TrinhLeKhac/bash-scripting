# Bash Scripting Practice Guide

## Overview
This comprehensive guide covers bash scripting from basic concepts to advanced system administration. It includes both example scripts and 15 hands-on exercises with complete solutions.

## Basic Scripts

### 1. Basic Script (basic_script.sh)
**Function:** Learn fundamental bash scripting concepts
```bash
cd scripts && bash basic_script.sh 5
```
**Covers:** Variables, conditionals, loops, functions, arrays, string manipulation

### 2. Install Me (install_me.sh)
**Function:** Simulate program installation with user input
```bash
cd scripts && bash install_me.sh
```
**Covers:** User input, conditional processing, string comparison

### 3. Calculate Frequencies (calculate_frequency.sh)
**Function:** Calculate frequency of flower species in CSV data
```bash
cd scripts && bash calculate_frequency.sh ../data
```
**Covers:** File processing, arrays, data analysis, loops

## Advanced Scripts

### 4. File Monitor (file_monitor.sh)
**Function:** Monitor file changes with advanced features
```bash
cd scripts && bash file_monitor.sh ../data/data1.csv 2
```
**Features:** Real-time monitoring, logging, color output, configurable intervals

### 5. CSV Processor (csv_processor.sh)
**Function:** Process and analyze CSV data interactively
```bash
cd scripts && bash csv_processor.sh ../data/data1.csv interactive
```
**Features:** Statistical analysis, data filtering, interactive menus

### 6. System Monitor (system_monitor.sh)
**Function:** Monitor system resources continuously
```bash
cd scripts && bash system_monitor.sh 3
```
**Features:** CPU/Memory/Disk monitoring, CSV logging, color-coded alerts

### 7. Backup Manager (backup_manager.sh)
**Function:** Comprehensive backup management system
```bash
cd scripts && bash backup_manager.sh ../data ./backups
```
**Features:** Automated backups, compression, restoration, cleanup

### 8. Log Analyzer (log_analyzer.sh)
**Function:** Analyze log files for patterns and statistics
```bash
cd scripts && bash log_analyzer.sh sample.log
```
**Features:** Pattern detection, statistical analysis, report generation

## Practice Exercises (15 Comprehensive Exercises)

### Getting Started with Exercises
```bash
# Navigate to exercises directory
cd exercises

# Read exercise description
cat exercise_1.md

# Try your own solution first
nano my_solution.sh

# Check the official solution
bash solutions/exercise_1_solution.sh
```

### Basic Level Exercises (1-5)

#### Exercise 1: Calculator Script
**Objective:** Create a command-line calculator
```bash
cd exercises && bash solutions/exercise_1_solution.sh 10 + 5
cd exercises && bash solutions/exercise_1_solution.sh 2 ^ 3
cd exercises && bash solutions/exercise_1_solution.sh --help
```
**Skills:** Arithmetic operations, input validation, error handling

#### Exercise 2: File Organizer
**Objective:** Organize files by extension into subdirectories
```bash
cd exercises && bash solutions/exercise_2_solution.sh /path/to/directory
cd exercises && bash solutions/exercise_2_solution.sh . --backup --dry-run
```
**Skills:** File operations, directory manipulation, backup strategies

#### Exercise 3: Password Generator
**Objective:** Generate secure passwords with customizable options
```bash
cd exercises && bash solutions/exercise_3_solution.sh --length 16 --count 3
cd exercises && bash solutions/exercise_3_solution.sh --no-symbols --save passwords.txt
```
**Skills:** Random generation, character sets, security practices

#### Exercise 4: System Information
**Objective:** Display comprehensive system information
```bash
cd exercises && bash solutions/exercise_4_solution.sh --all
cd exercises && bash solutions/exercise_4_solution.sh --cpu --memory --json
```
**Skills:** System calls, cross-platform compatibility, data formatting

#### Exercise 5: Text File Analyzer
**Objective:** Analyze text files for statistics and patterns
```bash
cd exercises && bash solutions/exercise_5_solution.sh document.txt --words --top 10
```
**Skills:** Text processing, statistical analysis, data extraction

### Intermediate Level Exercises (6-10)

#### Exercise 6: Directory Tree Generator
**Objective:** Create visual directory tree structures
```bash
cd exercises && bash solutions/exercise_6_solution.sh . --depth 3 --size
cd exercises && bash solutions/exercise_6_solution.sh /home --filter "*.txt"
```
**Skills:** Recursive traversal, tree visualization, file filtering

#### Exercise 7: Process Monitor
**Objective:** Monitor and manage system processes
```bash
cd exercises && bash solutions/exercise_7_solution.sh --list
cd exercises && bash solutions/exercise_7_solution.sh --monitor firefox
cd exercises && bash solutions/exercise_7_solution.sh --top-cpu 5
```
**Skills:** Process management, real-time monitoring, resource tracking

#### Exercise 8: Network Checker
**Objective:** Test network connectivity and port status
```bash
cd exercises && bash solutions/exercise_8_solution.sh --ping google.com
cd exercises && bash solutions/exercise_8_solution.sh --port github.com 443
cd exercises && bash solutions/exercise_8_solution.sh --batch hosts.txt
```
**Skills:** Network operations, connectivity testing, batch processing

#### Exercise 9: Log Rotator
**Objective:** Implement log file rotation with compression
```bash
cd exercises && bash solutions/exercise_9_solution.sh --file app.log --size 100M
cd exercises && bash solutions/exercise_9_solution.sh --file app.log --daily --compress gzip
```
**Skills:** File rotation, compression, scheduling, maintenance

#### Exercise 10: Database Backup
**Objective:** Automated database backup system
```bash
cd exercises && bash solutions/exercise_10_solution.sh --type mysql --db myapp --user admin
cd exercises && bash solutions/exercise_10_solution.sh --type postgres --rotate 7
```
**Skills:** Database operations, backup strategies, automation

### Advanced Level Exercises (11-15)

#### Exercise 11: Server Health Check
**Objective:** Comprehensive server monitoring and alerting
```bash
cd exercises && bash solutions/exercise_11_solution.sh --local --dashboard
cd exercises && bash solutions/exercise_11_solution.sh --alert --email admin@company.com
```
**Skills:** System monitoring, health checks, alerting, reporting

#### Exercise 12: Deployment Script
**Objective:** Automate application deployment with rollback
```bash
cd exercises && bash solutions/exercise_12_solution.sh --app myapp --env production --version v1.2.3
cd exercises && bash solutions/exercise_12_solution.sh --rollback --env staging
```
**Skills:** Deployment automation, version management, rollback strategies

#### Exercise 13: Configuration Manager
**Objective:** Manage configurations across environments
```bash
cd exercises && bash solutions/exercise_13_solution.sh --env production --generate
cd exercises && bash solutions/exercise_13_solution.sh --sync --from staging --to production
```
**Skills:** Configuration management, templating, environment handling

#### Exercise 14: Performance Analyzer
**Objective:** Analyze system performance and generate reports
```bash
cd exercises && bash solutions/exercise_14_solution.sh --monitor --duration 300
cd exercises && bash solutions/exercise_14_solution.sh --benchmark cpu,memory
```
**Skills:** Performance monitoring, benchmarking, analysis, reporting

#### Exercise 15: Automated Testing
**Objective:** Testing framework for bash scripts
```bash
cd exercises && bash solutions/exercise_15_solution.sh --test-dir tests/
cd exercises && bash solutions/exercise_15_solution.sh --parallel --jobs 4 --report coverage.html
```
**Skills:** Test automation, assertion frameworks, parallel execution

## Key Concepts and Patterns

### 1. Variables and Parameters
```bash
# Variable assignment
name="John"
count=10

# Parameter expansion
echo "Hello, ${name}!"
echo "Length: ${#name}"

# Command line arguments
echo "Script: $0"
echo "First arg: $1"
echo "All args: $@"
echo "Arg count: $#"
```

### 2. Conditionals and Comparisons
```bash
# Numeric comparisons
if (( num > 10 )); then
    echo "Greater than 10"
fi

# String comparisons
if [[ "$str" == "hello" ]]; then
    echo "String matches"
fi

# File tests
if [[ -f "$file" ]]; then
    echo "File exists"
elif [[ -d "$file" ]]; then
    echo "Directory exists"
fi
```

### 3. Loops and Iteration
```bash
# For loop with range
for i in {1..10}; do
    echo "Number: $i"
done

# For loop with array
for item in "${array[@]}"; do
    echo "Item: $item"
done

# While loop
while read -r line; do
    echo "Line: $line"
done < file.txt

# Until loop
until [[ $count -eq 0 ]]; do
    echo "Countdown: $count"
    ((count--))
done
```

### 4. Functions and Scope
```bash
# Function definition
my_function() {
    local param=$1
    local result=$((param * 2))
    echo "$result"
    return 0
}

# Function call
result=$(my_function 5)
echo "Result: $result"
```

### 5. Arrays and Data Structures
```bash
# Array creation
fruits=("apple" "banana" "orange")
numbers=(1 2 3 4 5)

# Array access
echo "First fruit: ${fruits[0]}"
echo "All fruits: ${fruits[@]}"
echo "Array length: ${#fruits[@]}"

# Array iteration
for fruit in "${fruits[@]}"; do
    echo "Fruit: $fruit"
done

# Associative arrays (bash 4+)
declare -A colors
colors[red]="#FF0000"
colors[green]="#00FF00"
echo "Red color: ${colors[red]}"
```

### 6. String Processing
```bash
str="Hello World"

# Length
echo "Length: ${#str}"

# Substring
echo "Substring: ${str:0:5}"

# Case conversion
echo "Lowercase: ${str,,}"
echo "Uppercase: ${str^^}"

# Pattern replacement
echo "Replace: ${str/World/Universe}"
echo "Replace all: ${str//l/L}"

# Pattern removal
path="/home/user/documents/file.txt"
echo "Filename: ${path##*/}"
echo "Directory: ${path%/*}"
echo "Extension: ${path##*.}"
```

### 7. Input/Output and Redirection
```bash
# Reading input
echo -n "Enter your name: "
read -r name
echo "Hello, $name!"

# File redirection
echo "Output" > file.txt          # Overwrite
echo "Append" >> file.txt         # Append
command < input.txt               # Input from file
command 2> error.log              # Redirect stderr
command &> all_output.log         # Redirect both stdout and stderr

# Here documents
cat << EOF > config.txt
Setting1=value1
Setting2=value2
EOF
```

### 8. Error Handling and Debugging
```bash
# Exit on error
set -e

# Exit on undefined variable
set -u

# Show commands as they execute
set -x

# Custom error handling
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Check command success
if ! command_that_might_fail; then
    error_exit "Command failed"
fi

# Trap signals
cleanup() {
    echo "Cleaning up..."
    rm -f temp_files
}
trap cleanup EXIT
```

## Advanced Patterns and Techniques

### 1. Argument Parsing
```bash
# Standard argument parsing pattern
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--file)
            FILE="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done
```

### 2. Configuration Management
```bash
# Load configuration file
load_config() {
    local config_file="$1"
    if [[ -f "$config_file" ]]; then
        source "$config_file"
    fi
}

# Default configuration
DEFAULT_CONFIG="config.conf"
USER_CONFIG="$HOME/.myapp/config"

load_config "$DEFAULT_CONFIG"
load_config "$USER_CONFIG"
```

### 3. Logging System
```bash
# Logging levels
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARN=2
LOG_LEVEL_ERROR=3

CURRENT_LOG_LEVEL=$LOG_LEVEL_INFO

log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [[ $level -ge $CURRENT_LOG_LEVEL ]]; then
        case $level in
            $LOG_LEVEL_DEBUG) echo "[$timestamp] DEBUG: $message" ;;
            $LOG_LEVEL_INFO)  echo "[$timestamp] INFO:  $message" ;;
            $LOG_LEVEL_WARN)  echo "[$timestamp] WARN:  $message" ;;
            $LOG_LEVEL_ERROR) echo "[$timestamp] ERROR: $message" >&2 ;;
        esac
    fi
}
```

### 4. Parallel Processing
```bash
# Background jobs
run_parallel() {
    local jobs=()
    local max_jobs=4
    
    for task in "${tasks[@]}"; do
        # Wait if we have too many jobs
        while [[ ${#jobs[@]} -ge $max_jobs ]]; do
            for i in "${!jobs[@]}"; do
                if ! kill -0 "${jobs[i]}" 2>/dev/null; then
                    unset "jobs[i]"
                fi
            done
            jobs=("${jobs[@]}")  # Reindex array
            sleep 0.1
        done
        
        # Start new job
        process_task "$task" &
        jobs+=($!)
    done
    
    # Wait for all jobs to complete
    for job in "${jobs[@]}"; do
        wait "$job"
    done
}
```

## Best Practices and Tips

### 1. Code Organization
- Use functions to break down complex logic
- Keep functions focused on single responsibilities
- Use meaningful variable and function names
- Group related functionality together

### 2. Error Handling
- Always validate input parameters
- Check return codes of important commands
- Provide helpful error messages
- Use appropriate exit codes

### 3. Security Considerations
- Quote variables to prevent word splitting
- Validate user input thoroughly
- Avoid using `eval` with user input
- Use temporary files securely

### 4. Performance Optimization
- Avoid unnecessary subshells
- Use built-in commands when possible
- Cache expensive operations
- Consider parallel processing for independent tasks

### 5. Portability
- Test on different systems (Linux, macOS, etc.)
- Use POSIX-compliant features when possible
- Handle differences in command options
- Provide fallbacks for missing commands

### 6. Documentation
- Include usage examples in help text
- Comment complex logic thoroughly
- Maintain up-to-date documentation
- Provide clear error messages

## Testing and Debugging

### 1. Testing Strategies
```bash
# Unit testing with assertions
assert_equals() {
    if [[ "$1" != "$2" ]]; then
        echo "FAIL: Expected '$2', got '$1'"
        return 1
    fi
    echo "PASS: $3"
}

# Integration testing
test_full_workflow() {
    setup_test_environment
    run_application_workflow
    verify_results
    cleanup_test_environment
}
```

### 2. Debugging Techniques
```bash
# Debug mode
if [[ "${DEBUG:-}" == "true" ]]; then
    set -x
fi

# Conditional debugging
debug() {
    if [[ "${DEBUG:-}" == "true" ]]; then
        echo "DEBUG: $*" >&2
    fi
}

# Performance profiling
profile() {
    local start_time=$(date +%s.%N)
    "$@"
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc -l)
    echo "Command '$*' took ${duration}s" >&2
}
```

## Learning Progression

### Beginner (Weeks 1-2)
1. Complete basic scripts (1-3)
2. Work through exercises 1-5
3. Focus on syntax and basic concepts
4. Practice with simple modifications

### Intermediate (Weeks 3-4)
1. Study advanced scripts (4-8)
2. Complete exercises 6-10
3. Learn error handling and best practices
4. Start building your own scripts

### Advanced (Weeks 5-6)
1. Master exercises 11-15
2. Focus on system administration tasks
3. Learn automation and monitoring
4. Contribute to open-source projects

### Expert (Ongoing)
1. Create complex automation systems
2. Integrate with other tools and languages
3. Teach others and share knowledge
4. Contribute to the bash community

Remember: Practice is key to mastering bash scripting. Start with simple scripts and gradually work your way up to more complex automation tasks!