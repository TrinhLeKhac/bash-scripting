"""
Tests for data processor module
"""

import pytest
import tempfile
import json
import csv
from pathlib import Path
from setuptools_demo.data_processor import DataProcessor


class TestDataProcessor:
    """Test DataProcessor class"""
    
    def setup_method(self):
        """Setup test fixtures"""
        self.processor = DataProcessor()
        
        # Create sample CSV data
        self.sample_csv_data = [
            {'name': 'Alice', 'age': '25', 'city': 'New York', 'salary': '50000'},
            {'name': 'Bob', 'age': '30', 'city': 'San Francisco', 'salary': '75000'},
            {'name': 'Charlie', 'age': '35', 'city': 'New York', 'salary': '60000'},
            {'name': 'Diana', 'age': '28', 'city': 'Chicago', 'salary': '55000'}
        ]
        
        # Create sample JSON data
        self.sample_json_data = [
            {'product': 'Laptop', 'category': 'Electronics', 'price': 1200, 'quantity': 5},
            {'product': 'Phone', 'category': 'Electronics', 'price': 800, 'quantity': 10},
            {'product': 'Book', 'category': 'Education', 'price': 25, 'quantity': 50},
            {'product': 'Desk', 'category': 'Furniture', 'price': 300, 'quantity': 3}
        ]
    
    def test_load_csv(self):
        """Test CSV loading"""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.csv', delete=False) as f:
            writer = csv.DictWriter(f, fieldnames=['name', 'age', 'city', 'salary'])
            writer.writeheader()
            writer.writerows(self.sample_csv_data)
            csv_file = f.name
        
        self.processor.load_csv(csv_file)
        
        assert len(self.processor.data) == 4
        assert self.processor.metadata['rows'] == 4
        assert 'name' in self.processor.metadata['columns']
        assert self.processor.data[0]['name'] == 'Alice'
        
        Path(csv_file).unlink()  # Cleanup
    
    def test_load_json(self):
        """Test JSON loading"""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
            json.dump(self.sample_json_data, f)
            json_file = f.name
        
        self.processor.load_json(json_file)
        
        assert len(self.processor.data) == 4
        assert self.processor.data[0]['product'] == 'Laptop'
        assert self.processor.metadata['type'] == 'json'
        
        Path(json_file).unlink()  # Cleanup
    
    def test_filter_data(self):
        """Test data filtering"""
        self.processor.data = self.sample_csv_data
        
        # Filter by city
        filtered = self.processor.filter_data({'city': 'New York'})
        assert len(filtered) == 2
        assert all(row['city'] == 'New York' for row in filtered)
        
        # Filter by age
        filtered = self.processor.filter_data({'age': '30'})
        assert len(filtered) == 1
        assert filtered[0]['name'] == 'Bob'
    
    def test_group_by(self):
        """Test grouping functionality"""
        self.processor.data = self.sample_csv_data
        
        groups = self.processor.group_by('city')
        
        assert len(groups) == 3  # New York, San Francisco, Chicago
        assert len(groups['New York']) == 2
        assert len(groups['San Francisco']) == 1
        assert len(groups['Chicago']) == 1
    
    def test_aggregate(self):
        """Test aggregation functions"""
        self.processor.data = self.sample_csv_data
        
        # Test sum aggregation
        salary_sum = self.processor.aggregate('city', 'salary', 'sum')
        assert salary_sum['New York'] == 110000  # 50000 + 60000
        assert salary_sum['San Francisco'] == 75000
        
        # Test average aggregation
        salary_avg = self.processor.aggregate('city', 'salary', 'avg')
        assert salary_avg['New York'] == 55000  # (50000 + 60000) / 2
        
        # Test count aggregation
        count = self.processor.aggregate('city', 'salary', 'count')
        assert count['New York'] == 2
        assert count['Chicago'] == 1
    
    def test_get_statistics(self):
        """Test statistical calculations"""
        self.processor.data = self.sample_csv_data
        
        stats = self.processor.get_statistics('salary')
        
        assert stats['count'] == 4
        assert stats['mean'] == 60000  # (50000 + 75000 + 60000 + 55000) / 4
        assert stats['min'] == 50000
        assert stats['max'] == 75000
        assert stats['sum'] == 240000
    
    def test_export_csv(self):
        """Test CSV export"""
        self.processor.data = self.sample_csv_data
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.csv', delete=False) as f:
            export_file = f.name
        
        self.processor.export_csv(export_file)
        
        # Verify exported data
        with open(export_file, 'r') as f:
            reader = csv.DictReader(f)
            exported_data = list(reader)
        
        assert len(exported_data) == 4
        assert exported_data[0]['name'] == 'Alice'
        
        Path(export_file).unlink()  # Cleanup
    
    def test_export_json(self):
        """Test JSON export"""
        self.processor.data = self.sample_json_data
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
            export_file = f.name
        
        self.processor.export_json(export_file)
        
        # Verify exported data
        with open(export_file, 'r') as f:
            exported_data = json.load(f)
        
        assert len(exported_data) == 4
        assert exported_data[0]['product'] == 'Laptop'
        
        Path(export_file).unlink()  # Cleanup
    
    def test_get_summary(self):
        """Test data summary"""
        self.processor.data = self.sample_csv_data
        self.processor.metadata = {'source': 'test.csv', 'rows': 4}
        
        summary = self.processor.get_summary()
        
        assert summary['row_count'] == 4
        assert 'name' in summary['columns']
        assert len(summary['sample_data']) == 3  # First 3 rows
        assert summary['metadata']['source'] == 'test.csv'