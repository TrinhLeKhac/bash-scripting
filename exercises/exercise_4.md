# Exercise 4: System Information Display

## Objective
Create a comprehensive system information script that displays hardware, software, and performance details.

## Requirements
1. Display system hardware information (CPU, Memory, Disk)
2. Show operating system details
3. Display network information
4. Show running processes summary
5. Display system uptime and load
6. Show disk usage for all mounted filesystems
7. Format output in a readable way
8. Option to save report to file
9. Option to show only specific categories

## Usage Examples
```bash
bash system_info.sh                    # Show all information
bash system_info.sh --cpu             # Show only CPU info
bash system_info.sh --memory          # Show only memory info
bash system_info.sh --disk            # Show only disk info
bash system_info.sh --network         # Show only network info
bash system_info.sh --save report.txt # Save to file
bash system_info.sh --json            # Output in JSON format
```

## Information Categories

### System Overview
- Hostname
- Operating System
- Kernel version
- Architecture
- Uptime
- Current date/time

### CPU Information
- CPU model and speed
- Number of cores
- CPU usage percentage
- Load average

### Memory Information
- Total RAM
- Used/Available memory
- Memory usage percentage
- Swap usage

### Disk Information
- All mounted filesystems
- Disk usage per filesystem
- Total disk space
- Available space

### Network Information
- Network interfaces
- IP addresses
- Network statistics
- Active connections

### Process Information
- Total number of processes
- Top CPU consuming processes
- Top memory consuming processes

## Output Format
```
=== SYSTEM INFORMATION REPORT ===
Generated: 2024-01-15 14:30:25

--- System Overview ---
Hostname: myserver
OS: Ubuntu 20.04.3 LTS
Kernel: 5.4.0-91-generic
Architecture: x86_64
Uptime: 5 days, 3 hours, 22 minutes

--- CPU Information ---
Model: Intel(R) Core(TM) i7-8700K CPU @ 3.70GHz
Cores: 8
Current Usage: 15.2%
Load Average: 0.85, 0.92, 1.05

[... continue for other categories ...]
```

## Test Cases
1. Run with no arguments (show all info)
2. Test individual category options
3. Test file output functionality
4. Test JSON output format
5. Verify cross-platform compatibility