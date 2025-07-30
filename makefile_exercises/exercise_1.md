# Exercise 1: Basic C Project Build System

## Objective
Create a comprehensive Makefile for a C project with multiple source files, header dependencies, and different build configurations.

## Project Structure
```
c_project/
├── src/
│   ├── main.c
│   ├── utils.c
│   └── math_ops.c
├── include/
│   ├── utils.h
│   └── math_ops.h
├── tests/
│   └── test_main.c
├── build/
├── bin/
└── Makefile
```

## Requirements

### Basic Features
1. **Compilation**: Compile all .c files in src/ directory
2. **Linking**: Create executable in bin/ directory
3. **Dependencies**: Handle header file dependencies automatically
4. **Clean**: Remove all generated files
5. **Install**: Install binary to system location

### Advanced Features
1. **Debug/Release**: Support different build configurations
2. **Testing**: Compile and run unit tests
3. **Static Analysis**: Run static code analysis tools
4. **Documentation**: Generate code documentation
5. **Cross-compilation**: Support different target architectures

### Build Configurations
- **Debug**: `-g -O0 -DDEBUG -Wall -Wextra`
- **Release**: `-O2 -DNDEBUG -Wall`
- **Profile**: `-pg -O2 -DPROFILE`

## Expected Targets

```bash
make                # Build release version
make debug          # Build debug version
make test           # Build and run tests
make clean          # Clean build artifacts
make install        # Install to system
make uninstall      # Remove from system
make docs           # Generate documentation
make check          # Run static analysis
make profile        # Build with profiling
make dist           # Create distribution package
```

## Sample Files to Create

### src/main.c
```c
#include <stdio.h>
#include "utils.h"
#include "math_ops.h"

int main() {
    printf("Hello from C project!\n");
    print_version();
    printf("2 + 3 = %d\n", add(2, 3));
    return 0;
}
```

### include/utils.h
```c
#ifndef UTILS_H
#define UTILS_H
void print_version(void);
#endif
```

## Testing Your Makefile

1. Create the project structure
2. Implement your Makefile
3. Test all targets
4. Verify dependency tracking
5. Test clean and rebuild

## Advanced Challenges

1. **Automatic dependency generation** using gcc -MM
2. **Parallel builds** with proper dependency handling
3. **Color output** for better user experience
4. **Progress indicators** during compilation
5. **Integration with pkg-config** for external libraries