# Bash Scripting Guide

## Basic Scripts

### 1. Basic Script
Learn all the basics of bash scripting:
```bash
cd scripts && bash basic_script.sh 5
```
OR
```bash
cd scripts && chmod +x basic_script.sh && ./basic_script.sh 5
```

### 2. Install Me
Simulate the installation of a program with user confirmation:
```bash
cd scripts && bash install_me.sh
```

### 3. Calculate Frequencies
Calculate the frequencies of flower species in CSV files:
```bash
cd scripts && bash calculate_frequency.sh ../data
```

## Advanced Scripts

### 4. File Monitor
Monitor file changes with advanced features:
```bash
cd scripts && bash file_monitor.sh ../data/data1.csv 2
```

### 5. CSV Processor
Process and analyze CSV data:
```bash
cd scripts && bash csv_processor.sh ../data/data1.csv interactive
```

### 6. System Monitor
Monitor system resources:
```bash
cd scripts && bash system_monitor.sh 3
```

### 7. Backup Manager
Manage data backups:
```bash
cd scripts && bash backup_manager.sh ../data ./backups
```

### 8. Log Analyzer
Analyze log files:
```bash
cd scripts && bash log_analyzer.sh sample.log
```

## Makefile
```bash
make build
make deploy
make ci
```