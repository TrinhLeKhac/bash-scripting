# Scala Build Tools Comprehensive Guide

## Overview
This project demonstrates various Scala build tools and packaging methods, with focus on Apache Spark applications and JAR packaging.

## Project Structure
```
build_scala_exercise/
├── sbt_project/                 # SBT (Scala Build Tool)
├── maven_project/               # Apache Maven
├── gradle_project/              # Gradle build system
├── mill_project/                # Mill build tool
├── spark_sbt/                   # Spark application with SBT
├── spark_maven/                 # Spark application with Maven
├── spark_gradle/                # Spark application with Gradle
├── assembly_builds/             # Fat JAR creation
├── docker_builds/               # Docker containerization
├── fat_jar_builds/              # Uber JAR packaging
└── Makefile                     # Unified build system
```

## Build Tools Covered

### 1. **SBT** (Scala Build Tool)
- Native Scala build tool
- Interactive shell
- Incremental compilation
- Plugin ecosystem

### 2. **Maven** (Apache Maven)
- XML-based configuration
- Mature ecosystem
- Enterprise standard
- Extensive plugin support

### 3. **Gradle** (Gradle Build Tool)
- Groovy/Kotlin DSL
- Flexible and powerful
- Fast incremental builds
- Multi-project support

### 4. **Mill** (Modern Build Tool)
- Simple and fast
- Scala-based configuration
- Good performance
- Easy to understand

## Spark Applications
- **Data Processing**: ETL pipelines
- **Analytics**: Batch and streaming
- **Machine Learning**: MLlib integration
- **JAR Packaging**: Deployment-ready artifacts

## JAR Types
- **Thin JAR**: Application code only
- **Fat JAR**: All dependencies included
- **Uber JAR**: Single executable JAR
- **Assembly**: Optimized fat JAR

## Detailed Setup Steps

### Prerequisites
```bash
# Install Java 11+
java -version

# Install Scala
scala -version

# Install SBT
sbt --version

# Install Maven
mvn --version

# Install Gradle
gradle --version

# Install Apache Spark
spark-submit --version
```

### Step-by-Step Walkthrough

#### 1. SBT (Scala Build Tool)
```bash
cd sbt_project

# Interactive SBT shell
sbt

# Inside SBT shell:
compile          # Compile source code
test             # Run tests
run              # Run main class
package          # Create JAR
assembly         # Create fat JAR
reload           # Reload build.sbt changes

# Command line (non-interactive)
sbt clean compile test package
sbt "run arg1 arg2"  # Run with arguments
sbt assembly         # Create fat JAR

# Dependency management
sbt dependencyTree   # Show dependency tree
sbt dependencyUpdates # Check for updates
```

#### 2. Spark SBT Application
```bash
cd spark_sbt

# Compile Spark application
sbt compile

# Run tests
sbt test

# Create assembly JAR (fat JAR)
sbt assembly

# Submit to Spark cluster
spark-submit \
  --class com.example.WordCount \
  --master local[*] \
  target/scala-2.12/spark-sbt-demo-1.0.0-assembly.jar \
  input.txt output

# Run with specific Spark configuration
spark-submit \
  --class com.example.DataAnalytics \
  --master local[*] \
  --driver-memory 4g \
  --executor-memory 2g \
  target/scala-2.12/spark-sbt-demo-1.0.0-assembly.jar
```

#### 3. Maven Build System
```bash
cd maven_project

# Compile source code
mvn compile

# Run tests
mvn test

# Package JAR
mvn package

# Create fat JAR with dependencies
mvn package assembly:single

# Install to local repository
mvn install

# Clean build artifacts
mvn clean

# Full build lifecycle
mvn clean compile test package

# Run application
mvn exec:java -Dexec.mainClass="com.example.Main"
```

#### 4. Spark Maven Application
```bash
cd spark_maven

# Compile Spark application
mvn compile

# Package with dependencies
mvn package

# Submit Spark job
spark-submit \
  --class com.example.DataAnalytics \
  --master local[*] \
  target/spark-maven-demo-1.0.0-jar-with-dependencies.jar

# Run with Maven exec plugin
mvn exec:java -Dexec.mainClass="com.example.DataAnalytics"
```

#### 5. Gradle Build System
```bash
cd gradle_project

# Compile source code
gradle compileScala

# Run tests
gradle test

# Build JAR
gradle jar

# Create fat JAR (Shadow plugin)
gradle shadowJar

# Run application
gradle run

# Show dependencies
gradle dependencies

# Check for dependency updates
gradle dependencyUpdates
```

#### 6. Spark Gradle Application
```bash
cd spark_gradle

# Build Spark application
gradle compileScala

# Create shadow JAR
gradle shadowJar

# Submit to Spark
spark-submit \
  --class com.example.SparkApp \
  --master local[*] \
  build/libs/spark-gradle-1.0.0-all.jar
```

## JAR Packaging Strategies

### 1. Thin JAR (Application Only)
```bash
# SBT
sbt package
# Output: target/scala-2.12/project-name_2.12-1.0.0.jar

# Maven
mvn package
# Output: target/project-name-1.0.0.jar

# Gradle
gradle jar
# Output: build/libs/project-name-1.0.0.jar
```

### 2. Fat JAR (All Dependencies)
```bash
# SBT Assembly
sbt assembly
# Output: target/scala-2.12/project-name-assembly-1.0.0.jar

# Maven Assembly
mvn package assembly:single
# Output: target/project-name-1.0.0-jar-with-dependencies.jar

# Gradle Shadow
gradle shadowJar
# Output: build/libs/project-name-1.0.0-all.jar
```

### 3. Uber JAR (Single Executable)
```bash
# All tools can create uber JARs with proper main class configuration
# Run directly with: java -jar uber.jar
```

## Spark Application Development

### WordCount Example
```scala
// Basic text processing
val textDF = spark.read.text("input.txt")
val wordCount = textDF
  .select(explode(split(col("value"), "\\s+")).as("word"))
  .groupBy("word")
  .count()
  .orderBy(desc("count"))
```

### Data Analytics Example
```scala
// Advanced analytics with aggregations
val salesDF = spark.read.option("header", "true").csv("sales.csv")
val categoryRevenue = salesDF
  .groupBy("category")
  .agg(
    sum("revenue").as("total_revenue"),
    avg("revenue").as("avg_revenue")
  )
```

## Performance Optimization

### SBT Optimization
```scala
// build.sbt
ThisBuild / useSuperShell := false  // Disable for CI
ThisBuild / autoStartServer := false
Global / concurrentRestrictions += Tags.limit(Tags.Test, 1)
```

### Maven Optimization
```xml
<!-- pom.xml -->
<plugin>
  <groupId>net.alchim31.maven</groupId>
  <artifactId>scala-maven-plugin</artifactId>
  <configuration>
    <jvmArgs>
      <jvmArg>-Xmx4g</jvmArg>
    </jvmArgs>
  </configuration>
</plugin>
```

### Gradle Optimization
```gradle
// gradle.properties
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.configureondemand=true
org.gradle.jvmargs=-Xmx4g -XX:+UseG1GC
```

## Build Tool Comparison

| Feature | SBT | Maven | Gradle | Mill |
|---------|-----|-------|--------|----- |
| Configuration | build.sbt | pom.xml | build.gradle | build.sc |
| Language | Scala DSL | XML | Groovy/Kotlin | Scala |
| Incremental | Excellent | Good | Excellent | Good |
| Ecosystem | Scala-focused | Java-focused | Multi-language | Scala-focused |
| Learning Curve | Steep | Medium | Medium | Low |
| Performance | Fast | Medium | Fast | Fast |
| IDE Support | Excellent | Excellent | Excellent | Growing |

## Deployment Strategies

### Local Development
```bash
# Run Spark locally
spark-submit --master local[*] app.jar

# Debug mode
spark-submit --master local[*] --conf spark.driver.extraJavaOptions="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005" app.jar
```

### Cluster Deployment
```bash
# YARN cluster
spark-submit --master yarn --deploy-mode cluster app.jar

# Kubernetes
spark-submit --master k8s://https://k8s-apiserver-host:port --deploy-mode cluster app.jar

# Standalone cluster
spark-submit --master spark://master:7077 app.jar
```

## Quick Start Commands
```bash
# Setup all environments
make setup-all

# Build all projects
make build-all

# Build Spark applications
make build-spark

# Create fat JARs
make package-jars

# Run Spark jobs
make run-spark

# Performance benchmark
make benchmark

# Clean all builds
make clean-all
```

## Demo Applications and Scripts

### Spark Applications

#### 1. WordCount (Basic Text Processing)
```bash
# Build and run WordCount
cd spark_sbt
sbt assembly
spark-submit --class com.example.WordCount --master local[*] target/scala-2.12/*assembly*.jar input.txt output
```

#### 2. DataAnalytics (Advanced Analytics)
```bash
# Run sales data analysis
spark-submit --class com.example.DataAnalytics --master local[*] target/scala-2.12/*assembly*.jar demo_data/sales_data.csv analytics_output
```

#### 3. StreamingAnalytics (Real-time Processing)
```bash
# Run streaming analytics
spark-submit --class com.example.StreamingAnalytics --master local[*] target/scala-2.12/*assembly*.jar /tmp/streaming_input /tmp/streaming_output
```

#### 4. MLPipeline (Machine Learning)
```bash
# Run ML pipeline
spark-submit --class com.example.MLPipeline --master local[*] target/scala-2.12/*assembly*.jar ml_data.csv ml_output classification
```

### Demo Runner Script
```bash
# Run all Spark demos automatically
cd demo_scripts
chmod +x run_spark_demos.sh
./run_spark_demos.sh

# Clean and run demos
./run_spark_demos.sh --clean
```

### Sample Data Files
- `demo_data/sales_data.csv` - Sales data for analytics
- `demo_data/sample_text.txt` - Text data for WordCount (auto-generated)
- `demo_data/ml_sample.csv` - ML training data (auto-generated)

## New Spark Applications

### StreamingAnalytics.scala
- **Real-time processing**: File-based streaming
- **Windowed aggregations**: 5-minute windows
- **Alert detection**: Temperature/humidity thresholds
- **Multiple outputs**: Console, JSON files
- **Watermarking**: 10-minute watermark for late data

### MLPipeline.scala
- **Classification**: Logistic Regression, Random Forest
- **Regression**: Linear Regression, Random Forest
- **Clustering**: K-means clustering
- **Feature engineering**: VectorAssembler, StandardScaler
- **Model evaluation**: Accuracy, F1, RMSE, R²
- **Cross-validation**: Model selection

### Enhanced DataAnalytics.scala
- **Schema definition**: Structured data processing
- **Data validation**: Quality checks and cleaning
- **Advanced aggregations**: Multiple metrics per group
- **Time series analysis**: Monthly trends
- **Performance optimization**: Caching, adaptive query execution

## Comprehensive Test Suite

### WordCountTest.scala
- **Basic functionality**: Word counting accuracy
- **Edge cases**: Empty strings, special characters
- **Case sensitivity**: Proper word separation
- **Data validation**: Input/output verification

### DataAnalyticsTest.scala
- **Revenue calculations**: Price × quantity validation
- **Regional analysis**: Multi-dimensional aggregations
- **Data filtering**: Invalid data handling
- **Monthly trends**: Time-based grouping
- **Empty dataset handling**: Graceful error handling

### Test Framework Integration
- **ScalaTest**: BDD-style testing
- **Spark Testing Base**: Spark-specific test utilities
- **DataFrameSuiteBase**: DataFrame comparison utilities
- **Local Spark**: In-memory testing environment

## Build Enhancements

### Updated build.sbt
```scala
// Enhanced assembly settings
assembly / assemblyMergeStrategy := {
  case PathList("META-INF", "services", xs @ _*) => MergeStrategy.filterDistinctLines
  case PathList("META-INF", xs @ _*) => MergeStrategy.discard
  case "application.conf" => MergeStrategy.concat
  case "reference.conf" => MergeStrategy.concat
  case _ => MergeStrategy.first
}

// Spark dependencies with provided scope
libraryDependencies ++= Seq(
  "org.apache.spark" %% "spark-core" % sparkVersion % "provided",
  "org.apache.spark" %% "spark-sql" % sparkVersion % "provided",
  "org.apache.spark" %% "spark-mllib" % sparkVersion % "provided",
  "org.apache.spark" %% "spark-streaming" % sparkVersion % "provided"
)
```

## Learning Objectives
- Master different Scala build tools (SBT, Maven, Gradle)
- Understand JAR packaging strategies (thin, fat, uber)
- Build production-ready Spark applications
- Compare build tool performance and features
- Learn deployment best practices for Spark
- Optimize build configurations for large projects
- Choose the right build tool for your team
- Implement real-time streaming analytics
- Build end-to-end ML pipelines
- Write comprehensive test suites for Spark apps