#!/usr/bin/env python3
"""
PySpark ETL Pipeline Example
Extract, Transform, Load pipeline with PySpark
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, when, regexp_replace, upper, trim, to_date
from pyspark.sql.types import *
import sys

def extract_data(spark, input_path):
    """Extract: Read data from multiple sources"""
    print("=== EXTRACT PHASE ===")
    
    # Read CSV
    df = spark.read.option("header", "true").option("inferSchema", "true").csv(input_path)
    print(f"Read {df.count()} rows from {input_path}")
    
    return df

def transform_data(df):
    """Transform: Clean and transform data"""
    print("\n=== TRANSFORM PHASE ===")
    
    # Clean data
    df_clean = df.na.drop()  # Remove null values
    print(f"After removing nulls: {df_clean.count()} rows")
    
    # Normalize text columns
    string_cols = [field.name for field in df_clean.schema.fields if isinstance(field.dataType, StringType)]
    
    for col_name in string_cols:
        df_clean = df_clean.withColumn(
            col_name, 
            trim(upper(regexp_replace(col(col_name), "[^a-zA-Z0-9\\s]", "")))
        )
    
    # Add derived columns
    numeric_cols = [field.name for field in df_clean.schema.fields if isinstance(field.dataType, (IntegerType, DoubleType, FloatType))]
    
    if len(numeric_cols) >= 2:
        df_clean = df_clean.withColumn(
            "ratio", 
            col(numeric_cols[0]) / col(numeric_cols[1])
        )
        
        df_clean = df_clean.withColumn(
            "category",
            when(col("ratio") > 1.5, "HIGH")
            .when(col("ratio") > 1.0, "MEDIUM")
            .otherwise("LOW")
        )
    
    print("Transform completed")
    return df_clean

def load_data(df, output_path):
    """Load: Save processed data"""
    print(f"\n=== LOAD PHASE ===")
    
    # Save in multiple formats
    df.coalesce(1).write.mode("overwrite").option("header", "true").csv(f"{output_path}/csv")
    df.write.mode("overwrite").parquet(f"{output_path}/parquet")
    
    print(f"Data saved to {output_path}")

def main():
    spark = SparkSession.builder \
        .appName("ETL_Pipeline") \
        .master("local[*]") \
        .config("spark.sql.adaptive.enabled", "true") \
        .getOrCreate()
    
    input_file = sys.argv[1] if len(sys.argv) > 1 else "../data/sample_data.csv"
    output_path = sys.argv[2] if len(sys.argv) > 2 else "output/etl_result"
    
    try:
        # ETL Pipeline
        raw_df = extract_data(spark, input_file)
        transformed_df = transform_data(raw_df)
        load_data(transformed_df, output_path)
        
        print("\n=== PIPELINE COMPLETED ===")
        print("Final data:")
        transformed_df.show(10)
        
    except Exception as e:
        print(f"Pipeline error: {e}")
    finally:
        spark.stop()

if __name__ == "__main__":
    main()