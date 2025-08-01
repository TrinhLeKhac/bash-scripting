#!/bin/bash
# Exercise 1 Solution: Calculator Script
# Author: Practice Exercise
# Description: Command-line calculator with basic arithmetic operations

# STEP 1: Define colors for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# STEP 2: Function to display usage help
show_usage() {
    echo -e "${YELLOW}Calculator Script Usage:${NC}"
    echo "bash calculator.sh <number1> <operation> <number2>"
    echo ""
    echo "Supported operations:"
    echo "  +  : Addition"
    echo "  -  : Subtraction"
    echo "  *  : Multiplication"
    echo "  /  : Division"
    echo "  %  : Modulo"
    echo "  ^  : Power"
    echo ""
    echo "Examples:"
    echo "  bash calculator.sh 10 + 5"
    echo "  bash calculator.sh 20 / 4"
    echo "  bash calculator.sh 2 ^ 3"
}

# STEP 3: Function to validate if input is a number
is_number() {
    # Use regex to check if input is a valid number (integer or float)
    if [[ $1 =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
        return 0  # Valid number
    else
        return 1  # Invalid number
    fi
}

# STEP 4: Function to perform calculations
calculate() {
    local num1=$1
    local operation=$2
    local num2=$3
    local result
    
    # Perform calculation based on operation
    case $operation in
        "+")
            result=$(echo "scale=2; $num1 + $num2" | bc -l)
            ;;
        "-")
            result=$(echo "scale=2; $num1 - $num2" | bc -l)
            ;;
        "*")
            result=$(echo "scale=2; $num1 * $num2" | bc -l)
            ;;
        "/")
            # Check for division by zero
            if [[ $(echo "$num2 == 0" | bc -l) -eq 1 ]]; then
                echo -e "${RED}Error: Division by zero${NC}"
                return 1
            fi
            result=$(echo "scale=2; $num1 / $num2" | bc -l)
            ;;
        "%")
            # Check for modulo by zero
            if [[ $(echo "$num2 == 0" | bc -l) -eq 1 ]]; then
                echo -e "${RED}Error: Modulo by zero${NC}"
                return 1
            fi
            result=$(echo "scale=2; $num1 % $num2" | bc -l)
            ;;
        "^")
            result=$(echo "scale=2; $num1 ^ $num2" | bc -l)
            ;;
        *)
            echo -e "${RED}Error: Unsupported operation '$operation'${NC}"
            return 1
            ;;
    esac
    
    # Format result to always show 2 decimal places
    printf "${GREEN}%.2f${NC}\n" "$result"
    return 0
}

# STEP 5: Main script logic
main() {
    # Check if correct number of arguments provided
    if [[ $# -ne 3 ]]; then
        echo -e "${RED}Error: Invalid number of arguments${NC}"
        echo ""
        show_usage
        exit 1
    fi
    
    # Get arguments
    local num1=$1
    local operation=$2
    local num2=$3
    
    # Validate first number
    if ! is_number "$num1"; then
        echo -e "${RED}Error: '$num1' is not a valid number${NC}"
        exit 1
    fi
    
    # Validate second number
    if ! is_number "$num2"; then
        echo -e "${RED}Error: '$num2' is not a valid number${NC}"
        exit 1
    fi
    
    # Perform calculation
    calculate "$num1" "$operation" "$num2"
}

# STEP 6: Execute main function with all arguments
main "$@"