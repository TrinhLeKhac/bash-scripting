# Exercise 6: Directory Tree Generator

## Objective
Create a visual directory tree structure generator that displays filesystem hierarchy in a tree format.

## Requirements
1. Display directory structure in tree format
2. Show files and directories with different symbols
3. Support depth limiting
4. Show file sizes (optional)
5. Filter by file types
6. Export tree to file
7. Handle symbolic links
8. Color coding for different file types

## Usage Examples
```bash
bash tree_generator.sh /path/to/directory
bash tree_generator.sh . --depth 3
bash tree_generator.sh /home --size
bash tree_generator.sh . --filter "*.txt"
bash tree_generator.sh /var --export tree.txt
bash tree_generator.sh . --no-hidden
```

## Expected Output Format
```
/home/user/
├── Documents/
│   ├── file1.txt
│   ├── file2.pdf
│   └── subfolder/
│       └── nested_file.doc
├── Downloads/
│   ├── image.jpg
│   └── archive.zip
└── Desktop/
    ├── shortcut.lnk -> /usr/bin/app
    └── readme.md
```

## Features to Implement
- Tree structure visualization
- File type detection
- Size display option
- Depth control
- File filtering
- Hidden file handling
- Symbolic link detection
- Color output

## Test Cases
1. Generate tree for current directory
2. Test with depth limitation
3. Test file filtering
4. Test with symbolic links
5. Export to file functionality