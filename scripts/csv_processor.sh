#!/bin/bash
# Shebang: Specify script uses bash interpreter

# CSV Data Processor - Script to process and analyze CSV data
# Usage: ./csv_processor.sh <csv_file> [operation]

# STEP 1: Get parameters from command line
CSV_FILE=$1  # CSV file name to process
OPERATION=${2:-"summary"}  # Operation (default is "summary" if no parameter)

# STEP 2: Check if CSV file exists
if [[ ! -f "$CSV_FILE" ]]; then  # -f checks if file exists
    echo "Error: CSV file $CSV_FILE not found!"
    exit 1  # Exit with error code 1
fi

# STEP 3: Function to count columns in CSV
get_column_count() {
    head -1 "$1" | tr ',' '\n' | wc -l  # head -1: get first line, tr: replace , with newline, wc -l: count lines
}

# STEP 4: Function to count data rows (excluding header)
get_row_count() {
    tail -n +2 "$1" | wc -l  # tail -n +2: start from line 2, wc -l: count lines
}

# STEP 5: Function to display CSV file summary
show_summary() {
    echo "=== CSV File Summary ==="
    echo "File: $1"  # File name
    echo "Columns: $(get_column_count "$1")"  # Number of columns
    echo "Rows (data): $(get_row_count "$1")"  # Number of data rows
    echo "Total lines: $(wc -l < "$1")"  # Total number of lines
    echo ""
    echo "=== Column Headers ==="
    head -1 "$1" | tr ',' '\n' | nl  # nl: number each header
}

# STEP 6: Function to show statistics for numeric columns
show_stats() {
    echo "=== Numeric Column Statistics ==="
    local col_num=1  # Local variable to count columns
    head -1 "$CSV_FILE" | tr ',' '\n' | while read -r header; do  # Read each header
        echo "Column $col_num: $header"
        # Extract column data (skip header)
        tail -n +2 "$CSV_FILE" | cut -d',' -f$col_num | grep -E '^[0-9.]+$' | {  # Filter only numbers
            sum=0     # Sum
            count=0   # Count
            min=""    # Minimum value
            max=""    # Maximum value
            while read -r value; do  # Read each value
                if [[ -n "$value" ]]; then  # Check value is not empty
                    sum=$(echo "$sum + $value" | bc -l)  # Calculate sum using bc
                    count=$((count + 1))  # Increment count
                    # Update min
                    if [[ -z "$min" ]] || (( $(echo "$value < $min" | bc -l) )); then
                        min=$value
                    fi
                    # Update max
                    if [[ -z "$max" ]] || (( $(echo "$value > $max" | bc -l) )); then
                        max=$value
                    fi
                fi
            done
            if [[ $count -gt 0 ]]; then  # If there is data
                avg=$(echo "scale=2; $sum / $count" | bc -l)  # Calculate average
                echo "  Count: $count, Min: $min, Max: $max, Average: $avg"
            else
                echo "  No numeric data found"
            fi
        }
        col_num=$((col_num + 1))  # Increment column number
    done
}

# STEP 7: Function to filter data by condition
filter_data() {
    echo "Enter column number to filter by:"
    read -r col_num  # Read column number from user
    echo "Enter value to filter:"
    read -r filter_value  # Read filter value from user
    
    echo "=== Filtered Results ==="
    head -1 "$CSV_FILE"  # Display header
    # Use awk to filter data: -F',' is delimiter, -v passes variables, ~ is pattern matching
    tail -n +2 "$CSV_FILE" | awk -F',' -v col="$col_num" -v val="$filter_value" '$col ~ val'
}

# STEP 8: Main menu - handle different operations
case $OPERATION in  # case statement to handle options
    "summary")  # Show summary
        show_summary "$CSV_FILE"
        ;;
    "stats")  # Show statistics
        show_stats
        ;;
    "filter")  # Filter data
        filter_data
        ;;
    "interactive")  # Interactive mode
        while true; do  # Infinite loop for menu
            echo ""
            echo "=== CSV Processor Menu ==="
            echo "1. Show Summary"
            echo "2. Show Statistics"
            echo "3. Filter Data"
            echo "4. Exit"
            echo -n "Choose option (1-4): "
            read -r choice  # Read choice from user
            
            case $choice in  # Handle choice
                1) show_summary "$CSV_FILE" ;;  # Call corresponding function
                2) show_stats ;;
                3) filter_data ;;
                4) echo "Goodbye!"; exit 0 ;;  # Exit program
                *) echo "Invalid option!" ;;  # Invalid choice
            esac
        done
        ;;
    *)  # Invalid case
        echo "Usage: $0 <csv_file> [summary|stats|filter|interactive]"
        exit 1
        ;;
esac  # End case statement