#!/bin/bash
# Shebang: Specify script uses bash interpreter

# STEP 1: Get parameters from command line
FILENAME=$1  # File name to monitor
INTERVAL=${2:-1}  # Check interval (default 1 second if no parameter)
LOG_FILE="monitor.log"  # Log file name

# STEP 2: Define colors for output
RED='\033[0;31m'     # Red color for errors
GREEN='\033[0;32m'   # Green color for success
YELLOW='\033[1;33m'  # Yellow color for warnings
NC='\033[0m'         # No Color - reset color

# STEP 3: Function to log with timestamp
log_message() {
    # date '+%Y-%m-%d %H:%M:%S': format timestamp
    # tee -a: write to file and display on terminal
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# STEP 4: Check if file exists
if [[ ! -f "$FILENAME" ]]; then  # -f checks if file exists
    echo -e "${RED}Error: File $FILENAME does not exist!${NC}"
    exit 1  # Exit with error code 1
fi

# STEP 5: Display startup information
echo -e "${GREEN}Monitoring file: $FILENAME${NC}"
echo -e "${YELLOW}Check interval: ${INTERVAL}s${NC}"
log_message "Started monitoring $FILENAME"

# STEP 6: Get initial file information
# stat -f%z (macOS) or stat -c%s (Linux): get file size
prevSize=$(stat -f%z "$FILENAME" 2>/dev/null || stat -c%s "$FILENAME")
# stat -f%m (macOS) or stat -c%Y (Linux): get modification time
prevMtime=$(stat -f%m "$FILENAME" 2>/dev/null || stat -c%Y "$FILENAME")

# STEP 7: Main loop to monitor file
while true; do
    # STEP 8: Get current file information
    currentSize=$(stat -f%z "$FILENAME" 2>/dev/null || stat -c%s "$FILENAME")
    currentMtime=$(stat -f%m "$FILENAME" 2>/dev/null || stat -c%Y "$FILENAME")
    
    # STEP 9: Check for file size changes
    if [[ $currentSize -gt $prevSize ]]; then  # File increased in size
        echo -e "${GREEN}[NEW CONTENT]${NC}"
        # Display new line added
        tail -n +$(($(wc -l < "$FILENAME") - $(($currentSize - $prevSize)) / 50 + 1)) "$FILENAME" | tail -1
        log_message "File size increased: $prevSize -> $currentSize bytes"
        prevSize=$currentSize  # Update size
    elif [[ $currentSize -lt $prevSize ]]; then  # File was truncated
        echo -e "${RED}[FILE TRUNCATED]${NC}"
        log_message "File was truncated: $prevSize -> $currentSize bytes"
        prevSize=$currentSize
    fi
    
    # STEP 10: Check for modification time changes
    if [[ $currentMtime -gt $prevMtime ]]; then  # File was modified
        echo -e "${YELLOW}[FILE MODIFIED]${NC}"
        log_message "File was modified"
        prevMtime=$currentMtime  # Update modification time
    fi
    
    # STEP 11: Wait before next check
    sleep "$INTERVAL"  # Sleep for INTERVAL seconds
done