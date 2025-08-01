"""
Advanced data processing module
Demonstrates various data manipulation techniques
"""

import json
import csv
import statistics
from typing import List, Dict, Any, Optional
from pathlib import Path


class DataProcessor:
    """Advanced data processing utilities"""
    
    def __init__(self):
        self.data = []
        self.metadata = {}
    
    def load_csv(self, file_path: str, delimiter: str = ',') -> None:
        """Load data from CSV file"""
        with open(file_path, 'r', encoding='utf-8') as file:
            reader = csv.DictReader(file, delimiter=delimiter)
            self.data = list(reader)
            self.metadata['source'] = file_path
            self.metadata['rows'] = len(self.data)
            self.metadata['columns'] = list(self.data[0].keys()) if self.data else []
    
    def load_json(self, file_path: str) -> None:
        """Load data from JSON file"""
        with open(file_path, 'r', encoding='utf-8') as file:
            self.data = json.load(file)
            self.metadata['source'] = file_path
            self.metadata['type'] = 'json'
    
    def filter_data(self, condition: Dict[str, Any]) -> List[Dict]:
        """Filter data based on conditions"""
        filtered = []
        for row in self.data:
            match = True
            for key, value in condition.items():
                if key not in row or str(row[key]) != str(value):
                    match = False
                    break
            if match:
                filtered.append(row)
        return filtered
    
    def group_by(self, column: str) -> Dict[str, List[Dict]]:
        """Group data by column value"""
        groups = {}
        for row in self.data:
            key = row.get(column, 'Unknown')
            if key not in groups:
                groups[key] = []
            groups[key].append(row)
        return groups
    
    def aggregate(self, group_column: str, agg_column: str, operation: str = 'sum') -> Dict[str, float]:
        """Aggregate data by group"""
        groups = self.group_by(group_column)
        results = {}
        
        for group, rows in groups.items():
            values = []
            for row in rows:
                try:
                    values.append(float(row[agg_column]))
                except (ValueError, KeyError):
                    continue
            
            if values:
                if operation == 'sum':
                    results[group] = sum(values)
                elif operation == 'avg':
                    results[group] = statistics.mean(values)
                elif operation == 'count':
                    results[group] = len(values)
                elif operation == 'max':
                    results[group] = max(values)
                elif operation == 'min':
                    results[group] = min(values)
        
        return results
    
    def get_statistics(self, column: str) -> Dict[str, float]:
        """Get statistical summary of numeric column"""
        values = []
        for row in self.data:
            try:
                values.append(float(row[column]))
            except (ValueError, KeyError):
                continue
        
        if not values:
            return {}
        
        return {
            'count': len(values),
            'mean': statistics.mean(values),
            'median': statistics.median(values),
            'std_dev': statistics.stdev(values) if len(values) > 1 else 0,
            'min': min(values),
            'max': max(values),
            'sum': sum(values)
        }
    
    def export_csv(self, file_path: str, data: Optional[List[Dict]] = None) -> None:
        """Export data to CSV file"""
        export_data = data or self.data
        if not export_data:
            return
        
        with open(file_path, 'w', newline='', encoding='utf-8') as file:
            writer = csv.DictWriter(file, fieldnames=export_data[0].keys())
            writer.writeheader()
            writer.writerows(export_data)
    
    def export_json(self, file_path: str, data: Optional[List[Dict]] = None) -> None:
        """Export data to JSON file"""
        export_data = data or self.data
        with open(file_path, 'w', encoding='utf-8') as file:
            json.dump(export_data, file, indent=2, ensure_ascii=False)
    
    def get_summary(self) -> Dict[str, Any]:
        """Get data summary"""
        return {
            'metadata': self.metadata,
            'row_count': len(self.data),
            'columns': list(self.data[0].keys()) if self.data else [],
            'sample_data': self.data[:3] if self.data else []
        }