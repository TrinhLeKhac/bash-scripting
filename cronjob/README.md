# Cronjob Automation Project

## Overview
This project demonstrates automated data crawling using cron jobs, bash scripts, and Python. It downloads the famous Iris dataset every minute, processes it with pandas, and maintains detailed logs of all operations.

## Project Structure
```
cronjob/
├── run.sh              # Main bash script that orchestrates the process
├── crawl.py            # Python script for downloading and processing data
├── requirements.txt    # Python package dependencies
├── craw_cron.txt      # Cron job configuration
├── logs/              # Directory for log files
│   ├── crawler.log    # Python application logs
│   └── iris.log       # Cron job execution logs
└── myenv/             # Python virtual environment (auto-created)
```

## File Descriptions

### 1. run.sh - Main Orchestration Script
**Purpose:** Sets up Python environment and executes the crawler

**Step-by-step process:**
1. **Virtual Environment Creation:** Creates isolated Python environment
2. **Environment Activation:** Switches to the virtual environment
3. **Dependency Installation:** Installs required Python packages
4. **Directory Navigation:** Changes to the correct working directory
5. **Script Execution:** Runs the Python crawler script

**Usage:**
```bash
# Make executable
chmod +x run.sh

# Run manually
./run.sh

# Check execution status
echo $?
```

### 2. crawl.py - Data Crawler Script
**Purpose:** Downloads Iris dataset, processes with pandas, and cleans up

**Step-by-step process:**
1. **Import Libraries:** Loads required Python modules
2. **Configure Logging:** Sets up file-based logging system
3. **Define Data Source:** Specifies the Iris dataset URL
4. **Download Data:** Uses wget to download CSV file
5. **Process Data:** Reads CSV with pandas for validation
6. **Cleanup:** Removes downloaded file to save space
7. **Log Activities:** Records all operations for monitoring

**Key Features:**
- **Error Handling:** Catches and logs exceptions
- **Resource Management:** Automatically cleans up downloaded files
- **Logging:** Comprehensive activity logging
- **Data Validation:** Ensures successful data processing

### 3. requirements.txt - Python Dependencies
**Purpose:** Specifies exact Python package versions needed

**Contents:**
- **pandas==2.1.4:** Data manipulation and analysis library
- **Version Pinning:** Ensures reproducible environments
- **Compatibility:** Maintains stable functionality across deployments

**Usage:**
```bash
# Install dependencies
pip install -r requirements.txt

# Upgrade packages (if needed)
pip install --upgrade -r requirements.txt
```

### 4. craw_cron.txt - Cron Job Configuration
**Purpose:** Defines automated execution schedule

**Cron Format Explanation:**
```
* * * * * command
│ │ │ │ │
│ │ │ │ └─── Day of week (0-7, Sunday = 0 or 7)
│ │ │ └───── Month (1-12)
│ │ └─────── Day of month (1-31)
│ └───────── Hour (0-23)
└─────────── Minute (0-59)
```

**Current Configuration:**
- **Schedule:** Every minute (`* * * * *`)
- **Working Directory:** Changes to project directory
- **Execution:** Runs bash script with full path
- **Logging:** Redirects output to log files

## Setup Instructions

### 1. Prerequisites
```bash
# Ensure Python 3 is installed
python3 --version

# Ensure wget is available
which wget

# Check cron service status
systemctl status cron  # Linux
# or
launchctl list | grep cron  # macOS
```

### 2. Initial Setup
```bash
# Navigate to project directory
cd /path/to/cronjob

# Make run script executable
chmod +x run.sh

# Create logs directory if not exists
mkdir -p logs

# Test manual execution
./run.sh
```

### 3. Install Cron Job
```bash
# Open crontab editor
crontab -e

# Add the cron job (copy from craw_cron.txt)
* * * * * cd /path/to/cronjob && /bin/bash run.sh >> logs/iris.log 2>&1

# Save and exit editor

# Verify cron job installation
crontab -l
```

### 4. Monitoring Setup
```bash
# Check cron job logs
tail -f logs/iris.log

# Check Python application logs
tail -f logs/crawler.log

# Monitor cron service
journalctl -u cron -f  # Linux
```

## Operation Guide

### Manual Execution
```bash
# Run the complete process manually
./run.sh

# Run only the Python script (after setup)
source myenv/bin/activate
python3 crawl.py
```

### Monitoring and Troubleshooting

#### Check Execution Status
```bash
# View recent cron executions
tail -20 logs/iris.log

# Check for errors
grep -i error logs/iris.log logs/crawler.log

# Monitor real-time execution
watch -n 60 'tail -5 logs/iris.log'
```

#### Common Issues and Solutions

**1. Permission Denied**
```bash
# Fix script permissions
chmod +x run.sh

# Check directory permissions
ls -la logs/
```

**2. Python Environment Issues**
```bash
# Recreate virtual environment
rm -rf myenv
python3 -m venv myenv
source myenv/bin/activate
pip install -r requirements.txt
```

**3. Network/Download Issues**
```bash
# Test wget manually
wget https://gist.githubusercontent.com/netj/8836201/raw/6f9306ad21398ea43cba4f7d537619d0e07d5ae3/iris.csv

# Check network connectivity
ping -c 3 gist.githubusercontent.com
```

**4. Cron Job Not Running**
```bash
# Check cron service
systemctl status cron

# Restart cron service
sudo systemctl restart cron

# Check system logs
journalctl -u cron --since "1 hour ago"
```

## Log Analysis

### Understanding Log Files

#### iris.log (Cron Execution Log)
- Contains output from bash script execution
- Shows wget download progress
- Captures any script errors or warnings
- Timestamps each execution

#### crawler.log (Python Application Log)
- Detailed Python application logging
- Success/failure of data processing
- Exception details if errors occur
- File operations tracking

### Log Monitoring Commands
```bash
# Real-time monitoring
tail -f logs/iris.log logs/crawler.log

# Search for errors
grep -i "error\|exception\|fail" logs/*.log

# Count successful executions
grep -c "Successfully read" logs/crawler.log

# View execution timeline
grep "$(date +%Y-%m-%d)" logs/iris.log
```

## Security Considerations

### File Permissions
```bash
# Secure script files
chmod 750 run.sh
chmod 640 crawl.py requirements.txt craw_cron.txt

# Secure log directory
chmod 750 logs/
chmod 640 logs/*.log
```

### Environment Isolation
- Uses Python virtual environment for package isolation
- Prevents conflicts with system Python packages
- Ensures reproducible execution environment

### Resource Management
- Automatically removes downloaded files
- Prevents disk space accumulation
- Logs all file operations for audit trail

## Performance Optimization

### Execution Frequency
```bash
# Current: Every minute
* * * * *

# Alternative schedules:
*/5 * * * *    # Every 5 minutes
0 * * * *      # Every hour
0 0 * * *      # Daily at midnight
0 0 * * 1      # Weekly on Monday
```

### Resource Usage
- Minimal CPU usage (quick download and processing)
- Low memory footprint (pandas processes small dataset)
- Automatic cleanup prevents storage bloat
- Virtual environment isolation

## Extending the Project

### Adding New Data Sources
1. Modify `IRIS_URL` in `crawl.py`
2. Update processing logic for different data formats
3. Adjust logging messages accordingly

### Enhanced Processing
```python
# Add data analysis
df_summary = df.describe()
logger.info(f'Dataset summary: {df_summary}')

# Add data validation
if df.empty:
    logger.warning('Downloaded dataset is empty')
```

### Multiple Schedules
```bash
# Different frequencies for different tasks
*/5 * * * * /path/to/quick_task.sh
0 */6 * * * /path/to/hourly_task.sh
0 2 * * * /path/to/daily_task.sh
```

## Troubleshooting Guide

### Debug Mode
```bash
# Run with debug output
bash -x run.sh

# Python debug mode
python3 -u crawl.py  # Unbuffered output
```

### Environment Testing
```bash
# Test cron environment
* * * * * env > /tmp/cron_env.txt

# Compare with shell environment
env > /tmp/shell_env.txt
diff /tmp/cron_env.txt /tmp/shell_env.txt
```

### Validation Scripts
```bash
# Test all components
./run.sh && echo "SUCCESS" || echo "FAILED"

# Validate Python syntax
python3 -m py_compile crawl.py

# Check requirements
pip check
```

This cronjob project demonstrates practical automation using bash scripting, Python integration, and system scheduling - essential skills for data engineering and system administration tasks.