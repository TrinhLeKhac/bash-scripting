#!/bin/bash
# Exercise 14 Solution: Performance Analyzer

# STEP 1: Setup colors and variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

MONITOR_DURATION=60
OUTPUT_FILE=""
LOG_DIR="./perf_logs"

# STEP 2: Usage function
show_usage() {
    echo "Usage: bash perf_analyzer.sh [options]"
    echo "Options:"
    echo "  --monitor           Start performance monitoring"
    echo "  --duration SEC      Monitor duration in seconds (default: 60)"
    echo "  --profile PID       Profile specific process"
    echo "  --report            Generate performance report"
    echo "  --output FILE       Output file for report"
    echo "  --benchmark TEST    Run benchmark (cpu, memory, disk, network)"
    echo "  --analyze FILE      Analyze log file"
}

# STEP 3: Monitor CPU performance
monitor_cpu() {
    local duration=$1
    local samples=$((duration / 5))
    local cpu_data=()
    
    echo -e "${BLUE}Monitoring CPU for ${duration}s...${NC}"
    
    for (( i=0; i<samples; i++ )); do
        local cpu_usage
        if [[ "$OSTYPE" == "darwin"* ]]; then
            cpu_usage=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
        else
            cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
        fi
        cpu_data+=("$cpu_usage")
        sleep 5
    done
    
    # Calculate statistics
    local total=0
    local max=0
    local min=100
    
    for usage in "${cpu_data[@]}"; do
        total=$(echo "$total + $usage" | bc -l)
        if (( $(echo "$usage > $max" | bc -l) )); then max=$usage; fi
        if (( $(echo "$usage < $min" | bc -l) )); then min=$usage; fi
    done
    
    local avg=$(echo "scale=2; $total / ${#cpu_data[@]}" | bc -l)
    
    echo "CPU_AVG:$avg,CPU_MAX:$max,CPU_MIN:$min"
}

# STEP 4: Monitor memory performance
monitor_memory() {
    local duration=$1
    local samples=$((duration / 5))
    local mem_data=()
    
    echo -e "${BLUE}Monitoring Memory for ${duration}s...${NC}"
    
    for (( i=0; i<samples; i++ )); do
        local mem_usage
        if [[ "$OSTYPE" == "darwin"* ]]; then
            mem_usage=$(vm_stat | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
        else
            mem_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
        fi
        mem_data+=("$mem_usage")
        sleep 5
    done
    
    # Calculate statistics
    local total=0
    local max=0
    local min=100
    
    for usage in "${mem_data[@]}"; do
        total=$(echo "$total + $usage" | bc -l)
        if (( $(echo "$usage > $max" | bc -l) )); then max=$usage; fi
        if (( $(echo "$usage < $min" | bc -l) )); then min=$usage; fi
    done
    
    local avg=$(echo "scale=2; $total / ${#mem_data[@]}" | bc -l)
    
    echo "MEM_AVG:$avg,MEM_MAX:$max,MEM_MIN:$min"
}

# STEP 5: Monitor disk I/O
monitor_disk() {
    echo -e "${BLUE}Monitoring Disk I/O...${NC}"
    
    if command -v iostat >/dev/null; then
        local disk_stats=$(iostat -d 1 2 | tail -1)
        echo "DISK_STATS:$disk_stats"
    else
        # Fallback: check disk usage
        local disk_usage=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
        echo "DISK_USAGE:$disk_usage"
    fi
}

# STEP 6: Profile specific process
profile_process() {
    local pid=$1
    
    if ! kill -0 "$pid" 2>/dev/null; then
        echo -e "${RED}Process $pid not found${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Profiling process $pid...${NC}"
    
    # Get process info
    local process_info=$(ps -p "$pid" -o pid,ppid,user,cpu,mem,command --no-headers)
    echo "PROCESS_INFO:$process_info"
    
    # Monitor for 30 seconds
    for (( i=0; i<6; i++ )); do
        local cpu_mem=$(ps -p "$pid" -o cpu,mem --no-headers)
        echo "SAMPLE_$i:$cpu_mem"
        sleep 5
    done
}

# STEP 7: Run CPU benchmark
benchmark_cpu() {
    echo -e "${BLUE}Running CPU benchmark...${NC}"
    
    local start_time=$(date +%s.%N)
    
    # CPU intensive task
    for (( i=0; i<1000000; i++ )); do
        echo "scale=10; sqrt($i)" | bc -l >/dev/null
    done
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc -l)
    
    echo "CPU_BENCHMARK:${duration}s"
}

# STEP 8: Run memory benchmark
benchmark_memory() {
    echo -e "${BLUE}Running Memory benchmark...${NC}"
    
    local start_time=$(date +%s.%N)
    
    # Memory allocation test
    local large_array=()
    for (( i=0; i<100000; i++ )); do
        large_array+=("data_$i")
    done
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc -l)
    
    echo "MEMORY_BENCHMARK:${duration}s"
    
    # Clean up
    unset large_array
}

# STEP 9: Generate performance report
generate_report() {
    local output_file=${OUTPUT_FILE:-"performance_report.html"}
    
    mkdir -p "$LOG_DIR"
    
    # Run monitoring
    local cpu_stats=$(monitor_cpu 30)
    local mem_stats=$(monitor_memory 30)
    local disk_stats=$(monitor_disk)
    
    # Generate HTML report
    cat > "$output_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Performance Analysis Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .metric { margin: 15px 0; padding: 10px; border: 1px solid #ccc; }
        .good { color: green; }
        .warning { color: orange; }
        .critical { color: red; }
    </style>
</head>
<body>
    <h1>Performance Analysis Report</h1>
    <p>Generated: $(date)</p>
    
    <div class="metric">
        <h3>CPU Performance</h3>
        <p>$cpu_stats</p>
    </div>
    
    <div class="metric">
        <h3>Memory Performance</h3>
        <p>$mem_stats</p>
    </div>
    
    <div class="metric">
        <h3>Disk Performance</h3>
        <p>$disk_stats</p>
    </div>
    
    <div class="metric">
        <h3>Recommendations</h3>
        <ul>
            <li>Monitor CPU usage during peak hours</li>
            <li>Consider memory optimization if usage > 80%</li>
            <li>Check disk I/O patterns for bottlenecks</li>
        </ul>
    </div>
</body>
</html>
EOF
    
    echo -e "${GREEN}Performance report generated: $output_file${NC}"
}

# STEP 10: Main function
main() {
    local action=""
    local pid=""
    local benchmark_type=""
    local log_file=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --monitor) action="monitor"; shift ;;
            --duration) MONITOR_DURATION=$2; shift 2 ;;
            --profile) action="profile"; pid=$2; shift 2 ;;
            --report) action="report"; shift ;;
            --output) OUTPUT_FILE=$2; shift 2 ;;
            --benchmark) action="benchmark"; benchmark_type=$2; shift 2 ;;
            --analyze) action="analyze"; log_file=$2; shift 2 ;;
            --help) show_usage; exit 0 ;;
            *) echo -e "${RED}Unknown option: $1${NC}"; show_usage; exit 1 ;;
        esac
    done
    
    # Execute action
    case $action in
        monitor)
            echo -e "${BLUE}=== Performance Monitoring ===${NC}"
            monitor_cpu "$MONITOR_DURATION"
            monitor_memory "$MONITOR_DURATION"
            monitor_disk
            ;;
        profile)
            profile_process "$pid"
            ;;
        report)
            generate_report
            ;;
        benchmark)
            case $benchmark_type in
                cpu) benchmark_cpu ;;
                memory) benchmark_memory ;;
                *) echo -e "${RED}Unknown benchmark type: $benchmark_type${NC}" ;;
            esac
            ;;
        analyze)
            echo -e "${BLUE}Analyzing log file: $log_file${NC}"
            if [[ -f "$log_file" ]]; then
                grep -E "(ERROR|WARN|SLOW)" "$log_file" | head -10
            else
                echo -e "${RED}Log file not found${NC}"
            fi
            ;;
        *)
            echo -e "${RED}No action specified${NC}"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"