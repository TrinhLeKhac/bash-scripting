#!/bin/bash
# Shebang: Specify script uses bash interpreter

# System Monitor Script - Monitor system resources
# Usage: ./system_monitor.sh [interval]

# STEP 1: Get parameters and setup variables
INTERVAL=${1:-5}  # Check interval (default 5 seconds)
LOG_DIR="./logs"  # Directory containing log files
mkdir -p "$LOG_DIR"  # Create log directory if not exists

# STEP 2: Define colors for output
RED='\033[0;31m'     # Red color for critical warnings
GREEN='\033[0;32m'   # Green color for normal status
YELLOW='\033[1;33m'  # Yellow color for warnings
BLUE='\033[0;34m'    # Blue color for information
NC='\033[0m'         # No Color - reset color

# STEP 3: Function to get CPU usage information
get_cpu_usage() {
    if [[ "$OSTYPE" == "darwin"* ]]; then  # Check if macOS
        # macOS: Use top command
        top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//'  # Get CPU % and remove % sign
    else
        # Linux: Read from /proc/stat
        grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$3+$4+$5)} END {print usage}'  # Calculate CPU %
    fi
}

# STEP 4: Function to get Memory usage information
get_memory_usage() {
    if [[ "$OSTYPE" == "darwin"* ]]; then  # macOS
        # Use vm_stat command
        vm_stat | grep "Pages active" | awk '{print $3}' | sed 's/\.//'
    else  # Linux
        # Use free command
        free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}'  # Calculate % memory used
    fi
}

# STEP 5: Function to get Disk usage information
get_disk_usage() {
    # df -h: display disk usage in human-readable format
    # NR==2: get line 2, $5: column 5 (% used)
    df -h / | awk 'NR==2{print $5}' | sed 's/%//'  # Remove % sign at end
}

# STEP 6: Function to get load average
get_load_average() {
    # uptime: display uptime and load average
    # Extract load average part and get first value (1 minute)
    uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//'
}

# STEP 7: Function to log system statistics to CSV
log_stats() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')  # Get current timestamp
    local cpu=$(get_cpu_usage)     # Get CPU usage
    local memory=$(get_memory_usage)  # Get Memory usage
    local disk=$(get_disk_usage)   # Get Disk usage
    local load=$(get_load_average) # Get Load average
    
    # Write to CSV file with format: timestamp,cpu,memory,disk,load
    echo "$timestamp,$cpu,$memory,$disk,$load" >> "$LOG_DIR/system_stats.csv"
}

# Function to display current stats
display_stats() {
    clear
    echo -e "${BLUE}=== System Monitor ===${NC}"
    echo -e "${YELLOW}Time: $(date)${NC}"
    echo ""
    
    local cpu=$(get_cpu_usage)
    local memory=$(get_memory_usage)
    local disk=$(get_disk_usage)
    local load=$(get_load_average)
    
    # CPU Usage
    if (( $(echo "$cpu > 80" | bc -l) )); then
        echo -e "${RED}CPU Usage: ${cpu}%${NC}"
    elif (( $(echo "$cpu > 60" | bc -l) )); then
        echo -e "${YELLOW}CPU Usage: ${cpu}%${NC}"
    else
        echo -e "${GREEN}CPU Usage: ${cpu}%${NC}"
    fi
    
    # Memory Usage
    if (( $(echo "$memory > 80" | bc -l) )); then
        echo -e "${RED}Memory Usage: ${memory}%${NC}"
    elif (( $(echo "$memory > 60" | bc -l) )); then
        echo -e "${YELLOW}Memory Usage: ${memory}%${NC}"
    else
        echo -e "${GREEN}Memory Usage: ${memory}%${NC}"
    fi
    
    # Disk Usage
    if (( disk > 80 )); then
        echo -e "${RED}Disk Usage: ${disk}%${NC}"
    elif (( disk > 60 )); then
        echo -e "${YELLOW}Disk Usage: ${disk}%${NC}"
    else
        echo -e "${GREEN}Disk Usage: ${disk}%${NC}"
    fi
    
    echo -e "${BLUE}Load Average: ${load}${NC}"
    echo ""
    echo -e "${YELLOW}Press Ctrl+C to stop monitoring${NC}"
    echo -e "${YELLOW}Logs saved to: $LOG_DIR/system_stats.csv${NC}"
}

# STEP 9: Initialize CSV log file if not exists
if [[ ! -f "$LOG_DIR/system_stats.csv" ]]; then
    # Create header for CSV file
    echo "timestamp,cpu_usage,memory_usage,disk_usage,load_average" > "$LOG_DIR/system_stats.csv"
fi

echo -e "${GREEN}Starting system monitor (interval: ${INTERVAL}s)${NC}"

# STEP 10: Main loop to monitor system
while true; do  # Infinite loop
    display_stats  # Display statistics on screen
    log_stats      # Log statistics to file
    sleep "$INTERVAL"  # Wait INTERVAL seconds before next check
done