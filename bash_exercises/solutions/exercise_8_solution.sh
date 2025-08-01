#!/bin/bash
# Exercise 8 Solution: Network Checker

# STEP 1: Setup colors and variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TIMEOUT=5
REPORT_FILE=""

# STEP 2: Usage function
show_usage() {
    echo "Usage: bash network_checker.sh [options]"
    echo "Options:"
    echo "  --ping HOST         Ping specific host"
    echo "  --port HOST PORT    Check if port is open"
    echo "  --dns HOST          Test DNS resolution"
    echo "  --interfaces        Show network interfaces"
    echo "  --speed-test        Basic speed test"
    echo "  --batch FILE        Test hosts from file"
    echo "  --report FILE       Generate report to file"
    echo "  --timeout SEC       Set timeout (default: 5)"
}

# STEP 3: Ping test function
ping_test() {
    local host=$1
    echo -e "${BLUE}Testing connectivity to $host...${NC}"
    
    if ping -c 3 -W "$TIMEOUT" "$host" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ $host is reachable${NC}"
        return 0
    else
        echo -e "${RED}✗ $host is unreachable${NC}"
        return 1
    fi
}

# STEP 4: Port check function
port_check() {
    local host=$1
    local port=$2
    echo -e "${BLUE}Checking port $port on $host...${NC}"
    
    if timeout "$TIMEOUT" bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
        echo -e "${GREEN}✓ Port $port is open on $host${NC}"
        return 0
    else
        echo -e "${RED}✗ Port $port is closed on $host${NC}"
        return 1
    fi
}

# STEP 5: DNS lookup function
dns_lookup() {
    local host=$1
    echo -e "${BLUE}DNS lookup for $host...${NC}"
    
    local ip=$(nslookup "$host" 2>/dev/null | grep -A1 "Name:" | tail -1 | awk '{print $2}')
    if [[ -n "$ip" ]]; then
        echo -e "${GREEN}✓ $host resolves to $ip${NC}"
        return 0
    else
        echo -e "${RED}✗ DNS lookup failed for $host${NC}"
        return 1
    fi
}

# STEP 6: Show network interfaces
show_interfaces() {
    echo -e "${BLUE}=== Network Interfaces ===${NC}"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        ifconfig | grep -E "^[a-z]|inet " | while read line; do
            if [[ "$line" =~ ^[a-z] ]]; then
                echo -e "${GREEN}Interface: $(echo $line | cut -d: -f1)${NC}"
            elif [[ "$line" =~ inet ]]; then
                echo -e "  IP: $(echo $line | awk '{print $2}')"
            fi
        done
    else
        ip addr show | grep -E "^[0-9]|inet " | while read line; do
            if [[ "$line" =~ ^[0-9] ]]; then
                echo -e "${GREEN}Interface: $(echo $line | cut -d: -f2 | sed 's/^ *//')${NC}"
            elif [[ "$line" =~ inet ]]; then
                echo -e "  IP: $(echo $line | awk '{print $2}' | cut -d/ -f1)"
            fi
        done
    fi
}

# STEP 7: Basic speed test
speed_test() {
    echo -e "${BLUE}Running basic speed test...${NC}"
    
    local test_url="http://speedtest.wdc01.softlayer.com/downloads/test10.zip"
    local start_time=$(date +%s)
    
    if curl -o /dev/null -s -w "%{speed_download}" --max-time 10 "$test_url" >/tmp/speed_result 2>/dev/null; then
        local speed=$(cat /tmp/speed_result)
        local speed_mbps=$(echo "scale=2; $speed / 1024 / 1024 * 8" | bc -l)
        echo -e "${GREEN}Download speed: ${speed_mbps} Mbps${NC}"
        rm -f /tmp/speed_result
    else
        echo -e "${RED}Speed test failed${NC}"
    fi
}

# STEP 8: Batch test from file
batch_test() {
    local file=$1
    
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}File not found: $file${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Running batch tests from $file...${NC}"
    
    while read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        
        # Parse line (format: host:port or just host)
        if [[ "$line" =~ : ]]; then
            local host=$(echo "$line" | cut -d: -f1)
            local port=$(echo "$line" | cut -d: -f2)
            port_check "$host" "$port"
        else
            ping_test "$line"
        fi
        echo ""
    done < "$file"
}

# STEP 9: Generate report
generate_report() {
    local output=""
    
    output+="=== Network Status Report ===\n"
    output+="Generated: $(date)\n\n"
    
    # Test common services
    local services=("google.com:80" "dns.google:53" "github.com:443")
    
    for service in "${services[@]}"; do
        local host=$(echo "$service" | cut -d: -f1)
        local port=$(echo "$service" | cut -d: -f2)
        
        if port_check "$host" "$port" >/dev/null 2>&1; then
            output+="✓ $service - OK\n"
        else
            output+="✗ $service - FAILED\n"
        fi
    done
    
    if [[ -n "$REPORT_FILE" ]]; then
        echo -e "$output" > "$REPORT_FILE"
        echo -e "${GREEN}Report saved to: $REPORT_FILE${NC}"
    else
        echo -e "$output"
    fi
}

# STEP 10: Main function
main() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --ping)
                ping_test "$2"
                shift 2
                ;;
            --port)
                port_check "$2" "$3"
                shift 3
                ;;
            --dns)
                dns_lookup "$2"
                shift 2
                ;;
            --interfaces)
                show_interfaces
                shift
                ;;
            --speed-test)
                speed_test
                shift
                ;;
            --batch)
                batch_test "$2"
                shift 2
                ;;
            --report)
                REPORT_FILE=$2
                generate_report
                shift 2
                ;;
            --timeout)
                TIMEOUT=$2
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
        echo -e "${BLUE}Running basic connectivity tests...${NC}"
        ping_test "google.com"
        echo ""
        port_check "google.com" "80"
    fi
}

main "$@"