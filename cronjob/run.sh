#!/bin/bash
# Shebang: Specify script uses bash interpreter

# STEP 1: Create Python virtual environment
# This creates an isolated Python environment to avoid conflicts with system packages
python3 -m venv myenv

# STEP 2: Activate the virtual environment
# This switches to the isolated environment where we can install packages safely
source myenv/bin/activate

# STEP 3: Install required Python packages
# Install pandas library for data manipulation and analysis
pip3 install pandas

# STEP 4: Navigate to the cronjob directory
# Change to the specific directory where our Python script is located
cd /Users/trinhlk2/Desktop/Others/fsds/1/Bash/bash_scripting/cronjob

# STEP 5: Execute the Python crawler script
# Run the main Python script that downloads and processes the iris dataset
python3 crawl.py