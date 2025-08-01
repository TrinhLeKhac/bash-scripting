#!/bin/bash
# Shebang: Specify script uses bash interpreter

# STEP 1: Get first parameter from command line
first_arg=$1  # $1 is the first parameter passed to script

# STEP 2: Print variable value
echo "Your first variable is $first_arg"

# STEP 3: Demo if-else structure with string comparison
if [[ $first_arg > 0 ]]; then  # [[ ]] used for string comparison
  echo "First argument is positive"
elif [[ $first_arg == 0 ]]; then  # == for equality comparison
  echo "First argument is zero"
else
  echo "First argument is negative"
fi  # End if statement

# STEP 4: For loop with C-style syntax
echo "All numbers from 0 to first_arg-1:"
for ((i=0;i<$first_arg;i++)); do  # Loop from 0 to first_arg-1
    echo $i  # Print value of i
done  # End loop

# STEP 5: Define and use function
filepath="../data/data1.csv"  # Path to CSV file
my_readfile_func() {  # Function definition
    while read -r line; do  # Read each line from file
        # Use IFS (Internal Field Separator) to split string by comma
        IFS=',' read -ra my_record <<< "$line"  # Create array from CSV line
        echo ${my_record[-1]}  # Print last element (index -1)
    done < $1  # Input from file passed to function
}
my_readfile_func $filepath  # Call function with filepath parameter

# STEP 6: For loop to iterate through .sh files
echo "All the .sh files in the current directory:"
for i in ./*.sh; do  # Iterate all .sh files in current directory
    echo $i  # Print filename
done

# STEP 7: Numeric comparison with (( ))
if (( first_arg > 0 )); then  # (( )) used for arithmetic operations
    echo "Positive number"
else
    echo "Non-positive number"
fi

# STEP 8: Demo difference between [[ ]] and (( ))
# [[ ]] compares by alphabetical order, not numeric
if [[ 10 > 9 ]]; then  # String comparison: "10" < "9" alphabetically
  echo "10 > 9 is true"
else
  echo "10 > 9 is false"  # This result will be printed
fi

# STEP 9: String manipulation operations
my_path="/home/quandv/Documents/home/m1/linux/scripts"
echo "Replaced the first 'home': ${my_path/home/house}"  # Replace first occurrence
echo "Split my_path by / into an array:"
IFS="/" read -ra my_array <<< "$my_path" && echo ${my_array[-1]}  # Split string into array
echo "Delete everything up to the last slash: ${my_path##*/}"  # Get filename
echo "Lower case: ${my_path,,}; Upper case: ${my_path^^}"  # Case conversion

# STEP 10: Array operations
my_array=(10 2 300)  # Create array with 3 elements
echo "First element: ${my_array[0]}"  # First element (index 0)
echo "Last element: ${my_array[-1]}"  # Last element (index -1)
echo "Number of elements: ${#my_array[@]}"  # Number of elements

# STEP 11: Here document - write multiple lines to file
cat << EOF >> test.txt  # << EOF starts here document
machine learning engineering
data engineering
EOF  # End here document