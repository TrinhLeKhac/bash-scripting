"""
Tests for core module
"""

import pytest
from wheel_demo.core import WheelProcessor, DataValidator


class TestWheelProcessor:
    """Test WheelProcessor class"""
    
    def test_process_data_basic(self):
        """Test basic data processing"""
        processor = WheelProcessor()
        data = [1, 2, 3, 4, 5]
        
        result = processor.process_data(data)
        
        assert result["count"] == 5
        assert result["sum"] == 15
        assert result["mean"] == 3.0
        assert result["median"] == 3.0
        assert result["min"] == 1
        assert result["max"] == 5
        assert processor.processed is True
    
    def test_process_data_empty(self):
        """Test processing empty data"""
        processor = WheelProcessor()
        
        with pytest.raises(ValueError, match="Data cannot be empty"):
            processor.process_data([])
    
    def test_process_text_basic(self):
        """Test basic text processing"""
        processor = WheelProcessor()
        text = "Hello world test"
        
        result = processor.process_text(text)
        
        assert result["text"] == text
        assert result["length"] == 16
        assert result["length_no_spaces"] == 14
        assert result["word_count"] == 3
        assert result["words"] == ["Hello", "world", "test"]
        assert result["unique_words"] == 3
    
    def test_process_text_empty(self):
        """Test processing empty text"""
        processor = WheelProcessor()
        
        with pytest.raises(ValueError, match="Text cannot be empty"):
            processor.process_text("")
    
    def test_get_summary(self):
        """Test summary generation"""
        processor = WheelProcessor()
        
        # Before processing
        assert processor.get_summary() == "No data processed yet"
        
        # After processing
        processor.process_data([1, 2, 3])
        assert processor.get_summary() == "Processed 3 data points"


class TestDataValidator:
    """Test DataValidator class"""
    
    def test_validate_numbers_valid(self):
        """Test validating valid numbers"""
        assert DataValidator.validate_numbers([1, 2, 3, 4.5]) is True
        assert DataValidator.validate_numbers(["1", "2", "3.5"]) is True
    
    def test_validate_numbers_invalid(self):
        """Test validating invalid numbers"""
        assert DataValidator.validate_numbers(["a", "b", "c"]) is False
        assert DataValidator.validate_numbers([1, 2, "invalid"]) is False
    
    def test_validate_text_valid(self):
        """Test validating valid text"""
        assert DataValidator.validate_text("Hello world") is True
        assert DataValidator.validate_text("   test   ") is True
    
    def test_validate_text_invalid(self):
        """Test validating invalid text"""
        assert DataValidator.validate_text("") is False
        assert DataValidator.validate_text("   ") is False
        assert DataValidator.validate_text(123) is False
    
    def test_validate_range(self):
        """Test range validation"""
        assert DataValidator.validate_range(5.0, 0.0, 10.0) is True
        assert DataValidator.validate_range(5.0, 10.0, 20.0) is False
        assert DataValidator.validate_range(5.0, min_val=0.0) is True
        assert DataValidator.validate_range(5.0, max_val=10.0) is True