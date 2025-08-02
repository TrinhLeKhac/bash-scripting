#!/usr/bin/env python3
"""
Warehouse Loader - Load data into data warehouse
"""

import pandas as pd
import json
import os
import sys
import argparse
from datetime import datetime

def load_to_warehouse(source_dir, target_dir="warehouse/raw"):
    """Load extracted data to warehouse"""
    try:
        # Create target directory
        os.makedirs(target_dir, exist_ok=True)
        
        loaded_files = []
        
        # Process all JSON files in source directory
        for root, dirs, files in os.walk(source_dir):
            for file in files:
                if file.endswith('_extracted.json'):
                    source_file = os.path.join(root, file)
                    
                    # Load JSON data
                    with open(source_file, 'r') as f:
                        data = json.load(f)
                    
                    # Convert to DataFrame
                    if isinstance(data, list):
                        df = pd.DataFrame(data)
                    else:
                        df = pd.DataFrame([data])
                    
                    # Save as Parquet in warehouse
                    base_name = file.replace('_extracted.json', '')
                    target_file = os.path.join(target_dir, f"{base_name}_raw.parquet")
                    
                    df.to_parquet(target_file, index=False)
                    loaded_files.append(target_file)
                    
                    print(f"✅ Loaded {len(df)} records to {target_file}")
        
        # Create load metadata
        load_metadata = {
            'loaded_at': datetime.now().isoformat(),
            'source_directory': source_dir,
            'target_directory': target_dir,
            'files_loaded': loaded_files,
            'total_files': len(loaded_files)
        }
        
        metadata_file = os.path.join(target_dir, 'load_metadata.json')
        with open(metadata_file, 'w') as f:
            json.dump(load_metadata, f, indent=2)
        
        print(f"📊 Load summary: {len(loaded_files)} files loaded to warehouse")
        return loaded_files
        
    except Exception as e:
        print(f"❌ Error loading to warehouse: {e}")
        return []

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Load data to warehouse')
    parser.add_argument('--source', required=True, help='Source directory')
    parser.add_argument('--target', default='warehouse/raw', help='Target directory')
    
    args = parser.parse_args()
    load_to_warehouse(args.source, args.target)