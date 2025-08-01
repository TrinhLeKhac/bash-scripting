#!/usr/bin/env python3
"""
Data Generator
Generate sample data for other examples
"""

import pandas as pd
import numpy as np
import random
from datetime import datetime, timedelta
import sys

def generate_sample_data(num_rows=1000):
    """Generate sample data"""
    np.random.seed(42)
    random.seed(42)
    
    # Create data
    data = {
        'id': range(1, num_rows + 1),
        'name': [f'User_{i}' for i in range(1, num_rows + 1)],
        'age': np.random.randint(18, 80, num_rows),
        'salary': np.random.normal(50000, 15000, num_rows).round(2),
        'department': np.random.choice(['IT', 'HR', 'Finance', 'Marketing', 'Sales'], num_rows),
        'city': np.random.choice(['Hanoi', 'HCMC', 'Danang', 'Haiphong', 'Cantho'], num_rows),
        'experience_years': np.random.randint(0, 20, num_rows),
        'performance_score': np.random.uniform(1, 5, num_rows).round(2)
    }
    
    # Add some missing values
    missing_indices = np.random.choice(num_rows, size=int(num_rows * 0.05), replace=False)
    for idx in missing_indices:
        col = np.random.choice(['salary', 'performance_score'])
        data[col][idx] = np.nan
    
    return pd.DataFrame(data)

def generate_text_data():
    """Generate text data for wordcount"""
    texts = [
        "Apache Spark is a unified analytics engine for large-scale data processing.",
        "PySpark is the Python API for Apache Spark.",
        "Data processing with Spark is fast and efficient.",
        "Machine learning with Spark MLlib is powerful.",
        "Spark SQL provides structured data processing.",
        "Real-time stream processing with Spark Streaming.",
        "Spark runs on Hadoop, Apache Mesos, Kubernetes, standalone, or in the cloud.",
        "Python is a popular programming language for data science.",
        "Data analysis with pandas and numpy is common in Python.",
        "Visualization with matplotlib and seaborn helps understand data."
    ] * 50  # Repeat to have enough text
    
    return '\n'.join(texts)

def main():
    num_rows = int(sys.argv[1]) if len(sys.argv) > 1 else 1000
    
    print(f"Generating {num_rows} rows of sample data...")
    
    # Create CSV data
    df = generate_sample_data(num_rows)
    df.to_csv('../data/sample_data.csv', index=False)
    print("Created ../data/sample_data.csv")
    
    # Create text data
    text_data = generate_text_data()
    with open('../data/sample_text.txt', 'w') as f:
        f.write(text_data)
    print("Created ../data/sample_text.txt")
    
    print("\nGenerated data information:")
    print(df.info())
    print("\nSample data:")
    print(df.head())

if __name__ == "__main__":
    main()