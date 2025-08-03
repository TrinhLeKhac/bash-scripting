"""
Utility functions for wheel demo
"""

import hashlib
import json
from typing import Any, Dict, List


def hash_string(text: str, algorithm: str = "sha256") -> str:
    """Generate hash of a string"""
    if algorithm not in ["md5", "sha1", "sha256", "sha512"]:
        raise ValueError(f"Unsupported algorithm: {algorithm}")
    
    hash_func = getattr(hashlib, algorithm)
    return hash_func(text.encode()).hexdigest()


def format_data(data: Any, format_type: str = "json") -> str:
    """Format data for output"""
    if format_type == "json":
        return json.dumps(data, indent=2, default=str)
    elif format_type == "text":
        if isinstance(data, dict):
            return "\n".join(f"{k}: {v}" for k, v in data.items())
        elif isinstance(data, list):
            return "\n".join(str(item) for item in data)
        else:
            return str(data)
    else:
        raise ValueError(f"Unsupported format: {format_type}")


def calculate_file_hash(filepath: str, algorithm: str = "sha256") -> str:
    """Calculate hash of a file"""
    hash_func = getattr(hashlib, algorithm)
    
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_func.update(chunk)
    
    return hash_func.hexdigest()


def validate_json(text: str) -> bool:
    """Validate if text is valid JSON"""
    try:
        json.loads(text)
        return True
    except json.JSONDecodeError:
        return False


def merge_dicts(*dicts: Dict[str, Any]) -> Dict[str, Any]:
    """Merge multiple dictionaries"""
    result = {}
    for d in dicts:
        result.update(d)
    return result


def flatten_list(nested_list: List[Any]) -> List[Any]:
    """Flatten a nested list"""
    result = []
    for item in nested_list:
        if isinstance(item, list):
            result.extend(flatten_list(item))
        else:
            result.append(item)
    return result


def chunk_list(data: List[Any], chunk_size: int) -> List[List[Any]]:
    """Split list into chunks of specified size"""
    if chunk_size <= 0:
        raise ValueError("Chunk size must be positive")
    
    return [data[i:i + chunk_size] for i in range(0, len(data), chunk_size)]


def safe_divide(a: float, b: float, default: float = 0.0) -> float:
    """Safely divide two numbers"""
    try:
        return a / b
    except ZeroDivisionError:
        return default