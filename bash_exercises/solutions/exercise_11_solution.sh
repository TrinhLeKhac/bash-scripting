#!/bin/bash
# Exercise 11 Solution: Server Health Check

# STEP 1: Setup colors and variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=90
ALERT_EMAIL=""
OUTPUT_FILE=""

# STEP 2: Usage function
show_usage() {
    echo "Usage: bash health_check.sh [options]"
    echo "Options:"
    echo "  --local             Check local server"
    echo "  --server HOST       Check remote server"
    echo "  --config FILE       Use configuration file"
    echo "  --alert             Enable alerts"
    echo "  --email EMAIL       Alert email address"
    echo "  --dashboard         Generate HTML dashboard"
    echo "  --output FILE       Output file for dashboard"
    echo "  --cpu-threshold N   CPU alert threshold (default: 80)"
    echo "  --mem-threshold N   Memory alert threshold (default: 80)"
    echo "  --disk-threshold N  Disk alert threshold (default: 90)"
}

# STEP 3: Check CPU usage
check_cpu() {
    local cpu_usage
    if [[ "$OSTYPE" == "darwin"* ]]; then
        cpu_usage=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    else
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
    fi
    
    echo "CPU:$cpu_usage"
    
    if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
        return 1
    fi
    return 0
}

# STEP 4: Check memory usage
check_memory() {
    local mem_usage
    if [[ "$OSTYPE" == "darwin"* ]]; then
        mem_usage=$(vm_stat | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
    else
        mem_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    fi
    
    echo "MEM:$mem_usage"
    
    if (( $(echo "$mem_usage > $MEM_THRESHOLD" | bc -l) )); then
        return 1
    fi
    return 0
}

# STEP 5: Check disk usage
check_disk() {
    local max_usage=0
    local critical_mount=""
    
    df -h | grep -v "Filesystem" | while read filesystem size used avail percent mount; do
        local usage=$(echo "$percent" | sed 's/%//')
        if [[ $usage -gt $max_usage ]]; then
            max_usage=$usage
            critical_mount=$mount
        fi
    done
    
    echo "DISK:$max_usage"
    
    if [[ $max_usage -gt $DISK_THRESHOLD ]]; then
        return 1
    fi
    return 0
}

# STEP 6: Check services
check_services() {
    local services=("ssh" "nginx" "apache2" "mysql" "postgresql")
    local running_services=0
    local total_services=0
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            running_services=$((running_services + 1))
        fi
        total_services=$((total_services + 1))
    done
    
    echo "SERVICES:$running_services/$total_services"
    return 0
}

# STEP 7: Check network connectivity
check_network() {
    local hosts=("google.com" "8.8.8.8")
    local reachable=0
    
    for host in "${hosts[@]}"; do
        if ping -c 1 -W 5 "$host" >/dev/null 2>&1; then
            reachable=$((reachable + 1))
        fi
    done
    
    echo "NETWORK:$reachable/${#hosts[@]}"
    
    if [[ $reachable -eq 0 ]]; then
        return 1
    fi
    return 0
}

# STEP 8: Generate health report
generate_report() {
    local server=${1:-"localhost"}
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${BLUE}=== Health Check Report ===${NC}"
    echo -e "${BLUE}Server: $server${NC}"
    echo -e "${BLUE}Time: $timestamp${NC}"
    echo ""
    
    local overall_status="HEALTHY"
    
    # Check CPU
    local cpu_result=$(check_cpu)
    local cpu_status=$?
    echo -e "${GREEN}CPU Usage: $(echo $cpu_result | cut -d: -f2)%${NC}"
    [[ $cpu_status -ne 0 ]] && overall_status="WARNING"
    
    # Check Memory
    local mem_result=$(check_memory)
    local mem_status=$?
    echo -e "${GREEN}Memory Usage: $(echo $mem_result | cut -d: -f2)%${NC}"
    [[ $mem_status -ne 0 ]] && overall_status="WARNING"
    
    # Check Disk
    local disk_result=$(check_disk)
    local disk_status=$?
    echo -e "${GREEN}Disk Usage: $(echo $disk_result | cut -d: -f2)%${NC}"
    [[ $disk_status -ne 0 ]] && overall_status="CRITICAL"
    
    # Check Services
    local service_result=$(check_services)
    echo -e "${GREEN}Services: $(echo $service_result | cut -d: -f2)${NC}"
    
    # Check Network
    local network_result=$(check_network)
    local network_status=$?
    echo -e "${GREEN}Network: $(echo $network_result | cut -d: -f2)${NC}"
    [[ $network_status -ne 0 ]] && overall_status="CRITICAL"
    
    echo ""
    case $overall_status in
        "HEALTHY") echo -e "${GREEN}Overall Status: HEALTHY${NC}" ;;
        "WARNING") echo -e "${YELLOW}Overall Status: WARNING${NC}" ;;
        "CRITICAL") echo -e "${RED}Overall Status: CRITICAL${NC}" ;;
    esac
    
    return $([[ "$overall_status" == "HEALTHY" ]] && echo 0 || echo 1)
}

# STEP 9: Generate HTML dashboard
generate_dashboard() {
    local output_file=${OUTPUT_FILE:-"health_dashboard.html"}
    
    cat > "$output_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Server Health Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .healthy { color: green; }
        .warning { color: orange; }
        .critical { color: red; }
        .metric { margin: 10px 0; padding: 10px; border: 1px solid #ccc; }
    </style>
</head>
<body>
    <h1>Server Health Dashboard</h1>
    <p>Generated: $(date)</p>
    
    <div class="metric">
        <h3>CPU Usage</h3>
        <p class="healthy">$(check_cpu | cut -d: -f2)%</p>
    </div>
    
    <div class="metric">
        <h3>Memory Usage</h3>
        <p class="healthy">$(check_memory | cut -d: -f2)%</p>
    </div>
    
    <div class="metric">
        <h3>Disk Usage</h3>
        <p class="warning">$(check_disk | cut -d: -f2)%</p>
    </div>
    
    <div class="metric">
        <h3>Network Status</h3>
        <p class="healthy">$(check_network | cut -d: -f2) hosts reachable</p>
    </div>
</body>
</html>
EOF
    
    echo -e "${GREEN}Dashboard generated: $output_file${NC}"
}

# STEP 10: Main function
main() {
    local server="localhost"
    local enable_alerts=false
    local generate_html=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --local) server="localhost"; shift ;;
            --server) server=$2; shift 2 ;;
            --alert) enable_alerts=true; shift ;;
            --email) ALERT_EMAIL=$2; shift 2 ;;
            --dashboard) generate_html=true; shift ;;
            --output) OUTPUT_FILE=$2; shift 2 ;;
            --cpu-threshold) CPU_THRESHOLD=$2; shift 2 ;;
            --mem-threshold) MEM_THRESHOLD=$2; shift 2 ;;
            --disk-threshold) DISK_THRESHOLD=$2; shift 2 ;;
            --help) show_usage; exit 0 ;;
            *) echo -e "${RED}Unknown option: $1${NC}"; show_usage; exit 1 ;;
        esac
    done
    
    # Generate report
    generate_report "$server"
    local health_status=$?
    
    # Generate HTML dashboard if requested
    if [[ "$generate_html" == true ]]; then
        generate_dashboard
    fi
    
    # Send alerts if enabled and status is not healthy
    if [[ "$enable_alerts" == true && $health_status -ne 0 && -n "$ALERT_EMAIL" ]]; then
        echo "Server health alert for $server" | mail -s "Health Check Alert" "$ALERT_EMAIL"
        echo -e "${YELLOW}Alert sent to: $ALERT_EMAIL${NC}"
    fi
    
    exit $health_status
}

main "$@"