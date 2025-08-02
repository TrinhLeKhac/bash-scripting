#!/usr/bin/env python3
"""
CSV Extractor - Extract data from CSV files
"""

import pandas as pd
import json
import os
import sys
from datetime import datetime

def extract_csv(file_path, output_dir="extracted/csv"):
    """Extract data from CSV file"""
    try:
        # Create output directory
        os.makedirs(output_dir, exist_ok=True)
        
        # Read CSV file
        df = pd.read_csv(file_path)
        
        # Extract metadata
        metadata = {
            'source_file': file_path,
            'extracted_at': datetime.now().isoformat(),
            'row_count': len(df),
            'columns': list(df.columns),
            'data_types': df.dtypes.astype(str).to_dict()
        }
        
        # Save extracted data
        base_name = os.path.splitext(os.path.basename(file_path))[0]
        output_file = os.path.join(output_dir, f"{base_name}_extracted.json")
        
        df.to_json(output_file, orient='records', indent=2)
        
        # Save metadata
        metadata_file = os.path.join(output_dir, f"{base_name}_metadata.json")
        with open(metadata_file, 'w') as f:
            json.dump(metadata, f, indent=2)
        
        print(f"✅ Extracted {len(df)} records from {file_path}")
        print(f"📁 Output: {output_file}")
        
        return output_file
        
    except Exception as e:
        print(f"❌ Error extracting {file_path}: {e}")
        return None

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python csv_extractor.py <csv_file>")
        sys.exit(1)
    
    csv_file = sys.argv[1]
    extract_csv(csv_file)