# ELT Examples - Extract, Load, Transform

## Overview
Collection of ELT (Extract, Load, Transform) examples with Python and PySpark, focusing on loading data into data warehouse before transformation.

## Directory Structure
```
elt_examples/
├── extract/                  # Extract scripts
│   ├── csv_extractor.py     # Extract from CSV
│   ├── json_extractor.py    # Extract from JSON
│   └── api_extractor.py     # Extract from API
├── load/                    # Load scripts
│   ├── warehouse_loader.py  # Load to warehouse
│   └── batch_loader.py      # Batch loading
├── transform/               # Transform scripts
│   ├── data_cleaner.py      # Data cleaning
│   └── aggregator.py        # Data aggregation
├── data/                    # Sample data
├── output/                  # Output results
├── requirements.txt         # Dependencies
├── run.sh                  # ELT pipeline runner
└── README.md               # This guide
```

## Quick Setup

### 1. Environment Setup
```bash
# Run complete ELT pipeline
./run.sh all

# Or step by step
./run.sh setup     # Setup environment
./run.sh extract   # Extract data
./run.sh load      # Load to warehouse
./run.sh transform # Transform data
```

## ELT Pipeline Components

### 1. Extract Phase

#### CSV Extractor (extract/csv_extractor.py)
Extract data from CSV files.

```bash
python extract/csv_extractor.py data/source.csv
```

**Features:**
- Read multiple CSV files
- Schema validation
- Data quality checks
- Error handling and logging

#### API Extractor (extract/api_extractor.py)
Extract data from REST APIs.

```bash
python extract/api_extractor.py --endpoint https://api.example.com/data
```

**Features:**
- REST API calls with authentication
- Rate limiting and retry logic
- JSON response parsing
- Incremental data extraction

### 2. Load Phase

#### Warehouse Loader (load/warehouse_loader.py)
Load data into data warehouse.

```bash
python load/warehouse_loader.py --source extracted_data/ --target warehouse/
```

**Features:**
- Bulk loading to warehouse
- Partitioning strategies
- Data compression
- Load monitoring and metrics

### 3. Transform Phase

#### Data Cleaner (transform/data_cleaner.py)
Clean and standardize data in warehouse.

```bash
python transform/data_cleaner.py --table raw_data --output clean_data
```

**Features:**
- Remove duplicates and outliers
- Data type conversions
- Missing value handling
- Data validation rules

## ELT vs ETL

### ELT Approach (Extract → Load → Transform)
- **Extract**: Get data from sources
- **Load**: Load raw data into data warehouse
- **Transform**: Process data within warehouse

### ELT Advantages
- Leverage processing power of modern data warehouses
- Flexibility in transformation logic
- Faster time-to-insight
- Better scalability for big data

### Use Cases
- Cloud data warehouses (Snowflake, BigQuery, Redshift)
- Data lakes with compute engines
- Real-time analytics
- Machine learning pipelines

## Running ELT Pipeline

### Full Pipeline
```bash
# Activate virtual environment
source venv/bin/activate

# Run complete ELT pipeline
./run.sh all
```

### Individual Steps
```bash
# Extract phase
cd extract
python csv_extractor.py ../data/source.csv
python api_extractor.py --endpoint https://api.example.com

# Load phase
cd ../load
python warehouse_loader.py --source ../extracted/ --target ../warehouse/

# Transform phase
cd ../transform
python data_cleaner.py --input ../warehouse/raw --output ../warehouse/clean
python aggregator.py --input ../warehouse/clean --output ../warehouse/aggregated
```

## Output Results

### Extract Phase
- `extracted/csv/`: Raw CSV data
- `extracted/json/`: Raw JSON data
- `extracted/api/`: API response data
- `logs/extract.log`: Extraction logs

### Load Phase
- `warehouse/raw/`: Raw data loaded to warehouse
- `warehouse/staging/`: Staging tables
- `logs/load.log`: Loading logs and metrics

### Transform Phase
- `warehouse/clean/`: Cleaned and validated data
- `warehouse/aggregated/`: Aggregated tables
- `warehouse/marts/`: Business logic applied data
- `logs/transform.log`: Transformation logs

## ELT Patterns and Best Practices

### Extract Patterns
```python
# Incremental extraction
def extract_incremental(source, last_updated):
    return source.filter(col("updated_at") > last_updated)

# Batch extraction with partitioning
def extract_batch(source, partition_col, partition_value):
    return source.filter(col(partition_col) == partition_value)
```

### Load Patterns
```python
# Bulk loading with compression
def bulk_load(df, target_path):
    df.write.mode("overwrite").option("compression", "snappy").parquet(target_path)

# Streaming load
def stream_load(df, target_table):
    df.writeStream.format("delta").outputMode("append").table(target_table)
```

### Transform Patterns
```python
# SQL-based transforms in warehouse
def sql_transform(spark, query):
    return spark.sql(query)

# Incremental transforms
def incremental_transform(source_table, target_table, merge_key):
    # MERGE logic for incremental updates
    pass
```

### Error Handling
```python
try:
    # Data processing
    result = process_data(df)
except Exception as e:
    print(f"Error: {e}")
finally:
    spark.stop()  # Cleanup resources
```

## Troubleshooting

### Common Issues
1. **Java not found**: Install Java 8 or 11
2. **Memory issues**: Increase Spark driver memory
3. **Permission denied**: `chmod +x run.sh`
4. **Module not found**: Run `pip install -r requirements.txt`

### Debug Commands
```bash
# Check Java
java -version

# Check Python packages
pip list | grep -E "(pyspark|pandas)"

# Test Spark
python -c "from pyspark.sql import SparkSession; print('Spark OK')"

# Verbose output
python -v script.py
```

## Performance Tips

### PySpark Optimization
- Use `coalesce()` to reduce partitions
- Cache DataFrame when used multiple times: `df.cache()`
- Use `broadcast()` for small tables
- Enable adaptive query execution

### Memory Management
```python
# Spark configuration
spark = SparkSession.builder \
    .config("spark.driver.memory", "4g") \
    .config("spark.executor.memory", "4g") \
    .config("spark.sql.adaptive.enabled", "true") \
    .getOrCreate()
```

## Extensions

### Adding New Examples
1. Create Python file in appropriate directory
2. Add to `run.sh`
3. Update README.md

### Integration with Other Tools
- **Jupyter Notebook**: Convert scripts to notebooks
- **Apache Airflow**: Create DAGs for ELT pipelines
- **Docker**: Containerize examples
- **CI/CD**: Automated testing and deployment

This ELT example collection provides a foundation for building modern data pipelines with ELT approach, leveraging the power of cloud data warehouses and distributed computing frameworks.