"""
Wheel-specific tools and utilities
"""

import os
import zipfile
from typing import Dict, List, Optional
import json


class WheelValidator:
    """Validator for Python wheel files"""
    
    def __init__(self):
        self.required_files = [
            "METADATA",
            "WHEEL", 
            "RECORD"
        ]
    
    def validate_wheel_file(self, wheel_path: str) -> bool:
        """Validate a wheel file structure"""
        if not os.path.exists(wheel_path):
            return False
        
        if not wheel_path.endswith('.whl'):
            return False
        
        try:
            with zipfile.ZipFile(wheel_path, 'r') as wheel_zip:
                file_list = wheel_zip.namelist()
                
                # Check for required metadata files
                metadata_files = [f for f in file_list if any(req in f for req in self.required_files)]
                
                return len(metadata_files) >= len(self.required_files)
        except zipfile.BadZipFile:
            return False
    
    def get_wheel_info(self, wheel_path: str) -> Dict[str, str]:
        """Extract information from wheel file"""
        if not self.validate_wheel_file(wheel_path):
            return {"error": "Invalid wheel file"}
        
        info = {
            "filename": os.path.basename(wheel_path),
            "size": str(os.path.getsize(wheel_path)),
            "valid": "True"
        }
        
        try:
            with zipfile.ZipFile(wheel_path, 'r') as wheel_zip:
                # Try to read WHEEL metadata
                wheel_files = [f for f in wheel_zip.namelist() if f.endswith('WHEEL')]
                if wheel_files:
                    wheel_content = wheel_zip.read(wheel_files[0]).decode('utf-8')
                    for line in wheel_content.split('\n'):
                        if ':' in line:
                            key, value = line.split(':', 1)
                            info[key.strip().lower()] = value.strip()
        except Exception as e:
            info["error"] = str(e)
        
        return info
    
    def list_wheel_contents(self, wheel_path: str) -> List[str]:
        """List contents of wheel file"""
        if not self.validate_wheel_file(wheel_path):
            return []
        
        try:
            with zipfile.ZipFile(wheel_path, 'r') as wheel_zip:
                return wheel_zip.namelist()
        except zipfile.BadZipFile:
            return []


class WheelBuilder:
    """Helper for wheel building operations"""
    
    @staticmethod
    def check_build_requirements() -> Dict[str, bool]:
        """Check if build requirements are met"""
        requirements = {}
        
        try:
            import build
            requirements["build"] = True
        except ImportError:
            requirements["build"] = False
        
        try:
            import wheel
            requirements["wheel"] = True
        except ImportError:
            requirements["wheel"] = False
        
        try:
            import setuptools
            requirements["setuptools"] = True
        except ImportError:
            requirements["setuptools"] = False
        
        return requirements
    
    @staticmethod
    def get_wheel_tags() -> Dict[str, str]:
        """Get wheel tags for current platform"""
        try:
            from wheel.bdist_wheel import get_platform
            import sys
            
            return {
                "python_tag": f"py{sys.version_info.major}",
                "abi_tag": "none",
                "platform_tag": get_platform(None)
            }
        except ImportError:
            return {
                "python_tag": "py3",
                "abi_tag": "none", 
                "platform_tag": "any"
            }


class WheelAnalyzer:
    """Analyzer for wheel files and metadata"""
    
    def __init__(self):
        self.validator = WheelValidator()
    
    def analyze_wheel(self, wheel_path: str) -> Dict[str, any]:
        """Comprehensive wheel analysis"""
        analysis = {
            "file_path": wheel_path,
            "exists": os.path.exists(wheel_path),
            "valid": False,
            "info": {},
            "contents": [],
            "size_bytes": 0
        }
        
        if not analysis["exists"]:
            return analysis
        
        analysis["size_bytes"] = os.path.getsize(wheel_path)
        analysis["valid"] = self.validator.validate_wheel_file(wheel_path)
        
        if analysis["valid"]:
            analysis["info"] = self.validator.get_wheel_info(wheel_path)
            analysis["contents"] = self.validator.list_wheel_contents(wheel_path)
            analysis["content_count"] = len(analysis["contents"])
        
        return analysis