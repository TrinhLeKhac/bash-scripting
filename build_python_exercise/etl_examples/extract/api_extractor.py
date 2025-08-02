#!/usr/bin/env python3
"""
API Extractor - Extract data from REST APIs
"""

import requests
import json
import os
import sys
import argparse
from datetime import datetime

def extract_api(endpoint, output_dir="extracted/api", headers=None):
    """Extract data from API endpoint"""
    try:
        # Create output directory
        os.makedirs(output_dir, exist_ok=True)
        
        # Make API request
        response = requests.get(endpoint, headers=headers or {})
        response.raise_for_status()
        
        data = response.json()
        
        # Extract metadata
        metadata = {
            'endpoint': endpoint,
            'extracted_at': datetime.now().isoformat(),
            'status_code': response.status_code,
            'record_count': len(data) if isinstance(data, list) else 1,
            'headers': dict(response.headers)
        }
        
        # Save extracted data
        endpoint_name = endpoint.split('/')[-1] or 'api_data'
        output_file = os.path.join(output_dir, f"{endpoint_name}_extracted.json")
        
        with open(output_file, 'w') as f:
            json.dump(data, f, indent=2)
        
        # Save metadata
        metadata_file = os.path.join(output_dir, f"{endpoint_name}_metadata.json")
        with open(metadata_file, 'w') as f:
            json.dump(metadata, f, indent=2)
        
        record_count = len(data) if isinstance(data, list) else 1
        print(f"✅ Extracted {record_count} records from {endpoint}")
        print(f"📁 Output: {output_file}")
        
        return output_file
        
    except Exception as e:
        print(f"❌ Error extracting from {endpoint}: {e}")
        return None

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Extract data from API')
    parser.add_argument('--endpoint', required=True, help='API endpoint URL')
    parser.add_argument('--output', default='extracted/api', help='Output directory')
    
    args = parser.parse_args()
    extract_api(args.endpoint, args.output)