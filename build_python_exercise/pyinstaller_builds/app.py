#!/usr/bin/env python3
"""
PyInstaller demo application
Creates standalone executables from Python code
"""

import sys
import os
import platform
import argparse
from pathlib import Path

def get_system_info():
    """Get system information"""
    return {
        "platform": platform.platform(),
        "python_version": platform.python_version(),
        "architecture": platform.architecture()[0],
        "processor": platform.processor(),
        "hostname": platform.node(),
    }

def main():
    """Main application entry point"""
    parser = argparse.ArgumentParser(
        description="PyInstaller Demo Application",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --info          Show system information
  %(prog)s --version       Show version
  %(prog)s --test          Run self-test
        """
    )
    
    parser.add_argument(
        "--info", 
        action="store_true",
        help="Show system information"
    )
    
    parser.add_argument(
        "--version", 
        action="store_true",
        help="Show version information"
    )
    
    parser.add_argument(
        "--test", 
        action="store_true",
        help="Run self-test"
    )
    
    args = parser.parse_args()
    
    if args.version:
        print("PyInstaller Demo v1.0.0")
        print(f"Python {platform.python_version()}")
        return 0
    
    if args.info:
        print("System Information:")
        print("-" * 40)
        info = get_system_info()
        for key, value in info.items():
            print(f"{key.replace('_', ' ').title()}: {value}")
        return 0
    
    if args.test:
        print("Running self-test...")
        
        # Test file operations
        try:
            test_file = Path("test_file.txt")
            test_file.write_text("Hello, PyInstaller!")
            content = test_file.read_text()
            test_file.unlink()
            print("✓ File operations: OK")
        except Exception as e:
            print(f"✗ File operations: FAILED ({e})")
            return 1
        
        # Test imports
        try:
            import json
            import urllib.request
            print("✓ Standard library imports: OK")
        except ImportError as e:
            print(f"✗ Standard library imports: FAILED ({e})")
            return 1
        
        print("✓ All tests passed!")
        return 0
    
    # Default behavior
    print("PyInstaller Demo Application")
    print("Use --help for available options")
    return 0

if __name__ == "__main__":
    sys.exit(main())