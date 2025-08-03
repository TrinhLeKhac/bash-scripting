# SBT Scala Project Demo

Comprehensive SBT (Scala Build Tool) project demonstrating modern Scala development practices, testing, and build automation.

## Overview

This project showcases:
- **Modern SBT configuration** with Scala 2.13
- **Comprehensive testing** with ScalaTest
- **Assembly JAR creation** for deployment
- **Code formatting** with Scalafmt
- **Test coverage** reporting
- **Automated build scripts** for CI/CD

## Project Structure

```
sbt_project/
├── src/
│   ├── main/scala/com/example/sbtdemo/
│   │   ├── DataProcessor.scala     # Core data processing logic
│   │   └── Main.scala              # Application entry point
│   └── test/scala/com/example/sbtdemo/
│       └── DataProcessorSpec.scala # Comprehensive test suite
├── project/
│   └── plugins.sbt                 # SBT plugins configuration
├── build.sbt                       # Main build configuration
├── build_and_run.sh               # Automated build script
├── README.md                       # This documentation
└── sample_data.csv                 # Sample data for testing
```

## Prerequisites

### Install SBT
```bash
# macOS
brew install sbt

# Linux (Ubuntu/Debian)
echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
sudo apt-get update
sudo apt-get install sbt

# Manual installation
# Download from: https://www.scala-sbt.org/download.html
```

### Verify Installation
```bash
sbt --version
# Should show: sbt version in this project: 1.9.x
```

## Quick Start

### Using the Build Script (Recommended)

```bash
# Make script executable
chmod +x build_and_run.sh

# Build entire project (clean, compile, test)
./build_and_run.sh build

# Run application with sample data
./build_and_run.sh run

# Create sample data file and process it
./build_and_run.sh sample
./build_and_run.sh run file sample_data.csv

# Process custom data
./build_and_run.sh run data "1,2,3,4,5,-1,-2"
```

### Manual SBT Commands

```bash
# Clean and compile
sbt clean compile

# Run tests
sbt test

# Run application
sbt run

# Create assembly JAR
sbt assembly

# Run with arguments
sbt "run --file sample_data.csv"
sbt "run --data 1,2,3,4,5"
sbt "run --help"
```

## Build Configuration Details

### build.sbt Features

```scala
// Modern Scala version
ThisBuild / scalaVersion := "2.13.12"

// Comprehensive compiler options
scalacOptions ++= Seq(
  "-deprecation",      // Warn about deprecated features
  "-encoding", "UTF-8", // Source file encoding
  "-feature",          // Warn about language features
  "-unchecked",        // Warn about unchecked operations
  "-Xlint",           // Enable additional warnings
  "-Ywarn-dead-code", // Warn about dead code
  "-Ywarn-numeric-widen", // Warn about numeric widening
  "-Ywarn-value-discard"  // Warn about discarded values
)

// Dependencies
libraryDependencies ++= Seq(
  "org.scalatest" %% "scalatest" % "3.2.17" % Test,
  "org.scalactic" %% "scalactic" % "3.2.17",
  "com.typesafe.scala-logging" %% "scala-logging" % "3.9.5",
  "ch.qos.logback" % "logback-classic" % "1.4.11"
)
```

### SBT Plugins (project/plugins.sbt)

- **sbt-assembly**: Create fat JARs with all dependencies
- **sbt-scoverage**: Code coverage reporting
- **sbt-scalafmt**: Code formatting
- **sbt-updates**: Check for dependency updates
- **sbt-native-packager**: Create distribution packages
- **sbt-buildinfo**: Generate build information

## Application Features

### DataProcessor Object

```scala
// Calculate statistics for numbers
val stats = DataProcessor.calculateStats(List(1.0, 2.0, 3.0, 4.0, 5.0))
// Returns: Map("count" -> 5.0, "sum" -> 15.0, "mean" -> 3.0, ...)

// Filter numbers by condition
val positive = DataProcessor.filterNumbers(numbers, _ > 0)

// Parse CSV data
val result = DataProcessor.parseCsvLine("1,2,3,4,5")

// Process multiple CSV lines
val analysis = DataProcessor.processCsvData(csvLines)
```

### Main Application

```bash
# Process CSV file
sbt "run --file data.csv"

# Process inline data
sbt "run --data 1,2,3,4,5,-1,-2"

# Show help
sbt "run --help"

# Default sample processing
sbt run
```

## Testing

### Run Tests
```bash
# All tests
sbt test

# Specific test class
sbt "testOnly *DataProcessorSpec"

# Tests with detailed output
sbt "test -- -oD"
```

### Test Coverage
```bash
# Generate coverage report
sbt coverage test coverageReport

# View report
open target/scala-2.13/scoverage-report/index.html
```

### Test Structure
```scala
class DataProcessorSpec extends AnyFlatSpec with Matchers {
  "DataProcessor.calculateStats" should "calculate correct statistics" in {
    val numbers = List(1.0, 2.0, 3.0, 4.0, 5.0)
    val stats = DataProcessor.calculateStats(numbers)
    
    stats("mean") shouldBe 3.0
    stats("count") shouldBe 5.0
  }
}
```

## Build and Deployment

### Create Assembly JAR
```bash
# Using build script
./build_and_run.sh assembly

# Manual SBT command
sbt assembly

# Result: target/scala-2.13/sbt-demo.jar
```

### Run Assembly JAR
```bash
# Using build script
./build_and_run.sh jar
./build_and_run.sh jar file sample_data.csv
./build_and_run.sh jar data "1,2,3,4,5"

# Direct Java execution
java -jar target/scala-2.13/sbt-demo.jar
java -jar target/scala-2.13/sbt-demo.jar --file sample_data.csv
java -jar target/scala-2.13/sbt-demo.jar --data "1,2,3,4,5"
```

## Development Workflow

### Code Formatting
```bash
# Format all code
./build_and_run.sh format

# Or manually
sbt scalafmt
```

### Dependency Management
```bash
# Check for updates
./build_and_run.sh updates

# Or manually
sbt dependencyUpdates
```

### Continuous Development
```bash
# Auto-compile on file changes
sbt ~compile

# Auto-test on file changes
sbt ~test

# Auto-run on file changes
sbt ~run
```

## Build Script Commands

### Available Commands
```bash
./build_and_run.sh build          # Full build (clean, compile, test)
./build_and_run.sh compile        # Compile only
./build_and_run.sh test           # Run tests
./build_and_run.sh coverage       # Test coverage
./build_and_run.sh assembly       # Create JAR
./build_and_run.sh run [args]     # Run with SBT
./build_and_run.sh jar [args]     # Run JAR directly
./build_and_run.sh format         # Format code
./build_and_run.sh updates        # Check updates
./build_and_run.sh info           # Project info
./build_and_run.sh sample         # Create sample data
./build_and_run.sh clean          # Clean build
./build_and_run.sh help           # Show help
```

### Run Arguments
```bash
# Default sample processing
./build_and_run.sh run

# Process file
./build_and_run.sh run file sample_data.csv

# Process inline data
./build_and_run.sh run data "1,2,3,4,5,-1,-2"

# Show application help
./build_and_run.sh run help
```

## Performance and Optimization

### JVM Options
```scala
// In build.sbt
run / javaOptions ++= Seq(
  "-Xmx1G",           // Max heap size
  "-XX:+UseG1GC"      // Use G1 garbage collector
)
```

### Assembly Optimization
```scala
// Exclude Scala library for smaller JARs
assembly / assemblyOption := (assembly / assemblyOption).value.copy(
  includeScala = false
)

// Custom merge strategy
assembly / assemblyMergeStrategy := {
  case PathList("META-INF", xs @ _*) => MergeStrategy.discard
  case PathList("reference.conf") => MergeStrategy.concat
  case _ => MergeStrategy.first
}
```

## CI/CD Integration

### GitHub Actions Example
```yaml
name: SBT Build
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-java@v3
      with:
        java-version: '11'
        distribution: 'temurin'
    - name: Run tests
      run: sbt test
    - name: Create assembly
      run: sbt assembly
```

### Docker Integration
```dockerfile
FROM openjdk:11-jre-slim
COPY target/scala-2.13/sbt-demo.jar /app/
WORKDIR /app
ENTRYPOINT ["java", "-jar", "sbt-demo.jar"]
```

## Troubleshooting

### Common Issues

1. **SBT not found**
   ```bash
   # Install SBT first
   brew install sbt  # macOS
   ```

2. **Out of memory**
   ```bash
   # Increase heap size
   export SBT_OPTS="-Xmx2G"
   ```

3. **Dependency conflicts**
   ```bash
   # Check dependency tree
   sbt dependencyTree
   ```

4. **Assembly conflicts**
   ```bash
   # Check merge strategy in build.sbt
   sbt "show assembly / assemblyMergeStrategy"
   ```

### Debug Commands
```bash
# Verbose compilation
sbt -v compile

# Show classpath
sbt "show Compile / fullClasspath"

# Show settings
sbt settings

# Show tasks
sbt tasks
```

## Best Practices

### Project Organization
- Use package structure: `com.example.sbtdemo`
- Separate concerns: data processing, CLI, utilities
- Comprehensive test coverage
- Clear documentation

### Build Configuration
- Pin dependency versions
- Use semantic versioning
- Configure compiler warnings
- Optimize assembly settings

### Development Workflow
- Use continuous compilation: `sbt ~compile`
- Format code regularly: `sbt scalafmt`
- Run tests frequently: `sbt ~test`
- Check coverage: `sbt coverage test coverageReport`

## Learning Resources

- [SBT Documentation](https://www.scala-sbt.org/documentation.html)
- [Scala Documentation](https://docs.scala-lang.org/)
- [ScalaTest User Guide](https://www.scalatest.org/user_guide)
- [Assembly Plugin](https://github.com/sbt/sbt-assembly)

This SBT project demonstrates modern Scala development practices with comprehensive build automation, testing, and deployment capabilities.