# Spark SBT Project Demo

Comprehensive Apache Spark application built with SBT, demonstrating modern Spark development practices, DataFrame/Dataset APIs, and distributed data processing.

## Overview

This project showcases:
- **Apache Spark 3.4.0** with Scala 2.12
- **Modern SBT configuration** for Spark applications
- **DataFrame and Dataset APIs** for data processing
- **Comprehensive testing** with Spark Testing Base
- **Assembly JAR creation** for cluster deployment
- **Local and cluster execution** modes
- **Automated build scripts** for CI/CD

## Project Structure

```
spark_sbt/
├── src/
│   ├── main/scala/com/example/sparksbt/
│   │   └── SparkDataProcessor.scala    # Main Spark application
│   └── test/scala/com/example/sparksbt/
│       └── SparkDataProcessorSpec.scala # Spark test suite
├── data/
│   ├── spark_sample.csv               # Basic dataset
│   ├── large_dataset.csv              # Large dataset for performance
│   └── financial_spark.csv            # Financial data sample
├── project/
│   ├── build.properties               # SBT version
│   └── plugins.sbt                    # SBT plugins
├── build.sbt                          # Spark SBT configuration
├── build_and_run.sh                   # Automated build script
├── .scalafmt.conf                     # Code formatting
├── .sbtopts                           # SBT options
└── README.md                          # This documentation
```

## Prerequisites

### Install Required Tools
```bash
# Install SBT
brew install sbt  # macOS
# or follow: https://www.scala-sbt.org/download.html

# Install Apache Spark (optional - for spark-submit)
brew install apache-spark  # macOS
# or download from: https://spark.apache.org/downloads.html

# Verify installations
sbt --version
spark-submit --version  # optional
```

## Quick Start

### Using the Build Script (Recommended)

```bash
# Make script executable
chmod +x build_and_run.sh

# Build entire project (clean, compile, test)
./build_and_run.sh build

# Run Spark application with sample data
./build_and_run.sh run

# Process CSV file
./build_and_run.sh run file data/spark_sample.csv

# Process inline data
./build_and_run.sh run data "1,2,3,4,5,-1,-2"

# Create assembly JAR and run with spark-submit
./build_and_run.sh assembly
./build_and_run.sh spark file data/large_dataset.csv
```

### Manual SBT Commands

```bash
# Clean and compile
sbt clean compile

# Run tests
sbt test

# Run Spark application locally
sbt run

# Create assembly JAR
sbt assembly

# Run with arguments
sbt "run --file data/spark_sample.csv"
sbt "run --data 1,2,3,4,5"
sbt "run --help"
```

## Spark Configuration

### build.sbt Features

```scala
// Spark dependencies
libraryDependencies ++= Seq(
  "org.apache.spark" %% "spark-core" % "3.4.0" % "provided",
  "org.apache.spark" %% "spark-sql" % "3.4.0" % "provided",
  "org.apache.spark" %% "spark-mllib" % "3.4.0" % "provided",
  
  // Testing
  "com.holdenkarau" %% "spark-testing-base" % "3.4.0_1.4.0" % Test
)

// Spark-optimized JVM settings
run / javaOptions ++= Seq(
  "-Xmx4G",
  "-XX:+UseG1GC",
  "-Dspark.master=local[*]",
  "-Dspark.app.name=SparkSBTDemo"
)
```

### Assembly Configuration for Spark

```scala
// Spark-specific merge strategy
assembly / assemblyMergeStrategy := {
  case PathList("META-INF", xs @ _*) => MergeStrategy.discard
  case PathList("reference.conf") => MergeStrategy.concat
  case "log4j.properties" => MergeStrategy.first
  case x if x.endsWith(".class") => MergeStrategy.first
  case _ => MergeStrategy.first
}
```

## Application Features

### SparkDataProcessor

The main application demonstrates:

#### **DataFrame API Usage:**
```scala
// Read CSV and process with DataFrame API
val df = spark.read
  .option("header", "false")
  .option("inferSchema", "false")
  .schema(csvSchema)
  .csv(filePath)

// Parse and analyze data
val numbersDF = df
  .select(explode(split(col("values"), ",")).cast(DoubleType).as("number"))
  .filter(col("number").isNotNull)

// Calculate statistics
val stats = numbersDF.agg(
  count("number").as("count"),
  sum("number").as("sum"),
  avg("number").as("mean"),
  min("number").as("min"),
  max("number").as("max"),
  stddev("number").as("stddev")
).collect()(0)
```

#### **Dataset API Usage:**
```scala
// Process inline data with Dataset API
import spark.implicits._
val numbers = data.split(",").map(_.trim.toDouble).toSeq
val numbersDS = spark.createDataset(numbers)

// Type-safe operations
val positiveCount = numbersDS.filter(_ > 0).count()
val negativeCount = numbersDS.filter(_ < 0).count()
```

#### **Optimized Spark Session:**
```scala
SparkSession.builder()
  .appName(appName)
  .master("local[*]")
  .config("spark.sql.adaptive.enabled", "true")
  .config("spark.sql.adaptive.coalescePartitions.enabled", "true")
  .config("spark.serializer", "org.apache.spark.serializer.KryoSerializer")
  .getOrCreate()
```

## Running the Application

### Local Mode (SBT)

```bash
# Default sample processing
./build_and_run.sh run

# Process CSV file
./build_and_run.sh run file data/spark_sample.csv

# Process financial data
./build_and_run.sh run file data/financial_spark.csv

# Process inline data
./build_and_run.sh run data "10.5,-5.2,15.8,-10.1,20.3"

# Show help
./build_and_run.sh run help
```

### Cluster Mode (spark-submit)

```bash
# Create assembly JAR first
./build_and_run.sh assembly

# Run with spark-submit (local mode)
./build_and_run.sh spark file data/large_dataset.csv

# Manual spark-submit with custom settings
spark-submit \
  --class com.example.sparksbt.SparkDataProcessor \
  --master local[4] \
  --driver-memory 2g \
  --executor-memory 2g \
  --conf spark.sql.adaptive.enabled=true \
  target/scala-2.12/spark-sbt-demo.jar \
  --file data/large_dataset.csv
```

### Cluster Deployment

```bash
# Submit to YARN cluster
spark-submit \
  --class com.example.sparksbt.SparkDataProcessor \
  --master yarn \
  --deploy-mode cluster \
  --driver-memory 2g \
  --executor-memory 4g \
  --num-executors 4 \
  --executor-cores 2 \
  target/scala-2.12/spark-sbt-demo.jar \
  --file hdfs://path/to/data.csv

# Submit to Kubernetes
spark-submit \
  --class com.example.sparksbt.SparkDataProcessor \
  --master k8s://https://kubernetes-api-server:443 \
  --deploy-mode cluster \
  --conf spark.kubernetes.container.image=spark:3.4.0 \
  target/scala-2.12/spark-sbt-demo.jar \
  --data "1,2,3,4,5"
```

## Testing

### Spark Testing with SharedSparkContext

```scala
class SparkDataProcessorSpec extends AnyFlatSpec 
  with Matchers with SharedSparkContext {

  "SparkDataProcessor" should "process data correctly" in {
    val testData = "1,2,3,4,5"
    noException should be thrownBy {
      SparkDataProcessor.processInlineData(spark, testData)
    }
  }
}
```

### Run Tests

```bash
# All tests
./build_and_run.sh test

# With coverage
./build_and_run.sh coverage

# Specific test
sbt "testOnly *SparkDataProcessorSpec"
```

## Performance Optimization

### JVM Settings

```scala
// In build.sbt
run / javaOptions ++= Seq(
  "-Xmx4G",                    // Max heap size
  "-XX:+UseG1GC",              // G1 garbage collector
  "-XX:+UseCompressedOops",    // Compressed object pointers
  "-XX:MaxDirectMemorySize=2g" // Off-heap memory
)
```

### Spark Configuration

```scala
// Adaptive Query Execution
.config("spark.sql.adaptive.enabled", "true")
.config("spark.sql.adaptive.coalescePartitions.enabled", "true")

// Serialization
.config("spark.serializer", "org.apache.spark.serializer.KryoSerializer")

// Memory management
.config("spark.sql.execution.arrow.pyspark.enabled", "true")
```

## Build Script Commands

### Available Commands

```bash
./build_and_run.sh build          # Full build (clean, compile, test)
./build_and_run.sh compile        # Compile only
./build_and_run.sh test           # Run tests
./build_and_run.sh coverage       # Test coverage
./build_and_run.sh assembly       # Create assembly JAR
./build_and_run.sh run [args]     # Run with SBT (local mode)
./build_and_run.sh spark [args]   # Run with spark-submit
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
./build_and_run.sh run file data/spark_sample.csv
./build_and_run.sh spark file data/large_dataset.csv

# Process inline data
./build_and_run.sh run data "1,2,3,4,5,-1,-2"
./build_and_run.sh spark data "10.5,-5.2,15.8"

# Show application help
./build_and_run.sh run help
./build_and_run.sh spark help
```

## Data Processing Examples

### Sample Output

```bash
$ ./build_and_run.sh run file data/spark_sample.csv

Processing file: data/spark_sample.csv
Total numbers: 20
Positive numbers: 16
Negative numbers: 4
Zero values: 0
Statistics:
  count: 20
  sum: 465.00
  mean: 23.25
  min: -10.00
  max: 200.00
  stddev: 52.85
```

### Large Dataset Processing

```bash
$ ./build_and_run.sh spark file data/large_dataset.csv

Processing file: data/large_dataset.csv
Total numbers: 64
Positive numbers: 54
Negative numbers: 10
Zero values: 4
Statistics:
  count: 64
  sum: 1830.00
  mean: 28.59
  min: -10.00
  max: 60.00
  stddev: 20.45
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Spark SBT Build
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
    - name: Setup SBT
      uses: olafurpg/setup-scala@v13
    - name: Run tests
      run: sbt test
    - name: Create assembly
      run: sbt assembly
    - name: Test spark-submit
      run: |
        wget https://archive.apache.org/dist/spark/spark-3.4.0/spark-3.4.0-bin-hadoop3.tgz
        tar -xzf spark-3.4.0-bin-hadoop3.tgz
        ./spark-3.4.0-bin-hadoop3/bin/spark-submit \
          --class com.example.sparksbt.SparkDataProcessor \
          --master local[2] \
          target/scala-2.12/spark-sbt-demo.jar --help
```

### Docker Integration

```dockerfile
FROM openjdk:11-jre-slim

# Install Spark
RUN wget https://archive.apache.org/dist/spark/spark-3.4.0/spark-3.4.0-bin-hadoop3.tgz && \
    tar -xzf spark-3.4.0-bin-hadoop3.tgz && \
    mv spark-3.4.0-bin-hadoop3 /opt/spark && \
    rm spark-3.4.0-bin-hadoop3.tgz

ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin

# Copy application
COPY target/scala-2.12/spark-sbt-demo.jar /app/
WORKDIR /app

ENTRYPOINT ["spark-submit", "--class", "com.example.sparksbt.SparkDataProcessor", "spark-sbt-demo.jar"]
```

## Troubleshooting

### Common Issues

1. **Out of memory errors**
   ```bash
   # Increase driver memory
   export SBT_OPTS="-Xmx4G"
   # Or in spark-submit
   spark-submit --driver-memory 4g --executor-memory 4g ...
   ```

2. **Spark version conflicts**
   ```bash
   # Check Spark version compatibility
   sbt dependencyTree | grep spark
   ```

3. **Assembly conflicts**
   ```bash
   # Check merge strategy
   sbt "show assembly / assemblyMergeStrategy"
   ```

### Debug Commands

```bash
# Verbose SBT
sbt -v compile

# Spark with debug logging
spark-submit --conf spark.sql.execution.debug.maxToStringFields=100 ...

# Check Spark UI
# Open http://localhost:4040 during execution
```

## Best Practices

### Spark Development
- Use DataFrame/Dataset APIs for type safety and optimization
- Enable Adaptive Query Execution for better performance
- Use appropriate partitioning strategies
- Monitor Spark UI for performance tuning

### Build Configuration
- Use "provided" scope for Spark dependencies in assembly
- Configure appropriate merge strategies for JAR conflicts
- Set optimal JVM settings for Spark workloads
- Use Kryo serialization for better performance

### Testing
- Use SharedSparkContext for test isolation
- Test with small datasets for unit tests
- Use Spark Testing Base for comprehensive testing
- Mock external dependencies appropriately

## Learning Resources

- [Apache Spark Documentation](https://spark.apache.org/docs/latest/)
- [Spark Scala API](https://spark.apache.org/docs/latest/api/scala/org/apache/spark/)
- [SBT Documentation](https://www.scala-sbt.org/documentation.html)
- [Spark Testing Base](https://github.com/holdenk/spark-testing-base)

This Spark SBT project demonstrates modern Spark development practices with comprehensive build automation, testing, and deployment capabilities for both local development and cluster deployment.