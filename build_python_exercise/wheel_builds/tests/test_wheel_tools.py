"""
Tests for wheel_tools module
"""

import pytest
import tempfile
import zipfile
import os
from wheel_demo.wheel_tools import WheelValidator, WheelBuilder, WheelAnalyzer


class TestWheelValidator:
    """Test WheelValidator class"""
    
    def test_validate_nonexistent_file(self):
        """Test validating non-existent file"""
        validator = WheelValidator()
        assert validator.validate_wheel_file("nonexistent.whl") is False
    
    def test_validate_non_wheel_file(self):
        """Test validating non-wheel file"""
        validator = WheelValidator()
        
        with tempfile.NamedTemporaryFile(suffix=".txt", delete=False) as tmp:
            tmp.write(b"not a wheel")
            tmp_path = tmp.name
        
        try:
            assert validator.validate_wheel_file(tmp_path) is False
        finally:
            os.unlink(tmp_path)
    
    def test_validate_mock_wheel_file(self):
        """Test validating a mock wheel file"""
        validator = WheelValidator()
        
        with tempfile.NamedTemporaryFile(suffix=".whl", delete=False) as tmp:
            tmp_path = tmp.name
        
        try:
            # Create a mock wheel with required files
            with zipfile.ZipFile(tmp_path, 'w') as zf:
                zf.writestr("test_package-1.0.0.dist-info/METADATA", "Name: test-package\nVersion: 1.0.0")
                zf.writestr("test_package-1.0.0.dist-info/WHEEL", "Wheel-Version: 1.0")
                zf.writestr("test_package-1.0.0.dist-info/RECORD", "")
            
            assert validator.validate_wheel_file(tmp_path) is True
        finally:
            os.unlink(tmp_path)
    
    def test_get_wheel_info_invalid(self):
        """Test getting info from invalid wheel"""
        validator = WheelValidator()
        result = validator.get_wheel_info("nonexistent.whl")
        
        assert "error" in result
        assert result["error"] == "Invalid wheel file"
    
    def test_list_wheel_contents_invalid(self):
        """Test listing contents of invalid wheel"""
        validator = WheelValidator()
        result = validator.list_wheel_contents("nonexistent.whl")
        
        assert result == []


class TestWheelBuilder:
    """Test WheelBuilder class"""
    
    def test_check_build_requirements(self):
        """Test checking build requirements"""
        requirements = WheelBuilder.check_build_requirements()
        
        # Should return a dict with boolean values
        assert isinstance(requirements, dict)
        assert "build" in requirements
        assert "wheel" in requirements
        assert "setuptools" in requirements
        
        for req, available in requirements.items():
            assert isinstance(available, bool)
    
    def test_get_wheel_tags(self):
        """Test getting wheel tags"""
        tags = WheelBuilder.get_wheel_tags()
        
        assert isinstance(tags, dict)
        assert "python_tag" in tags
        assert "abi_tag" in tags
        assert "platform_tag" in tags
        
        # Python tag should start with 'py'
        assert tags["python_tag"].startswith("py")
        # ABI tag should be 'none' for pure Python
        assert tags["abi_tag"] == "none"


class TestWheelAnalyzer:
    """Test WheelAnalyzer class"""
    
    def test_analyze_nonexistent_wheel(self):
        """Test analyzing non-existent wheel"""
        analyzer = WheelAnalyzer()
        result = analyzer.analyze_wheel("nonexistent.whl")
        
        assert result["file_path"] == "nonexistent.whl"
        assert result["exists"] is False
        assert result["valid"] is False
        assert result["size_bytes"] == 0
    
    def test_analyze_mock_wheel(self):
        """Test analyzing a mock wheel file"""
        analyzer = WheelAnalyzer()
        
        with tempfile.NamedTemporaryFile(suffix=".whl", delete=False) as tmp:
            tmp_path = tmp.name
        
        try:
            # Create a mock wheel
            with zipfile.ZipFile(tmp_path, 'w') as zf:
                zf.writestr("test_package-1.0.0.dist-info/METADATA", "Name: test-package\nVersion: 1.0.0")
                zf.writestr("test_package-1.0.0.dist-info/WHEEL", "Wheel-Version: 1.0\nGenerator: test")
                zf.writestr("test_package-1.0.0.dist-info/RECORD", "")
                zf.writestr("test_package/__init__.py", "# Test package")
            
            result = analyzer.analyze_wheel(tmp_path)
            
            assert result["exists"] is True
            assert result["valid"] is True
            assert result["size_bytes"] > 0
            assert result["content_count"] > 0
            assert len(result["contents"]) > 0
            
        finally:
            os.unlink(tmp_path)


class TestWheelIntegration:
    """Integration tests for wheel tools"""
    
    def test_complete_wheel_workflow(self):
        """Test complete wheel validation workflow"""
        validator = WheelValidator()
        builder = WheelBuilder()
        analyzer = WheelAnalyzer()
        
        # Check build requirements
        requirements = builder.check_build_requirements()
        assert isinstance(requirements, dict)
        
        # Get wheel tags
        tags = builder.get_wheel_tags()
        assert isinstance(tags, dict)
        
        # Test with non-existent file
        assert validator.validate_wheel_file("fake.whl") is False
        
        analysis = analyzer.analyze_wheel("fake.whl")
        assert analysis["exists"] is False
        assert analysis["valid"] is False