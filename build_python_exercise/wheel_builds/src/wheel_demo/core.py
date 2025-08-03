"""
Core functionality for wheel demo
"""

from typing import List, Dict, Any
import statistics


class WheelProcessor:
    """Main processor for wheel demo functionality"""
    
    def __init__(self):
        self.data = []
        self.processed = False
    
    def process_data(self, data: List[float]) -> Dict[str, Any]:
        """Process numerical data and return statistics"""
        if not data:
            raise ValueError("Data cannot be empty")
        
        self.data = data
        self.processed = True
        
        result = {
            "count": len(data),
            "sum": sum(data),
            "mean": statistics.mean(data),
            "median": statistics.median(data),
            "min": min(data),
            "max": max(data)
        }
        
        if len(data) > 1:
            result["stdev"] = statistics.stdev(data)
        else:
            result["stdev"] = 0.0
        
        return result
    
    def process_text(self, text: str) -> Dict[str, Any]:
        """Process text data and return analysis"""
        if not text:
            raise ValueError("Text cannot be empty")
        
        words = text.split()
        chars = len(text)
        chars_no_spaces = len(text.replace(" ", ""))
        
        return {
            "text": text,
            "length": chars,
            "length_no_spaces": chars_no_spaces,
            "word_count": len(words),
            "words": words,
            "unique_words": len(set(word.lower() for word in words))
        }
    
    def get_summary(self) -> str:
        """Get processing summary"""
        if not self.processed:
            return "No data processed yet"
        
        return f"Processed {len(self.data)} data points"


class DataValidator:
    """Validator for input data"""
    
    @staticmethod
    def validate_numbers(data: List[Any]) -> bool:
        """Validate that all items are numbers"""
        try:
            [float(x) for x in data]
            return True
        except (ValueError, TypeError):
            return False
    
    @staticmethod
    def validate_text(text: str) -> bool:
        """Validate text input"""
        return isinstance(text, str) and len(text.strip()) > 0
    
    @staticmethod
    def validate_range(value: float, min_val: float = None, max_val: float = None) -> bool:
        """Validate number is within range"""
        if min_val is not None and value < min_val:
            return False
        if max_val is not None and value > max_val:
            return False
        return True