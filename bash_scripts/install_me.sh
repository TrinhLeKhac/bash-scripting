#!/bin/bash
# Shebang: Specify script uses bash interpreter

# STEP 1: Display prompt and read user input
echo -n "Do you want to install me? [y/n]: "  # -n to not add newline
read -r answer  # -r to read raw input (no escape character processing)

# STEP 2: Check answer and process
if [[ "${answer,,}" == "y" ]]; then  # ${answer,,} converts to lowercase
    echo "${answer,,}"  # Print answer in lowercase
    echo "Installed the package successfully!"  # Success message
else
    echo "Cancelled installing the package!"  # Cancel message
fi  # End if statement