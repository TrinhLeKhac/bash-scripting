# Bash Scripting Practice Exercises

## Overview
This directory contains 15 comprehensive bash scripting exercises designed to teach all aspects of bash programming, from basic concepts to advanced system administration tasks.

## Exercise Categories

### Basic Level (1-5)
- **Exercise 1**: Calculator Script - Basic arithmetic operations
- **Exercise 2**: File Organizer - Sort files by extension
- **Exercise 3**: Password Generator - Generate secure passwords
- **Exercise 4**: System Information - Display system details
- **Exercise 5**: Text File Analyzer - Analyze text file statistics

### Intermediate Level (6-10)
- **Exercise 6**: Directory Tree Generator - Visual directory structure
- **Exercise 7**: Process Monitor - Monitor and manage processes
- **Exercise 8**: Network Checker - Test network connectivity
- **Exercise 9**: Log Rotator - Implement log rotation
- **Exercise 10**: Database Backup - Automated database backups

### Advanced Level (11-15)
- **Exercise 11**: Server Health Check - Comprehensive monitoring
- **Exercise 12**: Deployment Script - Application deployment automation
- **Exercise 13**: Configuration Manager - Manage app configurations
- **Exercise 14**: Performance Analyzer - System performance analysis
- **Exercise 15**: Automated Testing - Testing framework for bash scripts

## How to Use These Exercises

### 1. Read the Exercise Description
```bash
# View exercise requirements
cat exercise_1.md
```

### 2. Try to Solve It Yourself
Create your own solution before looking at the provided one:
```bash
# Create your solution
nano my_calculator.sh
chmod +x my_calculator.sh
./my_calculator.sh 10 + 5
```

### 3. Check the Provided Solution
```bash
# Run the official solution
bash solutions/exercise_1_solution.sh 10 + 5

# Study the code
cat solutions/exercise_1_solution.sh
```

### 4. Test Different Scenarios
```bash
# Test edge cases
bash solutions/exercise_1_solution.sh 10 / 0
bash solutions/exercise_1_solution.sh abc + 5
bash solutions/exercise_1_solution.sh --help
```

## Running Examples

### Basic Examples
```bash
# Calculator
cd exercises
bash solutions/exercise_1_solution.sh 15 + 25

# File Organizer
bash solutions/exercise_2_solution.sh /path/to/messy/directory

# Password Generator
bash solutions/exercise_3_solution.sh --length 16 --count 3
```

### Intermediate Examples
```bash
# Directory Tree
bash solutions/exercise_6_solution.sh . --depth 3

# Process Monitor
bash solutions/exercise_7_solution.sh --top-cpu 5

# Network Checker
bash solutions/exercise_8_solution.sh --ping google.com
```

### Advanced Examples
```bash
# Health Check
bash solutions/exercise_11_solution.sh --local --dashboard

# Deployment
bash solutions/exercise_12_solution.sh --app myapp --env staging --version v1.0

# Testing Framework
bash solutions/exercise_15_solution.sh --test-dir tests/
```

## Exercise Structure

Each exercise includes:
- **Description file** (`exercise_X.md`) - Requirements and specifications
- **Solution file** (`solutions/exercise_X_solution.sh`) - Complete implementation
- **Test cases** - Examples to verify functionality
- **Step-by-step comments** - Detailed code explanations

## Learning Path

### Beginner Path
1. Start with Exercise 1 (Calculator)
2. Progress through Exercises 2-5
3. Focus on understanding basic concepts:
   - Variables and parameters
   - Conditionals and loops
   - Functions
   - Input/output handling

### Intermediate Path
1. Complete Exercises 6-10
2. Learn advanced concepts:
   - Array operations
   - String processing
   - File operations
   - Error handling
   - Process management

### Advanced Path
1. Tackle Exercises 11-15
2. Master system administration:
   - System monitoring
   - Network operations
   - Automation
   - Configuration management
   - Testing frameworks

## Key Features of Solutions

### Code Quality
- **Comprehensive error handling**
- **Input validation**
- **Cross-platform compatibility**
- **Detailed documentation**

### User Experience
- **Color-coded output**
- **Help messages**
- **Progress indicators**
- **Interactive modes**

### Best Practices
- **Modular functions**
- **Configuration files**
- **Logging capabilities**
- **Security considerations**

## Testing Your Solutions

### Unit Testing
```bash
# Use the testing framework from Exercise 15
bash solutions/exercise_15_solution.sh --test-dir tests/
```

### Manual Testing
```bash
# Test with various inputs
bash your_solution.sh --help
bash your_solution.sh --invalid-option
bash your_solution.sh # (no arguments)
```

### Performance Testing
```bash
# Use performance analyzer from Exercise 14
bash solutions/exercise_14_solution.sh --benchmark cpu
```

## Common Patterns Used

### Argument Parsing
```bash
while [[ $# -gt 0 ]]; do
    case $1 in
        --option) VARIABLE=$2; shift 2 ;;
        --flag) FLAG=true; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done
```

### Error Handling
```bash
if [[ ! -f "$file" ]]; then
    echo -e "${RED}Error: File not found${NC}"
    exit 1
fi
```

### Logging
```bash
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}
```

## Troubleshooting

### Common Issues
1. **Permission denied**: Use `chmod +x script.sh`
2. **Command not found**: Check if required tools are installed
3. **Syntax errors**: Use `bash -n script.sh` to check syntax

### Debugging Tips
```bash
# Enable debug mode
bash -x script.sh

# Add debug output in script
set -x  # Enable debugging
set +x  # Disable debugging
```

## Additional Resources

### Documentation
- Each solution contains detailed step-by-step comments
- Exercise descriptions include usage examples
- Test cases demonstrate expected behavior

### Extensions
- Modify exercises to add new features
- Combine multiple exercises into larger projects
- Create your own exercises following the same pattern

## Contributing

Feel free to:
- Improve existing solutions
- Add new test cases
- Create additional exercises
- Fix bugs or enhance documentation

Remember: The goal is to learn bash scripting through practical, real-world examples!