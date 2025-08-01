#!/bin/bash
# Exercise 3 Solution: Password Generator
# Author: Practice Exercise
# Description: Generate secure passwords with customizable options

# STEP 1: Define colors and default settings
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default settings
DEFAULT_LENGTH=12
DEFAULT_COUNT=1
USE_LOWERCASE=true
USE_UPPERCASE=true
USE_NUMBERS=true
USE_SYMBOLS=true
NO_AMBIGUOUS=false
SAVE_FILE=""

# STEP 2: Define character sets
LOWERCASE="abcdefghijklmnopqrstuvwxyz"
UPPERCASE="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
NUMBERS="0123456789"
SYMBOLS="!@#\$%^&*()_+-=[]{}|;:,.<>?"
AMBIGUOUS="0Ol1I"

# STEP 3: Function to display usage help
show_usage() {
    echo -e "${YELLOW}Password Generator Usage:${NC}"
    echo "bash password_generator.sh [options]"
    echo ""
    echo "Options:"
    echo "  --length N          Password length (default: 12)"
    echo "  --count N           Number of passwords to generate (default: 1)"
    echo "  --no-lowercase      Exclude lowercase letters"
    echo "  --no-uppercase      Exclude uppercase letters"
    echo "  --no-numbers        Exclude numbers"
    echo "  --no-symbols        Exclude symbols"
    echo "  --only-alnum        Only letters and numbers"
    echo "  --no-ambiguous      Exclude ambiguous characters (0,O,l,1,I)"
    echo "  --save FILE         Save passwords to file"
    echo "  --interactive       Interactive mode"
    echo "  --help              Show this help"
    echo ""
    echo "Examples:"
    echo "  bash password_generator.sh --length 16 --count 3"
    echo "  bash password_generator.sh --no-symbols --save passwords.txt"
}

# STEP 4: Function to remove ambiguous characters
remove_ambiguous() {
    local charset=$1
    local result=""
    
    # Remove each ambiguous character from charset
    for (( i=0; i<${#charset}; i++ )); do
        local char="${charset:$i:1}"
        if [[ "$AMBIGUOUS" != *"$char"* ]]; then
            result+="$char"
        fi
    done
    
    echo "$result"
}

# STEP 5: Function to build character set based on options
build_charset() {
    local charset=""
    local required_chars=""
    
    # Add character sets based on options
    if [[ "$USE_LOWERCASE" == true ]]; then
        local lower_set="$LOWERCASE"
        if [[ "$NO_AMBIGUOUS" == true ]]; then
            lower_set=$(remove_ambiguous "$lower_set")
        fi
        charset+="$lower_set"
        # Add one required character from this set
        required_chars+="${lower_set:$((RANDOM % ${#lower_set})):1}"
    fi
    
    if [[ "$USE_UPPERCASE" == true ]]; then
        local upper_set="$UPPERCASE"
        if [[ "$NO_AMBIGUOUS" == true ]]; then
            upper_set=$(remove_ambiguous "$upper_set")
        fi
        charset+="$upper_set"
        required_chars+="${upper_set:$((RANDOM % ${#upper_set})):1}"
    fi
    
    if [[ "$USE_NUMBERS" == true ]]; then
        local num_set="$NUMBERS"
        if [[ "$NO_AMBIGUOUS" == true ]]; then
            num_set=$(remove_ambiguous "$num_set")
        fi
        charset+="$num_set"
        required_chars+="${num_set:$((RANDOM % ${#num_set})):1}"
    fi
    
    if [[ "$USE_SYMBOLS" == true ]]; then
        charset+="$SYMBOLS"
        required_chars+="${SYMBOLS:$((RANDOM % ${#SYMBOLS})):1}"
    fi
    
    # Return both charset and required characters
    echo "$charset|$required_chars"
}

# STEP 6: Function to shuffle string
shuffle_string() {
    local input=$1
    local output=""
    local temp="$input"
    
    # Randomly pick characters from temp string
    while [[ ${#temp} -gt 0 ]]; do
        local index=$((RANDOM % ${#temp}))
        output+="${temp:$index:1}"
        temp="${temp:0:$index}${temp:$((index+1))}"
    done
    
    echo "$output"
}

# STEP 7: Function to generate single password
generate_password() {
    local length=$1
    local charset_info=$(build_charset)
    local charset="${charset_info%|*}"
    local required_chars="${charset_info#*|}"
    
    # Check if charset is empty
    if [[ -z "$charset" ]]; then
        echo -e "${RED}Error: No character sets selected${NC}"
        return 1
    fi
    
    # Check if length is sufficient for required characters
    if [[ ${#required_chars} -gt $length ]]; then
        echo -e "${RED}Error: Password length too short for selected character sets${NC}"
        return 1
    fi
    
    local password="$required_chars"
    
    # Fill remaining length with random characters
    local remaining_length=$((length - ${#required_chars}))
    for (( i=0; i<remaining_length; i++ )); do
        local random_index=$((RANDOM % ${#charset}))
        password+="${charset:$random_index:1}"
    done
    
    # Shuffle the password to avoid predictable patterns
    password=$(shuffle_string "$password")
    
    echo "$password"
}

# STEP 8: Function to assess password strength
assess_strength() {
    local password=$1
    local length=${#password}
    local char_types=0
    
    # Count character types
    if [[ "$password" =~ [a-z] ]]; then char_types=$((char_types + 1)); fi
    if [[ "$password" =~ [A-Z] ]]; then char_types=$((char_types + 1)); fi
    if [[ "$password" =~ [0-9] ]]; then char_types=$((char_types + 1)); fi
    if [[ "$password" =~ [^a-zA-Z0-9] ]]; then char_types=$((char_types + 1)); fi
    
    # Determine strength
    if [[ $length -lt 8 ]] || [[ $char_types -lt 2 ]]; then
        echo -e "${RED}Weak${NC}"
    elif [[ $length -lt 12 ]] || [[ $char_types -lt 3 ]]; then
        echo -e "${YELLOW}Medium${NC}"
    elif [[ $length -lt 16 ]] || [[ $char_types -lt 4 ]]; then
        echo -e "${GREEN}Strong${NC}"
    else
        echo -e "${GREEN}Very Strong${NC}"
    fi
}

# STEP 9: Function for interactive mode
interactive_mode() {
    echo -e "${BLUE}=== Interactive Password Generator ===${NC}"
    echo ""
    
    # Get password length
    echo -n "Password length (default: $DEFAULT_LENGTH): "
    read -r length
    length=${length:-$DEFAULT_LENGTH}
    
    # Get number of passwords
    echo -n "Number of passwords (default: $DEFAULT_COUNT): "
    read -r count
    count=${count:-$DEFAULT_COUNT}
    
    # Character set options
    echo ""
    echo "Character set options (y/n):"
    
    echo -n "Include lowercase letters? (Y/n): "
    read -r response
    [[ "$response" =~ ^[Nn]$ ]] && USE_LOWERCASE=false
    
    echo -n "Include uppercase letters? (Y/n): "
    read -r response
    [[ "$response" =~ ^[Nn]$ ]] && USE_UPPERCASE=false
    
    echo -n "Include numbers? (Y/n): "
    read -r response
    [[ "$response" =~ ^[Nn]$ ]] && USE_NUMBERS=false
    
    echo -n "Include symbols? (Y/n): "
    read -r response
    [[ "$response" =~ ^[Nn]$ ]] && USE_SYMBOLS=false
    
    echo -n "Exclude ambiguous characters? (y/N): "
    read -r response
    [[ "$response" =~ ^[Yy]$ ]] && NO_AMBIGUOUS=true
    
    echo -n "Save to file? (filename or press Enter to skip): "
    read -r save_file
    [[ -n "$save_file" ]] && SAVE_FILE="$save_file"
    
    # Generate passwords with collected settings
    generate_passwords "$length" "$count"
}

# STEP 10: Function to generate multiple passwords
generate_passwords() {
    local length=$1
    local count=$2
    local passwords=()
    
    echo -e "${BLUE}Generating $count password(s) of length $length...${NC}"
    echo ""
    
    # Generate passwords
    for (( i=1; i<=count; i++ )); do
        local password=$(generate_password "$length")
        if [[ $? -eq 0 ]]; then
            passwords+=("$password")
            local strength=$(assess_strength "$password")
            echo -e "${GREEN}Password $i:${NC} $password ${BLUE}(Strength: $strength)${NC}"
        else
            return 1
        fi
    done
    
    # Save to file if requested
    if [[ -n "$SAVE_FILE" ]]; then
        printf '%s\n' "${passwords[@]}" > "$SAVE_FILE"
        echo ""
        echo -e "${GREEN}Passwords saved to: $SAVE_FILE${NC}"
    fi
}

# STEP 11: Main function
main() {
    local length=$DEFAULT_LENGTH
    local count=$DEFAULT_COUNT
    local interactive=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --length)
                length=$2
                shift 2
                ;;
            --count)
                count=$2
                shift 2
                ;;
            --no-lowercase)
                USE_LOWERCASE=false
                shift
                ;;
            --no-uppercase)
                USE_UPPERCASE=false
                shift
                ;;
            --no-numbers)
                USE_NUMBERS=false
                shift
                ;;
            --no-symbols)
                USE_SYMBOLS=false
                shift
                ;;
            --only-alnum)
                USE_SYMBOLS=false
                shift
                ;;
            --no-ambiguous)
                NO_AMBIGUOUS=true
                shift
                ;;
            --save)
                SAVE_FILE=$2
                shift 2
                ;;
            --interactive)
                interactive=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Validate inputs
    if ! [[ "$length" =~ ^[0-9]+$ ]] || [[ $length -lt 1 ]]; then
        echo -e "${RED}Error: Invalid length '$length'${NC}"
        exit 1
    fi
    
    if ! [[ "$count" =~ ^[0-9]+$ ]] || [[ $count -lt 1 ]]; then
        echo -e "${RED}Error: Invalid count '$count'${NC}"
        exit 1
    fi
    
    # Run interactive mode or generate passwords
    if [[ "$interactive" == true ]]; then
        interactive_mode
    else
        generate_passwords "$length" "$count"
    fi
}

# STEP 12: Execute main function with all arguments
main "$@"