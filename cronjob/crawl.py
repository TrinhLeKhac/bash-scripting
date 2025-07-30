#!/usr/bin/env python3
"""
Iris Dataset Crawler Script
This script downloads the iris dataset from a remote URL, processes it with pandas,
and then cleans up the downloaded file while logging all activities.
"""

# STEP 1: Import required libraries
import os          # For file system operations (remove files, get basename)
import pandas as pd    # For data manipulation and CSV reading
import logging     # For logging activities and errors
import subprocess  # For executing shell commands (wget)

# STEP 2: Configure logging system
# Create a logger instance with the current module name
logger = logging.getLogger(__name__)
# Set logging level to DEBUG to capture all log messages
logger.setLevel(logging.DEBUG)

# STEP 3: Create file handler for logging
# Create a file handler to write logs to 'logs/crawler.log'
fh = logging.FileHandler('logs/crawler.log')

# STEP 4: Add handler to logger
# Attach the file handler to the logger so logs are written to file
logger.addHandler(fh)

# STEP 5: Define the data source URL
# URL pointing to the iris dataset CSV file on GitHub Gist
IRIS_URL = 'https://gist.githubusercontent.com/netj/8836201/raw/6f9306ad21398ea43cba4f7d537619d0e07d5ae3/iris.csv'

# STEP 6: Main execution block
if __name__ == '__main__':
    # STEP 7: Download file using wget command
    # Construct wget command to download the iris dataset
    cmd = f"wget {IRIS_URL}"
    
    # STEP 8: Execute the download command
    # Use subprocess.Popen to run the wget command
    process = subprocess.Popen(
        cmd,                    # Command to execute
        stdout=subprocess.PIPE, # Capture standard output
        stderr=subprocess.PIPE, # Capture standard error
        text=True,             # Return output as text (not bytes)
        shell=True             # Execute command through shell
    )
    
    # STEP 9: Get command output and errors
    # Wait for command to complete and get output/error streams
    std_out, std_err = process.communicate()
    print(std_out.strip(), std_err)  # Print download results
    
    # STEP 10: Extract filename from URL
    # Get just the filename part from the full URL path
    filename = os.path.basename(IRIS_URL)
    
    # STEP 11: Read CSV file with pandas
    try:
        # Attempt to read the downloaded CSV file into a pandas DataFrame
        df = pd.read_csv(os.path.basename(IRIS_URL))
        # Log successful file reading
        logger.info('Successfully read the iris file')
    except Exception as e:
        # Log any errors that occur during file reading
        logger.error(f'Error while reading iris file with error {e}')
    
    # STEP 12: Clean up downloaded file
    # Remove the downloaded file to keep directory clean
    os.remove(filename)
    # Log the file removal action
    logger.info('The file has been removed immediately!')