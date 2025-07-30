# Exercise 8: Network Checker

## Objective
Create a network connectivity and port status checker tool.

## Requirements
1. Check internet connectivity
2. Test specific host reachability
3. Check port status (open/closed)
4. Perform DNS lookups
5. Test network speed
6. Monitor network interfaces
7. Generate connectivity reports
8. Support batch testing

## Usage Examples
```bash
bash network_checker.sh --ping google.com
bash network_checker.sh --port google.com 80
bash network_checker.sh --dns example.com
bash network_checker.sh --interfaces
bash network_checker.sh --speed-test
bash network_checker.sh --batch hosts.txt
bash network_checker.sh --report network_status.txt
```

## Features to Implement
- Ping connectivity tests
- Port scanning capabilities
- DNS resolution testing
- Network interface monitoring
- Basic speed testing
- Batch host testing
- Report generation
- Timeout handling

## Test Cases
1. Test basic connectivity
2. Check specific ports
3. Test DNS resolution
4. Monitor network interfaces
5. Generate comprehensive report