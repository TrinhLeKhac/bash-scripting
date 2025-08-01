#!/usr/bin/env python3
"""
PySpark WordCount Example
Count word frequencies in text files
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import explode, split, lower, regexp_replace, col
import sys

def main():
    # Create SparkSession
    spark = SparkSession.builder \
        .appName("WordCount") \
        .master("local[*]") \
        .getOrCreate()
    
    # Read input file
    input_file = sys.argv[1] if len(sys.argv) > 1 else "../data/sample_text.txt"
    
    # Read data
    df = spark.read.text(input_file)
    
    # Process text: lowercase, remove special chars, split words
    words = df.select(
        explode(
            split(
                regexp_replace(lower(col("value")), "[^a-zA-Z0-9\\s]", ""), 
                "\\s+"
            )
        ).alias("word")
    ).filter(col("word") != "")
    
    # Count word frequencies
    word_counts = words.groupBy("word").count().orderBy(col("count").desc())
    
    # Display results
    print("Top 20 most frequent words:")
    word_counts.show(20)
    
    # Save results
    output_path = "output/wordcount_result"
    word_counts.coalesce(1).write.mode("overwrite").csv(output_path, header=True)
    print(f"Results saved to: {output_path}")
    
    spark.stop()

if __name__ == "__main__":
    main()