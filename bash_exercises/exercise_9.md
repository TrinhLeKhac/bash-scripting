# Exercise 9: Log Rotator

## Objective
Implement log file rotation with compression and cleanup functionality.

## Requirements
1. Rotate log files based on size or time
2. Compress old log files
3. Keep specified number of rotated logs
4. Support multiple log files
5. Create rotation schedule
6. Generate rotation reports
7. Handle file permissions
8. Support different compression formats

## Usage Examples
```bash
bash log_rotator.sh --file /var/log/app.log --size 100M
bash log_rotator.sh --file /var/log/app.log --daily
bash log_rotator.sh --config rotation.conf
bash log_rotator.sh --file app.log --keep 7 --compress gzip
bash log_rotator.sh --schedule --cron
```

## Features to Implement
- Size-based rotation
- Time-based rotation (daily, weekly, monthly)
- Compression (gzip, bzip2, xz)
- Configurable retention policy
- Multiple file support
- Cron integration
- Rotation logging
- Permission handling

## Test Cases
1. Rotate by file size
2. Rotate by time schedule
3. Test compression options
4. Test retention policy
5. Handle permission issues