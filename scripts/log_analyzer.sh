#!/bin/bash
# Shebang: Specify script uses bash interpreter

# Log Analyzer Script - Analyze log files
# Usage: ./log_analyzer.sh <log_file>

# STEP 1: Get parameters and setup variables
LOG_FILE=$1  # Log file to analyze
OUTPUT_DIR="./analysis_results"  # Directory containing analysis results

# STEP 2: Check if log file exists
if [[ ! -f "$LOG_FILE" ]]; then  # -f checks if file exists
    echo "Error: Log file $LOG_FILE not found!"
    echo "Usage: $0 <log_file>"
    exit 1  # Exit with error code
fi

# STEP 3: Create output directory
mkdir -p "$OUTPUT_DIR"  # -p creates parent directories if needed

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to analyze log levels
analyze_log_levels() {
    echo -e "${BLUE}=== Log Level Analysis ===${NC}"
    echo "Analyzing log levels in $LOG_FILE..."
    
    grep -i "error\|warn\|info\|debug" "$LOG_FILE" | \
    sed -E 's/.*(ERROR|WARN|INFO|DEBUG).*/\1/I' | \
    sort | uniq -c | sort -nr > "$OUTPUT_DIR/log_levels.txt"
    
    echo "Results saved to: $OUTPUT_DIR/log_levels.txt"
    cat "$OUTPUT_DIR/log_levels.txt"
}

# Function to find error patterns
find_error_patterns() {
    echo -e "${RED}=== Error Pattern Analysis ===${NC}"
    echo "Finding error patterns..."
    
    grep -i "error\|exception\|fail" "$LOG_FILE" | \
    head -20 > "$OUTPUT_DIR/error_patterns.txt"
    
    echo "Top 20 errors saved to: $OUTPUT_DIR/error_patterns.txt"
    cat "$OUTPUT_DIR/error_patterns.txt"
}

# Function to analyze timestamps
analyze_timestamps() {
    echo -e "${YELLOW}=== Timestamp Analysis ===${NC}"
    echo "Analyzing activity by hour..."
    
    # Extract hour from timestamps (assuming format: YYYY-MM-DD HH:MM:SS)
    grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}' "$LOG_FILE" | \
    cut -d' ' -f2 | sort | uniq -c | sort -nr > "$OUTPUT_DIR/hourly_activity.txt"
    
    echo "Hourly activity saved to: $OUTPUT_DIR/hourly_activity.txt"
    cat "$OUTPUT_DIR/hourly_activity.txt"
}

# Function to find top IPs (if log contains IP addresses)
analyze_ips() {
    echo -e "${GREEN}=== IP Address Analysis ===${NC}"
    echo "Finding top IP addresses..."
    
    grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' "$LOG_FILE" | \
    sort | uniq -c | sort -nr | head -10 > "$OUTPUT_DIR/top_ips.txt"
    
    if [[ -s "$OUTPUT_DIR/top_ips.txt" ]]; then
        echo "Top 10 IPs saved to: $OUTPUT_DIR/top_ips.txt"
        cat "$OUTPUT_DIR/top_ips.txt"
    else
        echo "No IP addresses found in log file."
    fi
}

# Function to generate summary report
generate_summary() {
    echo -e "${BLUE}=== Summary Report ===${NC}"
    local total_lines=$(wc -l < "$LOG_FILE")
    local error_count=$(grep -ci "error" "$LOG_FILE")
    local warning_count=$(grep -ci "warn" "$LOG_FILE")
    local info_count=$(grep -ci "info" "$LOG_FILE")
    
    {
        echo "=== Log Analysis Summary ==="
        echo "File: $LOG_FILE"
        echo "Generated: $(date)"
        echo ""
        echo "Total lines: $total_lines"
        echo "Error count: $error_count"
        echo "Warning count: $warning_count"
        echo "Info count: $info_count"
        echo ""
        echo "Error rate: $(echo "scale=2; $error_count * 100 / $total_lines" | bc -l)%"
        echo "Warning rate: $(echo "scale=2; $warning_count * 100 / $total_lines" | bc -l)%"
    } > "$OUTPUT_DIR/summary_report.txt"
    
    cat "$OUTPUT_DIR/summary_report.txt"
}

# Function to search for specific patterns
search_pattern() {
    echo -n "Enter search pattern: "
    read -r pattern
    echo -e "${YELLOW}Searching for pattern: $pattern${NC}"
    
    grep -n "$pattern" "$LOG_FILE" > "$OUTPUT_DIR/search_results.txt"
    
    if [[ -s "$OUTPUT_DIR/search_results.txt" ]]; then
        echo "Results saved to: $OUTPUT_DIR/search_results.txt"
        echo "Found $(wc -l < "$OUTPUT_DIR/search_results.txt") matches:"
        head -10 "$OUTPUT_DIR/search_results.txt"
        if [[ $(wc -l < "$OUTPUT_DIR/search_results.txt") -gt 10 ]]; then
            echo "... (showing first 10 results)"
        fi
    else
        echo "No matches found for pattern: $pattern"
    fi
}

# Main menu
show_menu() {
    echo ""
    echo -e "${BLUE}=== Log Analyzer Menu ===${NC}"
    echo "Analyzing: $LOG_FILE"
    echo ""
    echo "1. Analyze Log Levels"
    echo "2. Find Error Patterns"
    echo "3. Analyze Timestamps"
    echo "4. Analyze IP Addresses"
    echo "5. Generate Summary Report"
    echo "6. Search Custom Pattern"
    echo "7. Run All Analysis"
    echo "8. Exit"
    echo -n "Choose option (1-8): "
}

# Run all analysis
run_all_analysis() {
    echo -e "${GREEN}Running complete analysis...${NC}"
    analyze_log_levels
    echo ""
    find_error_patterns
    echo ""
    analyze_timestamps
    echo ""
    analyze_ips
    echo ""
    generate_summary
    echo -e "${GREEN}Analysis complete! Results saved in $OUTPUT_DIR/${NC}"
}

# Main loop
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1) analyze_log_levels ;;
        2) find_error_patterns ;;
        3) analyze_timestamps ;;
        4) analyze_ips ;;
        5) generate_summary ;;
        6) search_pattern ;;
        7) run_all_analysis ;;
        8) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option!${NC}" ;;
    esac
done