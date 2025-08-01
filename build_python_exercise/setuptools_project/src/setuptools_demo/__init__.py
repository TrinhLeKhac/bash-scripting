"""
Setuptools Demo Package
Traditional Python packaging example
"""

__version__ = "1.0.0"
__author__ = "Demo Author"
__email__ = "demo@example.com"

from .core import Calculator, DataProcessor
from .utils import format_output, validate_input

__all__ = [
    "Calculator", 
    "DataProcessor", 
    "format_output", 
    "validate_input"
]