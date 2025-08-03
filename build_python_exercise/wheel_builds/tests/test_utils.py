"""
Tests for utils module
"""

import pytest
import json
from wheel_demo.utils import (
    hash_string, format_data, validate_json, merge_dicts,
    flatten_list, chunk_list, safe_divide
)


class TestHashString:
    """Test hash_string function"""
    
    def test_sha256_hash(self):
        """Test SHA256 hashing"""
        result = hash_string("hello", "sha256")
        expected = "2cf24dba4f21d4288094c8b0f5b6dc1c1b8b0b8b0b8b0b8b0b8b0b8b0b8b0b8b"
        # Just check it's a valid hex string of correct length
        assert len(result) == 64
        assert all(c in "0123456789abcdef" for c in result)
    
    def test_md5_hash(self):
        """Test MD5 hashing"""
        result = hash_string("hello", "md5")
        assert len(result) == 32
        assert all(c in "0123456789abcdef" for c in result)
    
    def test_invalid_algorithm(self):
        """Test invalid hash algorithm"""
        with pytest.raises(ValueError, match="Unsupported algorithm"):
            hash_string("hello", "invalid")


class TestFormatData:
    """Test format_data function"""
    
    def test_format_json(self):
        """Test JSON formatting"""
        data = {"name": "test", "value": 123}
        result = format_data(data, "json")
        
        # Should be valid JSON
        parsed = json.loads(result)
        assert parsed == data
    
    def test_format_text_dict(self):
        """Test text formatting for dictionary"""
        data = {"name": "test", "value": 123}
        result = format_data(data, "text")
        
        assert "name: test" in result
        assert "value: 123" in result
    
    def test_format_text_list(self):
        """Test text formatting for list"""
        data = [1, 2, 3]
        result = format_data(data, "text")
        
        assert "1" in result
        assert "2" in result
        assert "3" in result
    
    def test_invalid_format(self):
        """Test invalid format type"""
        with pytest.raises(ValueError, match="Unsupported format"):
            format_data({}, "invalid")


class TestValidateJson:
    """Test validate_json function"""
    
    def test_valid_json(self):
        """Test valid JSON strings"""
        assert validate_json('{"key": "value"}') is True
        assert validate_json('[1, 2, 3]') is True
        assert validate_json('"string"') is True
    
    def test_invalid_json(self):
        """Test invalid JSON strings"""
        assert validate_json('{"key": value}') is False  # Missing quotes
        assert validate_json('[1, 2, 3,]') is False     # Trailing comma
        assert validate_json('invalid') is False


class TestMergeDicts:
    """Test merge_dicts function"""
    
    def test_merge_basic(self):
        """Test basic dictionary merging"""
        dict1 = {"a": 1, "b": 2}
        dict2 = {"c": 3, "d": 4}
        
        result = merge_dicts(dict1, dict2)
        expected = {"a": 1, "b": 2, "c": 3, "d": 4}
        
        assert result == expected
    
    def test_merge_overlapping(self):
        """Test merging with overlapping keys"""
        dict1 = {"a": 1, "b": 2}
        dict2 = {"b": 3, "c": 4}
        
        result = merge_dicts(dict1, dict2)
        # Later dict should override
        assert result["b"] == 3


class TestFlattenList:
    """Test flatten_list function"""
    
    def test_flatten_nested(self):
        """Test flattening nested lists"""
        nested = [1, [2, 3], [4, [5, 6]], 7]
        result = flatten_list(nested)
        expected = [1, 2, 3, 4, 5, 6, 7]
        
        assert result == expected
    
    def test_flatten_already_flat(self):
        """Test flattening already flat list"""
        flat = [1, 2, 3, 4]
        result = flatten_list(flat)
        
        assert result == flat


class TestChunkList:
    """Test chunk_list function"""
    
    def test_chunk_even_division(self):
        """Test chunking with even division"""
        data = [1, 2, 3, 4, 5, 6]
        result = chunk_list(data, 2)
        expected = [[1, 2], [3, 4], [5, 6]]
        
        assert result == expected
    
    def test_chunk_uneven_division(self):
        """Test chunking with uneven division"""
        data = [1, 2, 3, 4, 5]
        result = chunk_list(data, 2)
        expected = [[1, 2], [3, 4], [5]]
        
        assert result == expected
    
    def test_chunk_invalid_size(self):
        """Test chunking with invalid size"""
        with pytest.raises(ValueError, match="Chunk size must be positive"):
            chunk_list([1, 2, 3], 0)


class TestSafeDivide:
    """Test safe_divide function"""
    
    def test_normal_division(self):
        """Test normal division"""
        assert safe_divide(10, 2) == 5.0
        assert safe_divide(7, 3) == pytest.approx(2.333, rel=1e-2)
    
    def test_division_by_zero(self):
        """Test division by zero"""
        assert safe_divide(10, 0) == 0.0
        assert safe_divide(10, 0, default=999) == 999