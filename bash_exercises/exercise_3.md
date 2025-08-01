# Exercise 3: Password Generator

## Objective
Create a secure password generator with customizable options for length, character sets, and complexity requirements.

## Requirements
1. Generate passwords with specified length (default: 12)
2. Include/exclude character sets: uppercase, lowercase, numbers, symbols
3. Ensure at least one character from each selected set
4. Generate multiple passwords at once
5. Save passwords to file (optional)
6. Check password strength
7. Avoid ambiguous characters (0, O, l, 1, etc.) option

## Usage Examples
```bash
bash password_generator.sh                           # Default 12-char password
bash password_generator.sh --length 16              # 16-character password
bash password_generator.sh --count 5                # Generate 5 passwords
bash password_generator.sh --no-symbols             # Exclude symbols
bash password_generator.sh --only-alnum             # Only letters and numbers
bash password_generator.sh --save passwords.txt     # Save to file
bash password_generator.sh --no-ambiguous           # Exclude ambiguous chars
```

## Character Sets
- **Lowercase**: a-z
- **Uppercase**: A-Z  
- **Numbers**: 0-9
- **Symbols**: !@#$%^&*()_+-=[]{}|;:,.<>?
- **Ambiguous**: 0, O, l, 1, I (excluded with --no-ambiguous)

## Features to Implement
- Customizable password length
- Multiple character set options
- Batch password generation
- Password strength assessment
- File output option
- Ambiguous character filtering
- Interactive mode

## Password Strength Criteria
- **Weak**: < 8 characters or single character type
- **Medium**: 8-11 characters with 2+ character types
- **Strong**: 12+ characters with 3+ character types
- **Very Strong**: 16+ characters with all character types

## Test Cases
1. Generate default password (12 chars, all sets)
2. Generate 16-character password with only letters/numbers
3. Generate 5 passwords and save to file
4. Generate password without ambiguous characters
5. Test password strength assessment