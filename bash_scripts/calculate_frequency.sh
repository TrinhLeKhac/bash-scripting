#!/bin/bash
# Shebang: Specify script uses bash interpreter

# STEP 1: Get first parameter (folder name containing CSV files)
FOLDERNAME=$1  # $1 is first parameter from command line

# STEP 2: Initialize array to store file list
filesArr=()  # Create empty array

# STEP 3: Iterate through all CSV files in folder
for filename in $(ls ${FOLDERNAME}/*.csv); do  # Get list of .csv files
    echo "Viewing ${filename}"  # Display filename being processed
    
    # STEP 4: Exclude files containing "copy" in name
    if [[ $filename != *"copy"* ]]; then  # Check filename doesn't contain "copy"
        # STEP 5: Display file content (skip header)
        tail -n +2 $filename  # tail -n +2: start from line 2
        echo -e "\n"  # Print empty line (-e to interpret \n as newline)
        
        # STEP 6: Add file to array
        filesArr+=($filename)  # += to append to array
    fi
done

# STEP 7: Initialize array to store flower species names
flowerSpecies=()  # Create empty array for species

# STEP 8: Iterate through each file in filesArr
for filename in ${filesArr[@]}; do  # ${filesArr[@]} to get all elements
    # STEP 9: Extract last column (species) from each file
    # awk -F, '{print $5}': split by comma and get column 5
    # tail -n +2: skip header
    flowerSpecies+=($(awk -F, '{print $5}' $filename | tail -n +2))
done

# STEP 10: Count frequency of each species
# IFS=$'\n': set delimiter as newline
# sort: sort the species
# uniq -c: count occurrences of each species
# sort -nr: sort by count in descending order
(IFS=$'\n'; sort <<< "${flowerSpecies[*]}") | uniq -c | sort -nr