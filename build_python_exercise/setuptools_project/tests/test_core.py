"""
Tests for setuptools demo core functionality
"""

import pytest
from setuptools_demo.core import Calculator, DataProcessor


class TestCalculator:
    """Test Calculator class"""
    
    def setup_method(self):
        """Setup test fixtures"""
        self.calc = Calculator()
    
    def test_add(self):
        """Test addition"""
        assert self.calc.add(2, 3) == 5
        assert self.calc.add(-1, 1) == 0
        assert self.calc.add(0.1, 0.2) == pytest.approx(0.3)
    
    def test_subtract(self):
        """Test subtraction"""
        assert self.calc.subtract(5, 3) == 2
        assert self.calc.subtract(1, 1) == 0
        assert self.calc.subtract(-1, -1) == 0
    
    def test_multiply(self):
        """Test multiplication"""
        assert self.calc.multiply(3, 4) == 12
        assert self.calc.multiply(-2, 3) == -6
        assert self.calc.multiply(0, 100) == 0
    
    def test_divide(self):
        """Test division"""
        assert self.calc.divide(10, 2) == 5
        assert self.calc.divide(7, 2) == 3.5
        
        with pytest.raises(ValueError, match="Cannot divide by zero"):
            self.calc.divide(5, 0)


class TestDataProcessor:
    """Test DataProcessor class"""
    
    def setup_method(self):
        """Setup test fixtures"""
        self.processor = DataProcessor()
    
    def test_load_data(self):
        """Test data loading"""
        data = [1, 2, 3, 4, 5]
        self.processor.load_data(data)
        assert self.processor.data == data
    
    def test_calculate_mean(self):
        """Test mean calculation"""
        self.processor.load_data([1, 2, 3, 4, 5])
        assert self.processor.calculate_mean() == 3.0
        
        self.processor.load_data([10, 20, 30])
        assert self.processor.calculate_mean() == 20.0
        
        # Test empty data
        self.processor.load_data([])
        with pytest.raises(ValueError, match="No data loaded"):
            self.processor.calculate_mean()
    
    def test_calculate_median(self):
        """Test median calculation"""
        # Odd number of elements
        self.processor.load_data([1, 2, 3, 4, 5])
        assert self.processor.calculate_median() == 3.0
        
        # Even number of elements
        self.processor.load_data([1, 2, 3, 4])
        assert self.processor.calculate_median() == 2.5
        
        # Single element
        self.processor.load_data([42])
        assert self.processor.calculate_median() == 42
        
        # Test empty data
        self.processor.load_data([])
        with pytest.raises(ValueError, match="No data loaded"):
            self.processor.calculate_median()
    
    def test_to_json(self):
        """Test JSON export"""
        import json
        
        self.processor.load_data([1, 2, 3])
        json_output = self.processor.to_json()
        data = json.loads(json_output)
        
        assert data["data"] == [1, 2, 3]
        assert data["count"] == 3
        assert data["mean"] == 2.0
        assert data["median"] == 2.0