#!/usr/bin/env python3
"""
Aggregator - Aggregate and summarize data
"""

import pandas as pd
import json
import os
import sys
import argparse
from datetime import datetime

def aggregate_data(input_dir, output_dir="warehouse/aggregated"):
    """Aggregate data in warehouse"""
    try:
        # Create output directory
        os.makedirs(output_dir, exist_ok=True)
        
        aggregated_files = []
        
        # Process all Parquet files in input directory
        for root, dirs, files in os.walk(input_dir):
            for file in files:
                if file.endswith('_clean.parquet'):
                    input_file = os.path.join(root, file)
                    
                    # Load cleaned data
                    df = pd.read_parquet(input_file)
                    
                    # Perform aggregations based on data structure
                    base_name = file.replace('_clean.parquet', '')
                    
                    # Generic aggregations
                    aggregations = {}
                    
                    # Numeric column aggregations
                    numeric_cols = df.select_dtypes(include=['number']).columns
                    if len(numeric_cols) > 0:
                        numeric_agg = df[numeric_cols].agg(['count', 'mean', 'median', 'std', 'min', 'max'])
                        aggregations['numeric_summary'] = numeric_agg.to_dict()
                    
                    # Categorical column aggregations
                    categorical_cols = df.select_dtypes(include=['object']).columns
                    if len(categorical_cols) > 0:
                        categorical_agg = {}
                        for col in categorical_cols:
                            categorical_agg[col] = {
                                'unique_count': df[col].nunique(),
                                'top_values': df[col].value_counts().head(5).to_dict(),
                                'null_count': df[col].isnull().sum()
                            }
                        aggregations['categorical_summary'] = categorical_agg
                    
                    # Group by aggregations (if suitable columns exist)
                    if len(categorical_cols) > 0 and len(numeric_cols) > 0:
                        group_col = categorical_cols[0]  # Use first categorical column
                        numeric_col = numeric_cols[0]    # Use first numeric column
                        
                        grouped_agg = df.groupby(group_col)[numeric_col].agg(['count', 'mean', 'sum']).reset_index()
                        
                        # Save grouped aggregation as separate file
                        group_file = os.path.join(output_dir, f"{base_name}_by_{group_col}.parquet")
                        grouped_agg.to_parquet(group_file, index=False)
                        aggregated_files.append(group_file)
                        
                        print(f"✅ Created grouped aggregation: {group_file}")
                    
                    # Save general aggregations as JSON
                    agg_file = os.path.join(output_dir, f"{base_name}_aggregations.json")
                    with open(agg_file, 'w') as f:
                        json.dump(aggregations, f, indent=2, default=str)
                    
                    aggregated_files.append(agg_file)
                    print(f"✅ Created aggregations for {input_file}")
        
        # Create aggregation metadata
        agg_metadata = {
            'aggregated_at': datetime.now().isoformat(),
            'input_directory': input_dir,
            'output_directory': output_dir,
            'files_created': aggregated_files,
            'total_files': len(aggregated_files),
            'aggregation_types': [
                'Numeric summaries (count, mean, median, std, min, max)',
                'Categorical summaries (unique count, top values, null count)',
                'Grouped aggregations'
            ]
        }
        
        metadata_file = os.path.join(output_dir, 'aggregation_metadata.json')
        with open(metadata_file, 'w') as f:
            json.dump(agg_metadata, f, indent=2)
        
        print(f"📊 Aggregation summary: {len(aggregated_files)} files created")
        return aggregated_files
        
    except Exception as e:
        print(f"❌ Error aggregating data: {e}")
        return []

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Aggregate data in warehouse')
    parser.add_argument('--input', required=True, help='Input directory')
    parser.add_argument('--output', default='warehouse/aggregated', help='Output directory')
    
    args = parser.parse_args()
    aggregate_data(args.input, args.output)