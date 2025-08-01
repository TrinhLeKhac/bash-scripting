#!/usr/bin/env python3
"""
PySpark Data Analysis Example
Analyze CSV data with basic operations
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, avg, max, min, count, when, isnan, isnull
from pyspark.sql.types import *
import sys

def main():
    spark = SparkSession.builder \
        .appName("DataAnalysis") \
        .master("local[*]") \
        .getOrCreate()
    
    # Read CSV file
    input_file = sys.argv[1] if len(sys.argv) > 1 else "../data/sample_data.csv"
    
    df = spark.read.option("header", "true").option("inferSchema", "true").csv(input_file)
    
    print("=== BASIC INFORMATION ===")
    print(f"Number of rows: {df.count()}")
    print(f"Number of columns: {len(df.columns)}")
    print("\nSchema:")
    df.printSchema()
    
    print("\n=== SAMPLE DATA ===")
    df.show(10)
    
    print("\n=== DESCRIPTIVE STATISTICS ===")
    df.describe().show()
    
    print("\n=== MISSING DATA CHECK ===")
    for column in df.columns:
        null_count = df.filter(col(column).isNull() | isnan(col(column))).count()
        print(f"{column}: {null_count} null values")
    
    # Filter data
    print("\n=== DATA FILTERING ===")
    numeric_cols = [field.name for field in df.schema.fields if isinstance(field.dataType, (IntegerType, DoubleType, FloatType))]
    
    if numeric_cols:
        first_numeric = numeric_cols[0]
        avg_value = df.select(avg(col(first_numeric))).collect()[0][0]
        filtered_df = df.filter(col(first_numeric) > avg_value)
        print(f"Data with {first_numeric} > {avg_value:.2f}: {filtered_df.count()} rows")
        filtered_df.show(5)
    
    # Group by and aggregation
    print("\n=== GROUPING AND AGGREGATION ===")
    categorical_cols = [field.name for field in df.schema.fields if isinstance(field.dataType, StringType)]
    
    if categorical_cols and numeric_cols:
        cat_col = categorical_cols[0]
        num_col = numeric_cols[0]
        
        grouped = df.groupBy(cat_col).agg(
            count("*").alias("count"),
            avg(col(num_col)).alias(f"avg_{num_col}"),
            max(col(num_col)).alias(f"max_{num_col}"),
            min(col(num_col)).alias(f"min_{num_col}")
        ).orderBy(col("count").desc())
        
        grouped.show()
    
    spark.stop()

if __name__ == "__main__":
    main()