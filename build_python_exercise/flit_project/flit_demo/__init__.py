"""
Flit Demo Package
A lightweight demonstration of Flit packaging
"""

__version__ = "1.0.0"
__author__ = "Demo Author"

# Import main function from main module
from .main import main

# Make main available at package level
__all__ = ['main', '__version__', '__author__']