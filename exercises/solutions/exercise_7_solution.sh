#!/bin/bash
# Exercise 7 Solution: Process Monitor

# STEP 1: Setup colors and variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

LOG_FILE="process_monitor.log"
CPU_THRESHOLD=80
MEM_THRESHOLD=80

# STEP 2: Usage function
show_usage() {
    echo "Usage: bash process_monitor.sh [options]"
    echo "Options:"
    echo "  --list              List all processes"
    echo "  --monitor NAME      Monitor specific process"
    echo "  --kill PID          Kill process by PID"
    echo "  --tree              Show process tree"
    echo "  --top-cpu N         Show top N CPU processes"
    echo "  --top-mem N         Show top N memory processes"
    echo "  --search PATTERN    Search processes by pattern"
    echo "  --alert-cpu PCT     Set CPU alert threshold"
    echo "  --alert-mem PCT     Set memory alert threshold"
}

# STEP 3: Log function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# STEP 4: List processes function
list_processes() {
    echo -e "${BLUE}=== Running Processes ===${NC}"
    printf "%-8s %-8s %-6s %-6s %-20s %s\n" "PID" "USER" "CPU%" "MEM%" "COMMAND" "ARGS"
    echo "--------------------------------------------------------------------"
    ps aux | tail -n +2 | while read user pid cpu mem vsz rss tty stat start time command args; do
        printf "%-8s %-8s %-6s %-6s %-20s %s\n" "$pid" "$user" "$cpu" "$mem" "$command" "$args"
    done | head -20
}

# STEP 5: Monitor specific process
monitor_process() {
    local process_name=$1
    echo -e "${BLUE}Monitoring process: $process_name${NC}"
    log_message "Started monitoring process: $process_name"
    
    while true; do
        local pids=$(pgrep "$process_name")
        if [[ -n "$pids" ]]; then
            echo -e "${GREEN}[$(date '+%H:%M:%S')] Process active:${NC}"
            ps aux | grep "$process_name" | grep -v grep | while read user pid cpu mem rest; do
                echo "  PID: $pid, CPU: $cpu%, MEM: $mem%"
                
                # Check thresholds
                if (( $(echo "$cpu > $CPU_THRESHOLD" | bc -l) )); then
                    echo -e "${RED}  ALERT: High CPU usage!${NC}"
                    log_message "HIGH CPU: Process $process_name (PID: $pid) using $cpu% CPU"
                fi
                
                if (( $(echo "$mem > $MEM_THRESHOLD" | bc -l) )); then
                    echo -e "${RED}  ALERT: High memory usage!${NC}"
                    log_message "HIGH MEM: Process $process_name (PID: $pid) using $mem% memory"
                fi
            done
        else
            echo -e "${YELLOW}[$(date '+%H:%M:%S')] Process not found${NC}"
        fi
        sleep 5
    done
}

# STEP 6: Kill process function
kill_process() {
    local pid=$1
    
    if ! kill -0 "$pid" 2>/dev/null; then
        echo -e "${RED}Process $pid not found${NC}"
        return 1
    fi
    
    # Show process info
    echo -e "${YELLOW}Process to kill:${NC}"
    ps aux | grep "^[^ ]* *$pid " | grep -v grep
    
    # Confirm kill
    echo -n "Are you sure you want to kill this process? (y/N): "
    read -r confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        if kill "$pid"; then
            log_message "Killed process $pid"
            echo -e "${GREEN}Process killed successfully${NC}"
        else
            echo -e "${RED}Failed to kill process${NC}"
        fi
    else
        echo -e "${YELLOW}Kill cancelled${NC}"
    fi
}

# STEP 7: Show process tree
show_tree() {
    echo -e "${BLUE}=== Process Tree ===${NC}"
    if command -v pstree >/dev/null; then
        pstree -p
    else
        ps auxf | head -20
    fi
}

# STEP 8: Show top CPU processes
show_top_cpu() {
    local count=${1:-10}
    echo -e "${BLUE}=== Top $count CPU Processes ===${NC}"
    ps aux --sort=-%cpu | head -n $((count + 1))
}

# STEP 9: Show top memory processes
show_top_mem() {
    local count=${1:-10}
    echo -e "${BLUE}=== Top $count Memory Processes ===${NC}"
    ps aux --sort=-%mem | head -n $((count + 1))
}

# STEP 10: Search processes
search_processes() {
    local pattern=$1
    echo -e "${BLUE}=== Processes matching '$pattern' ===${NC}"
    ps aux | grep -i "$pattern" | grep -v grep
}

# STEP 11: Main function
main() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --list)
                list_processes
                shift
                ;;
            --monitor)
                monitor_process "$2"
                shift 2
                ;;
            --kill)
                kill_process "$2"
                shift 2
                ;;
            --tree)
                show_tree
                shift
                ;;
            --top-cpu)
                show_top_cpu "$2"
                shift 2
                ;;
            --top-mem)
                show_top_mem "$2"
                shift 2
                ;;
            --search)
                search_processes "$2"
                shift 2
                ;;
            --alert-cpu)
                CPU_THRESHOLD=$2
                echo -e "${GREEN}CPU alert threshold set to $2%${NC}"
                shift 2
                ;;
            --alert-mem)
                MEM_THRESHOLD=$2
                echo -e "${GREEN}Memory alert threshold set to $2%${NC}"
                shift 2
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Default action
    if [[ $# -eq 0 ]]; then
        list_processes
    fi
}

main "$@"