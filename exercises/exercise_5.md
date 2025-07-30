# Exercise 5: Text File Analyzer

## Objective
Create a comprehensive text file analyzer that provides detailed statistics and analysis of text files.

## Requirements
1. Count lines, words, and characters
2. Find most/least frequent words
3. Analyze sentence and paragraph structure
4. Generate reading time estimate
5. Find longest/shortest lines
6. Character frequency analysis
7. Export results in multiple formats (text, CSV, JSON)
8. Handle multiple files
9. Generate summary report

## Usage Examples
```bash
bash text_analyzer.sh document.txt
bash text_analyzer.sh *.txt --summary
bash text_analyzer.sh file.txt --words --export csv
bash text_analyzer.sh file.txt --chars --top 10
bash text_analyzer.sh file.txt --reading-time
```

## Analysis Features

### Basic Statistics
- Total lines, words, characters
- Average words per line
- Average characters per word
- Blank lines count

### Word Analysis
- Most frequent words (top N)
- Least frequent words
- Unique word count
- Word length distribution

### Character Analysis
- Character frequency
- Most/least common characters
- Special character count
- Whitespace analysis

### Structure Analysis
- Sentence count (approximate)
- Paragraph count
- Longest/shortest lines
- Line length distribution

### Reading Analysis
- Estimated reading time
- Reading level assessment
- Complexity score

## Output Formats
- **Text**: Human-readable report
- **CSV**: Comma-separated values for spreadsheet
- **JSON**: Machine-readable format

## Test Cases
1. Analyze single text file
2. Analyze multiple files
3. Test different export formats
4. Test with empty file
5. Test with binary file (should handle gracefully)