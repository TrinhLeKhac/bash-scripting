# Exercise 5: Cross-Platform Package Manager

## Objective
Create a sophisticated Makefile that builds, packages, and distributes software for multiple operating systems and architectures, with automated release management.

## Project Structure
```
cross_platform_project/
├── src/
│   ├── main.c
│   ├── platform/
│   │   ├── linux.c
│   │   ├── macos.c
│   │   └── windows.c
│   └── include/
│       └── platform.h
├── packaging/
│   ├── linux/
│   │   ├── debian/
│   │   │   ├── control
│   │   │   └── postinst
│   │   ├── rpm/
│   │   │   └── spec.template
│   │   └── appimage/
│   │       └── AppRun
│   ├── macos/
│   │   ├── Info.plist
│   │   └── entitlements.plist
│   ├── windows/
│   │   ├── installer.nsi
│   │   └── manifest.xml
│   └── docker/
│       ├── Dockerfile.linux
│       ├── Dockerfile.alpine
│       └── Dockerfile.scratch
├── scripts/
│   ├── build.sh
│   ├── package.sh
│   └── release.sh
├── tests/
│   └── cross_platform_test.sh
├── dist/
├── releases/
└── Makefile
```

## Requirements

### Cross-Platform Building
1. **Linux**: Build for x86_64, ARM64, ARM32
2. **macOS**: Build for Intel and Apple Silicon (universal binary)
3. **Windows**: Build for x86, x64, ARM64
4. **FreeBSD**: Build for x86_64
5. **Static Linking**: Create portable executables

### Package Formats
1. **Linux**: DEB, RPM, AppImage, Snap, Flatpak
2. **macOS**: DMG, PKG, Homebrew formula
3. **Windows**: MSI, NSIS installer, Chocolatey package
4. **Universal**: Docker images, Tarball archives
5. **Language-Specific**: npm, pip, gem packages

### Distribution Channels
1. **GitHub Releases**: Automated release creation
2. **Package Repositories**: Upload to official repos
3. **Container Registries**: Docker Hub, GitHub Container Registry
4. **CDN Distribution**: Upload to CDN for fast downloads
5. **Update Channels**: Implement auto-update mechanism

### Quality Assurance
1. **Cross-Compilation**: Verify builds work on target platforms
2. **Package Testing**: Test installation on clean systems
3. **Signature Verification**: Sign packages for security
4. **Dependency Checking**: Verify all dependencies are included
5. **Performance Testing**: Benchmark across platforms

## Expected Targets

```bash
make all-platforms     # Build for all platforms
make linux-x64         # Build Linux x86_64
make macos-universal   # Build macOS universal binary
make windows-x64       # Build Windows x64
make packages          # Create all package formats
make docker-images     # Build all Docker images
make sign-packages     # Sign all packages
make test-packages     # Test package installation
make release           # Create GitHub release
make upload-cdn        # Upload to CDN
make clean-all         # Clean all artifacts
```

## Sample Files to Create

### src/main.c
```c
#include <stdio.h>
#include <stdlib.h>
#include "platform.h"

int main(int argc, char *argv[]) {
    printf("Cross-Platform Application v%s\n", VERSION);
    printf("Platform: %s\n", get_platform_name());
    printf("Architecture: %s\n", get_architecture());
    
    // Platform-specific initialization
    if (platform_init() != 0) {
        fprintf(stderr, "Failed to initialize platform\n");
        return 1;
    }
    
    printf("Application initialized successfully\n");
    
    // Cleanup
    platform_cleanup();
    return 0;
}
```

### src/platform/linux.c
```c
#include "../include/platform.h"
#include <sys/utsname.h>
#include <string.h>

const char* get_platform_name(void) {
    return "Linux";
}

const char* get_architecture(void) {
    static struct utsname info;
    if (uname(&info) == 0) {
        return info.machine;
    }
    return "unknown";
}

int platform_init(void) {
    // Linux-specific initialization
    return 0;
}

void platform_cleanup(void) {
    // Linux-specific cleanup
}
```

### packaging/linux/debian/control
```
Package: cross-platform-app
Version: 1.0.0
Section: utils
Priority: optional
Architecture: amd64
Depends: libc6 (>= 2.17)
Maintainer: Developer <dev@example.com>
Description: Cross-platform application
 A sample cross-platform application demonstrating
 multi-architecture builds and packaging.
```

### packaging/macos/Info.plist
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>cross-platform-app</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.cross-platform-app</string>
    <key>CFBundleName</key>
    <string>Cross Platform App</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
</dict>
</plist>
```

## Cross-Platform Build Matrix

### Target Platforms
| OS | Architecture | Compiler | Package Format |
|---|---|---|---|
| Linux | x86_64 | GCC/Clang | DEB, RPM, AppImage |
| Linux | ARM64 | GCC/Clang | DEB, RPM, AppImage |
| Linux | ARM32 | GCC/Clang | DEB, RPM |
| macOS | x86_64 | Clang | DMG, PKG |
| macOS | ARM64 | Clang | DMG, PKG |
| Windows | x86 | MinGW/MSVC | MSI, NSIS |
| Windows | x64 | MinGW/MSVC | MSI, NSIS |
| FreeBSD | x86_64 | Clang | TXZ |

### Build Environment Setup
1. **Docker Containers**: Use containers for consistent builds
2. **Cross-Compilers**: Install cross-compilation toolchains
3. **SDK Management**: Download and manage platform SDKs
4. **Dependency Management**: Handle platform-specific dependencies
5. **Build Caching**: Cache compiled objects across builds

## Package Distribution Strategy

### Release Workflow
1. **Version Tagging**: Semantic versioning with Git tags
2. **Changelog Generation**: Automatic changelog from commits
3. **Asset Building**: Build all platform packages
4. **Quality Gates**: Run tests before release
5. **Publication**: Upload to distribution channels

### Security Considerations
1. **Code Signing**: Sign executables and packages
2. **Checksum Generation**: Create SHA256 checksums
3. **GPG Signatures**: Sign release artifacts
4. **Vulnerability Scanning**: Scan dependencies
5. **Supply Chain Security**: Verify build reproducibility

## Testing Your Makefile

1. Setup cross-compilation environment
2. Build for single platform: `make linux-x64`
3. Build for all platforms: `make all-platforms`
4. Create packages: `make packages`
5. Test package installation in VMs/containers
6. Create test release: `make release`
7. Verify signatures and checksums

## Advanced Challenges

1. **Reproducible Builds**: Ensure bit-for-bit reproducible builds
2. **Build Farm**: Distribute builds across multiple machines
3. **Continuous Integration**: Integrate with CI/CD pipelines
4. **Performance Optimization**: Profile and optimize for each platform
5. **Localization**: Support multiple languages and locales
6. **Auto-Updates**: Implement automatic update mechanism
7. **Telemetry**: Add usage analytics and crash reporting