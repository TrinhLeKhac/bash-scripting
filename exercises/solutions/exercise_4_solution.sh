#!/bin/bash
# Exercise 4 Solution: System Information Display
# Author: Practice Exercise
# Description: Comprehensive system information reporting tool

# STEP 1: Define colors and global variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SHOW_ALL=true
SHOW_SYSTEM=false
SHOW_CPU=false
SHOW_MEMORY=false
SHOW_DISK=false
SHOW_NETWORK=false
SHOW_PROCESSES=false
OUTPUT_FILE=""
JSON_OUTPUT=false

# STEP 2: Function to display usage help
show_usage() {
    echo -e "${YELLOW}System Information Display Usage:${NC}"
    echo "bash system_info.sh [options]"
    echo ""
    echo "Options:"
    echo "  --all           Show all information (default)"
    echo "  --system        Show system overview only"
    echo "  --cpu           Show CPU information only"
    echo "  --memory        Show memory information only"
    echo "  --disk          Show disk information only"
    echo "  --network       Show network information only"
    echo "  --processes     Show process information only"
    echo "  --save FILE     Save report to file"
    echo "  --json          Output in JSON format"
    echo "  --help          Show this help"
}

# STEP 3: Function to detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            echo "$PRETTY_NAME"
        else
            echo "Linux"
        fi
    else
        echo "$OSTYPE"
    fi
}

# STEP 4: Function to get system overview
get_system_info() {
    local hostname=$(hostname)
    local os=$(detect_os)
    local kernel=$(uname -r)
    local arch=$(uname -m)
    local uptime_info=$(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')
    local current_time=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [[ "$JSON_OUTPUT" == true ]]; then
        cat << EOF
  "system": {
    "hostname": "$hostname",
    "os": "$os",
    "kernel": "$kernel",
    "architecture": "$arch",
    "uptime": "$uptime_info",
    "current_time": "$current_time"
  },
EOF
    else
        echo -e "${BLUE}--- System Overview ---${NC}"
        echo -e "${GREEN}Hostname:${NC} $hostname"
        echo -e "${GREEN}OS:${NC} $os"
        echo -e "${GREEN}Kernel:${NC} $kernel"
        echo -e "${GREEN}Architecture:${NC} $arch"
        echo -e "${GREEN}Uptime:${NC} $uptime_info"
        echo -e "${GREEN}Current Time:${NC} $current_time"
        echo ""
    fi
}

# STEP 5: Function to get CPU information
get_cpu_info() {
    local cpu_model=""
    local cpu_cores=""
    local cpu_usage=""
    local load_avg=""
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        cpu_model=$(sysctl -n machdep.cpu.brand_string)
        cpu_cores=$(sysctl -n hw.ncpu)
        cpu_usage=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
        load_avg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ *//')
    else
        # Linux
        cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^ *//')
        cpu_cores=$(nproc)
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
        load_avg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ *//')
    fi
    
    if [[ "$JSON_OUTPUT" == true ]]; then
        cat << EOF
  "cpu": {
    "model": "$cpu_model",
    "cores": $cpu_cores,
    "usage_percent": "$cpu_usage",
    "load_average": "$load_avg"
  },
EOF
    else
        echo -e "${BLUE}--- CPU Information ---${NC}"
        echo -e "${GREEN}Model:${NC} $cpu_model"
        echo -e "${GREEN}Cores:${NC} $cpu_cores"
        echo -e "${GREEN}Current Usage:${NC} ${cpu_usage}%"
        echo -e "${GREEN}Load Average:${NC} $load_avg"
        echo ""
    fi
}

# STEP 6: Function to get memory information
get_memory_info() {
    local total_mem=""
    local used_mem=""
    local free_mem=""
    local mem_usage=""
    local swap_info=""
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        local mem_pressure=$(memory_pressure | grep "System-wide memory free percentage" | awk '{print $5}' | sed 's/%//')
        total_mem=$(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024 " GB"}')
        used_mem="N/A"
        free_mem="${mem_pressure}% free"
        mem_usage=$((100 - mem_pressure))
        swap_info=$(sysctl -n vm.swapusage | awk '{print $3, $6}')
    else
        # Linux
        local mem_info=$(free -h | grep "Mem:")
        total_mem=$(echo $mem_info | awk '{print $2}')
        used_mem=$(echo $mem_info | awk '{print $3}')
        free_mem=$(echo $mem_info | awk '{print $4}')
        mem_usage=$(free | grep "Mem:" | awk '{printf "%.1f", $3/$2 * 100.0}')
        swap_info=$(free -h | grep "Swap:" | awk '{print $2 " total, " $3 " used"}')
    fi
    
    if [[ "$JSON_OUTPUT" == true ]]; then
        cat << EOF
  "memory": {
    "total": "$total_mem",
    "used": "$used_mem",
    "free": "$free_mem",
    "usage_percent": "$mem_usage",
    "swap": "$swap_info"
  },
EOF
    else
        echo -e "${BLUE}--- Memory Information ---${NC}"
        echo -e "${GREEN}Total RAM:${NC} $total_mem"
        echo -e "${GREEN}Used:${NC} $used_mem"
        echo -e "${GREEN}Free:${NC} $free_mem"
        echo -e "${GREEN}Usage:${NC} ${mem_usage}%"
        echo -e "${GREEN}Swap:${NC} $swap_info"
        echo ""
    fi
}

# STEP 7: Function to get disk information
get_disk_info() {
    if [[ "$JSON_OUTPUT" == true ]]; then
        echo '  "disk": ['
        local first=true
        df -h | grep -v "Filesystem" | while read filesystem size used avail percent mount; do
            if [[ "$first" == true ]]; then
                first=false
            else
                echo ","
            fi
            cat << EOF
    {
      "filesystem": "$filesystem",
      "size": "$size",
      "used": "$used",
      "available": "$avail",
      "usage_percent": "$percent",
      "mount_point": "$mount"
    }
EOF
        done
        echo "  ],"
    else
        echo -e "${BLUE}--- Disk Information ---${NC}"
        df -h | head -1
        df -h | grep -v "Filesystem" | while read filesystem size used avail percent mount; do
            echo -e "${GREEN}$filesystem${NC} $size $used $avail $percent $mount"
        done
        echo ""
    fi
}

# STEP 8: Function to get network information
get_network_info() {
    if [[ "$JSON_OUTPUT" == true ]]; then
        echo '  "network": {'
        echo '    "interfaces": ['
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            ifconfig | grep -E "^[a-z]" | cut -d: -f1 | while read interface; do
                local ip=$(ifconfig "$interface" | grep "inet " | awk '{print $2}')
                echo "      {\"interface\": \"$interface\", \"ip\": \"$ip\"}"
            done
        else
            # Linux
            ip addr show | grep -E "^[0-9]" | cut -d: -f2 | while read interface; do
                local ip=$(ip addr show "$interface" | grep "inet " | awk '{print $2}' | cut -d/ -f1)
                echo "      {\"interface\": \"$interface\", \"ip\": \"$ip\"}"
            done
        fi
        
        echo '    ]'
        echo '  },'
    else
        echo -e "${BLUE}--- Network Information ---${NC}"
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            ifconfig | grep -E "^[a-z]|inet " | while read line; do
                if [[ "$line" =~ ^[a-z] ]]; then
                    echo -e "${GREEN}Interface:${NC} $(echo $line | cut -d: -f1)"
                elif [[ "$line" =~ inet ]]; then
                    echo -e "${GREEN}  IP Address:${NC} $(echo $line | awk '{print $2}')"
                fi
            done
        else
            # Linux
            ip addr show | grep -E "^[0-9]|inet " | while read line; do
                if [[ "$line" =~ ^[0-9] ]]; then
                    echo -e "${GREEN}Interface:${NC} $(echo $line | cut -d: -f2 | sed 's/^ *//')"
                elif [[ "$line" =~ inet ]]; then
                    echo -e "${GREEN}  IP Address:${NC} $(echo $line | awk '{print $2}' | cut -d/ -f1)"
                fi
            done
        fi
        echo ""
    fi
}

# STEP 9: Function to get process information
get_process_info() {
    local total_processes=$(ps aux | wc -l)
    local top_cpu=$(ps aux --sort=-%cpu | head -6 | tail -5)
    local top_mem=$(ps aux --sort=-%mem | head -6 | tail -5)
    
    if [[ "$JSON_OUTPUT" == true ]]; then
        cat << EOF
  "processes": {
    "total": $total_processes,
    "top_cpu": "$(echo "$top_cpu" | tr '\n' ';')",
    "top_memory": "$(echo "$top_mem" | tr '\n' ';')"
  }
EOF
    else
        echo -e "${BLUE}--- Process Information ---${NC}"
        echo -e "${GREEN}Total Processes:${NC} $total_processes"
        echo ""
        echo -e "${GREEN}Top CPU Processes:${NC}"
        echo "$top_cpu"
        echo ""
        echo -e "${GREEN}Top Memory Processes:${NC}"
        echo "$top_mem"
        echo ""
    fi
}

# STEP 10: Function to generate report header
generate_header() {
    local current_time=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [[ "$JSON_OUTPUT" == true ]]; then
        echo "{"
        echo "  \"report_generated\": \"$current_time\","
    else
        echo -e "${CYAN}=== SYSTEM INFORMATION REPORT ===${NC}"
        echo -e "${CYAN}Generated: $current_time${NC}"
        echo ""
    fi
}

# STEP 11: Function to generate report footer
generate_footer() {
    if [[ "$JSON_OUTPUT" == true ]]; then
        echo "}"
    else
        echo -e "${CYAN}=== END OF REPORT ===${NC}"
    fi
}

# STEP 12: Function to generate complete report
generate_report() {
    local output=""
    
    # Capture output
    if [[ "$SHOW_ALL" == true ]]; then
        output=$(
            generate_header
            get_system_info
            get_cpu_info
            get_memory_info
            get_disk_info
            get_network_info
            get_process_info
            generate_footer
        )
    else
        output=$(generate_header)
        [[ "$SHOW_SYSTEM" == true ]] && output+=$(get_system_info)
        [[ "$SHOW_CPU" == true ]] && output+=$(get_cpu_info)
        [[ "$SHOW_MEMORY" == true ]] && output+=$(get_memory_info)
        [[ "$SHOW_DISK" == true ]] && output+=$(get_disk_info)
        [[ "$SHOW_NETWORK" == true ]] && output+=$(get_network_info)
        [[ "$SHOW_PROCESSES" == true ]] && output+=$(get_process_info)
        output+=$(generate_footer)
    fi
    
    # Output to file or stdout
    if [[ -n "$OUTPUT_FILE" ]]; then
        echo "$output" > "$OUTPUT_FILE"
        echo -e "${GREEN}Report saved to: $OUTPUT_FILE${NC}"
    else
        echo "$output"
    fi
}

# STEP 13: Main function
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                SHOW_ALL=true
                shift
                ;;
            --system)
                SHOW_ALL=false
                SHOW_SYSTEM=true
                shift
                ;;
            --cpu)
                SHOW_ALL=false
                SHOW_CPU=true
                shift
                ;;
            --memory)
                SHOW_ALL=false
                SHOW_MEMORY=true
                shift
                ;;
            --disk)
                SHOW_ALL=false
                SHOW_DISK=true
                shift
                ;;
            --network)
                SHOW_ALL=false
                SHOW_NETWORK=true
                shift
                ;;
            --processes)
                SHOW_ALL=false
                SHOW_PROCESSES=true
                shift
                ;;
            --save)
                OUTPUT_FILE=$2
                shift 2
                ;;
            --json)
                JSON_OUTPUT=true
                shift
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
    
    # Generate and display report
    generate_report
}

# STEP 14: Execute main function with all arguments
main "$@"