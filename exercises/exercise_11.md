# Exercise 11: Server Health Check

## Objective
Create a comprehensive server monitoring script that checks system health and generates alerts.

## Requirements
1. Monitor CPU, memory, disk usage
2. Check running services
3. Monitor network connectivity
4. Check log files for errors
5. Generate health reports
6. Send alerts when thresholds exceeded
7. Support multiple servers
8. Create dashboard output

## Usage Examples
```bash
bash health_check.sh --local
bash health_check.sh --server server1.com
bash health_check.sh --config servers.conf
bash health_check.sh --alert --email admin@company.com
bash health_check.sh --dashboard --output health.html
```

## Features to Implement
- System resource monitoring
- Service status checking
- Network connectivity tests
- Log error detection
- Alert system
- HTML dashboard generation
- Multi-server support
- Configuration management

## Test Cases
1. Check local server health
2. Monitor remote servers
3. Test alert thresholds
4. Generate HTML dashboard
5. Test service monitoring