"""
Utility functions for setuptools demo
"""

from typing import Any, Union
import re


def validate_input(value: Any, input_type: str = "number") -> bool:
    """Validate input based on type"""
    if input_type == "number":
        try:
            float(value)
            return True
        except (ValueError, TypeError):
            return False
    
    elif input_type == "email":
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return bool(re.match(pattern, str(value)))
    
    elif input_type == "positive":
        try:
            return float(value) > 0
        except (ValueError, TypeError):
            return False
    
    return False


def format_output(message: str, style: str = "info") -> str:
    """Format output message with style"""
    styles = {
        "info": f"ℹ️  {message}",
        "success": f"✅ {message}",
        "warning": f"⚠️  {message}",
        "error": f"❌ {message}",
        "debug": f"🐛 {message}"
    }
    
    return styles.get(style, message)


def safe_divide(a: Union[int, float], b: Union[int, float]) -> Union[float, None]:
    """Safely divide two numbers, returning None if division by zero"""
    if not validate_input(a, "number") or not validate_input(b, "number"):
        return None
    
    if b == 0:
        return None
    
    return float(a) / float(b)


def calculate_percentage(part: Union[int, float], whole: Union[int, float]) -> Union[float, None]:
    """Calculate percentage, handling edge cases"""
    if not validate_input(part, "number") or not validate_input(whole, "number"):
        return None
    
    if whole == 0:
        return None
    
    return (float(part) / float(whole)) * 100