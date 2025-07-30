# Exercise 7: Process Monitor

## Objective
Create a comprehensive process monitoring and management tool for system processes.

## Requirements
1. List running processes with detailed information
2. Monitor specific processes by name or PID
3. Kill processes safely with confirmation
4. Show process tree hierarchy
5. Monitor resource usage (CPU, memory)
6. Set alerts for high resource usage
7. Log process activities
8. Search and filter processes

## Usage Examples
```bash
bash process_monitor.sh --list
bash process_monitor.sh --monitor firefox
bash process_monitor.sh --kill 1234
bash process_monitor.sh --tree
bash process_monitor.sh --top-cpu 5
bash process_monitor.sh --search chrome
bash process_monitor.sh --alert-cpu 80
```

## Features to Implement
- Process listing with sorting options
- Real-time process monitoring
- Safe process termination
- Resource usage tracking
- Alert system for thresholds
- Process search and filtering
- Activity logging
- Interactive mode

## Test Cases
1. List all processes
2. Monitor specific process
3. Kill process with confirmation
4. Show process tree
5. Test CPU/memory alerts