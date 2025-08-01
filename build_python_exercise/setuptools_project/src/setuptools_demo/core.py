"""
Core functionality for setuptools demo
"""

from typing import List, Union
import json


class Calculator:
    """Simple calculator class demonstrating setuptools packaging"""
    
    def add(self, a: float, b: float) -> float:
        """Add two numbers"""
        return a + b
    
    def subtract(self, a: float, b: float) -> float:
        """Subtract two numbers"""
        return a - b
    
    def multiply(self, a: float, b: float) -> float:
        """Multiply two numbers"""
        return a * b
    
    def divide(self, a: float, b: float) -> float:
        """Divide two numbers"""
        if b == 0:
            raise ValueError("Cannot divide by zero")
        return a / b


class DataProcessor:
    """Data processing utilities"""
    
    def __init__(self):
        self.data = []
    
    def load_data(self, data: List[Union[int, float]]) -> None:
        """Load data for processing"""
        self.data = data
    
    def calculate_mean(self) -> float:
        """Calculate mean of loaded data"""
        if not self.data:
            raise ValueError("No data loaded")
        return sum(self.data) / len(self.data)
    
    def calculate_median(self) -> float:
        """Calculate median of loaded data"""
        if not self.data:
            raise ValueError("No data loaded")
        sorted_data = sorted(self.data)
        n = len(sorted_data)
        if n % 2 == 0:
            return (sorted_data[n//2 - 1] + sorted_data[n//2]) / 2
        return sorted_data[n//2]
    
    def to_json(self) -> str:
        """Export data as JSON"""
        return json.dumps({
            "data": self.data,
            "count": len(self.data),
            "mean": self.calculate_mean() if self.data else None,
            "median": self.calculate_median() if self.data else None
        })