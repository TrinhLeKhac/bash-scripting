# Exercise 1: Calculator Script

## Objective
Create a command-line calculator that performs basic arithmetic operations.

## Requirements
1. Accept two numbers and an operation as command-line arguments
2. Support operations: +, -, *, /, %, ^ (power)
3. Handle division by zero
4. Display results with 2 decimal places
5. Provide usage help if arguments are missing
6. Validate input (numbers only)

## Usage Examples
```bash
bash calculator.sh 10 + 5     # Output: 15.00
bash calculator.sh 20 / 4     # Output: 5.00
bash calculator.sh 10 / 0     # Output: Error: Division by zero
bash calculator.sh 2 ^ 3      # Output: 8.00
bash calculator.sh            # Output: Usage help
```

## Expected Features
- Input validation
- Error handling
- Formatted output
- Help message
- Support for floating-point numbers

## Test Cases
1. `bash calculator.sh 15 + 25` → `40.00`
2. `bash calculator.sh 100 - 30` → `70.00`
3. `bash calculator.sh 6 * 7` → `42.00`
4. `bash calculator.sh 50 / 10` → `5.00`
5. `bash calculator.sh 17 % 5` → `2.00`
6. `bash calculator.sh 3 ^ 4` → `81.00`
7. `bash calculator.sh 10 / 0` → `Error: Division by zero`
8. `bash calculator.sh abc + 5` → `Error: Invalid number`