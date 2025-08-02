#!/usr/bin/env python3
"""
JSON Extractor - Extract data from JSON files
"""

import json
import os
import sys
from datetime import datetime

def extract_json(file_path, output_dir="extracted/json"):
    """Extract data from JSON file"""
    try:
        # Create output directory
        os.makedirs(output_dir, exist_ok=True)
        
        # Read JSON file
        with open(file_path, 'r') as f:
            data = json.load(f)
        
        # Extract metadata
        metadata = {
            'source_file': file_path,
            'extracted_at': datetime.now().isoformat(),
            'record_count': len(data) if isinstance(data, list) else 1,
            'data_type': type(data).__name__
        }
        
        # Save extracted data
        base_name = os.path.splitext(os.path.basename(file_path))[0]
        output_file = os.path.join(output_dir, f"{base_name}_extracted.json")
        
        with open(output_file, 'w') as f:
            json.dump(data, f, indent=2)
        
        # Save metadata
        metadata_file = os.path.join(output_dir, f"{base_name}_metadata.json")
        with open(metadata_file, 'w') as f:
            json.dump(metadata, f, indent=2)
        
        record_count = len(data) if isinstance(data, list) else 1
        print(f"✅ Extracted {record_count} records from {file_path}")
        print(f"📁 Output: {output_file}")
        
        return output_file
        
    except Exception as e:
        print(f"❌ Error extracting {file_path}: {e}")
        return None

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python json_extractor.py <json_file>")
        sys.exit(1)
    
    json_file = sys.argv[1]
    extract_json(json_file)