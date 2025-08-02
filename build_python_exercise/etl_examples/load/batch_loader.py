#!/usr/bin/env python3
"""
Batch Loader - Load data in batches
"""

import pandas as pd
import json
import os
import sys
import argparse
from datetime import datetime

def batch_load(source_file, target_dir="warehouse/staging", batch_size=1000):
    """Load data in batches"""
    try:
        # Create target directory
        os.makedirs(target_dir, exist_ok=True)
        
        # Load source data
        if source_file.endswith('.json'):
            with open(source_file, 'r') as f:
                data = json.load(f)
            df = pd.DataFrame(data)
        elif source_file.endswith('.csv'):
            df = pd.read_csv(source_file)
        else:
            raise ValueError("Unsupported file format")
        
        # Split into batches
        total_rows = len(df)
        num_batches = (total_rows + batch_size - 1) // batch_size
        
        base_name = os.path.splitext(os.path.basename(source_file))[0]
        batch_files = []
        
        for i in range(num_batches):
            start_idx = i * batch_size
            end_idx = min((i + 1) * batch_size, total_rows)
            
            batch_df = df.iloc[start_idx:end_idx]
            batch_file = os.path.join(target_dir, f"{base_name}_batch_{i+1:03d}.parquet")
            
            batch_df.to_parquet(batch_file, index=False)
            batch_files.append(batch_file)
            
            print(f"✅ Batch {i+1}/{num_batches}: {len(batch_df)} records -> {batch_file}")
        
        # Create batch metadata
        batch_metadata = {
            'source_file': source_file,
            'loaded_at': datetime.now().isoformat(),
            'total_rows': total_rows,
            'batch_size': batch_size,
            'num_batches': num_batches,
            'batch_files': batch_files
        }
        
        metadata_file = os.path.join(target_dir, f"{base_name}_batch_metadata.json")
        with open(metadata_file, 'w') as f:
            json.dump(batch_metadata, f, indent=2)
        
        print(f"📊 Batch load complete: {total_rows} records in {num_batches} batches")
        return batch_files
        
    except Exception as e:
        print(f"❌ Error in batch loading: {e}")
        return []

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Load data in batches')
    parser.add_argument('--source', required=True, help='Source file')
    parser.add_argument('--target', default='warehouse/staging', help='Target directory')
    parser.add_argument('--batch-size', type=int, default=1000, help='Batch size')
    
    args = parser.parse_args()
    batch_load(args.source, args.target, args.batch_size)