#!/usr/bin/env python3
"""
Data Cleaner - Clean and validate data in warehouse
"""

import pandas as pd
import json
import os
import sys
import argparse
from datetime import datetime

def clean_data(input_dir, output_dir="warehouse/clean"):
    """Clean data in warehouse"""
    try:
        # Create output directory
        os.makedirs(output_dir, exist_ok=True)
        
        cleaned_files = []
        
        # Process all Parquet files in input directory
        for root, dirs, files in os.walk(input_dir):
            for file in files:
                if file.endswith('.parquet'):
                    input_file = os.path.join(root, file)
                    
                    # Load data
                    df = pd.read_parquet(input_file)
                    original_count = len(df)
                    
                    # Data cleaning operations
                    # 1. Remove duplicates
                    df = df.drop_duplicates()
                    
                    # 2. Handle missing values
                    # Fill numeric columns with median
                    numeric_cols = df.select_dtypes(include=['number']).columns
                    for col in numeric_cols:
                        df[col] = df[col].fillna(df[col].median())
                    
                    # Fill categorical columns with mode
                    categorical_cols = df.select_dtypes(include=['object']).columns
                    for col in categorical_cols:
                        mode_value = df[col].mode()
                        if not mode_value.empty:
                            df[col] = df[col].fillna(mode_value[0])
                    
                    # 3. Data type optimization
                    for col in df.columns:
                        if df[col].dtype == 'object':
                            try:
                                df[col] = pd.to_numeric(df[col], errors='ignore')
                            except:
                                pass
                    
                    # 4. Remove outliers (for numeric columns)
                    for col in numeric_cols:
                        if col in df.columns:
                            Q1 = df[col].quantile(0.25)
                            Q3 = df[col].quantile(0.75)
                            IQR = Q3 - Q1
                            lower_bound = Q1 - 1.5 * IQR
                            upper_bound = Q3 + 1.5 * IQR
                            df = df[(df[col] >= lower_bound) & (df[col] <= upper_bound)]
                    
                    # Save cleaned data
                    base_name = file.replace('_raw.parquet', '').replace('.parquet', '')
                    output_file = os.path.join(output_dir, f"{base_name}_clean.parquet")
                    
                    df.to_parquet(output_file, index=False)
                    cleaned_files.append(output_file)
                    
                    cleaned_count = len(df)
                    print(f"✅ Cleaned {input_file}: {original_count} -> {cleaned_count} records")
        
        # Create cleaning metadata
        cleaning_metadata = {
            'cleaned_at': datetime.now().isoformat(),
            'input_directory': input_dir,
            'output_directory': output_dir,
            'files_cleaned': cleaned_files,
            'total_files': len(cleaned_files),
            'cleaning_operations': [
                'Remove duplicates',
                'Fill missing values',
                'Optimize data types',
                'Remove outliers'
            ]
        }
        
        metadata_file = os.path.join(output_dir, 'cleaning_metadata.json')
        with open(metadata_file, 'w') as f:
            json.dump(cleaning_metadata, f, indent=2)
        
        print(f"📊 Cleaning summary: {len(cleaned_files)} files cleaned")
        return cleaned_files
        
    except Exception as e:
        print(f"❌ Error cleaning data: {e}")
        return []

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Clean data in warehouse')
    parser.add_argument('--input', required=True, help='Input directory')
    parser.add_argument('--output', default='warehouse/clean', help='Output directory')
    
    args = parser.parse_args()
    clean_data(args.input, args.output)