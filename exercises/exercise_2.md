# Exercise 2: File Organizer

## Objective
Create a script that organizes files in a directory by sorting them into subdirectories based on their file extensions.

## Requirements
1. Accept a directory path as command-line argument
2. Create subdirectories for each file extension found
3. Move files to appropriate subdirectories
4. Handle files without extensions (put in "no_extension" folder)
5. Provide summary of organized files
6. Create backup before organizing (optional)
7. Skip hidden files and directories

## Usage Examples
```bash
bash file_organizer.sh /path/to/messy/directory
bash file_organizer.sh .                    # Current directory
bash file_organizer.sh ~/Downloads --backup # With backup option
```

## Expected Directory Structure (Before)
```
messy_folder/
├── document.pdf
├── image.jpg
├── script.sh
├── data.csv
├── photo.png
├── readme
└── archive.zip
```

## Expected Directory Structure (After)
```
messy_folder/
├── pdf/
│   └── document.pdf
├── jpg/
│   └── image.jpg
├── sh/
│   └── script.sh
├── csv/
│   └── data.csv
├── png/
│   └── photo.png
├── zip/
│   └── archive.zip
└── no_extension/
    └── readme
```

## Features to Implement
- Directory validation
- Extension detection
- Safe file moving
- Progress reporting
- Undo functionality (advanced)
- Dry-run mode

## Test Cases
1. Organize directory with mixed file types
2. Handle directory with no files
3. Handle files without extensions
4. Handle duplicate filenames
5. Test with backup option