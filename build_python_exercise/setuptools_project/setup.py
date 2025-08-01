#!/usr/bin/env python3
"""
Traditional setuptools configuration
Classic Python packaging approach
"""

from setuptools import setup, find_packages
import os

# Read README for long description
def read_readme():
    with open("README.md", "r", encoding="utf-8") as fh:
        return fh.read()

# Read requirements
def read_requirements():
    with open("requirements.txt", "r") as f:
        return [line.strip() for line in f if line.strip() and not line.startswith("#")]

setup(
    name="setuptools-demo",
    version="1.0.0",
    author="Demo Author",
    author_email="demo@example.com",
    description="Traditional setuptools packaging demo",
    long_description=read_readme(),
    long_description_content_type="text/markdown",
    url="https://github.com/example/setuptools-demo",
    
    # Package discovery
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    
    # Dependencies
    install_requires=read_requirements(),
    
    # Development dependencies
    extras_require={
        "dev": [
            "pytest>=7.0.0",
            "pytest-cov>=4.0.0",
            "black>=22.0.0",
            "flake8>=5.0.0",
            "mypy>=1.0.0",
        ],
        "docs": [
            "sphinx>=5.0.0",
            "sphinx-rtd-theme>=1.0.0",
        ]
    },
    
    # Entry points
    entry_points={
        "console_scripts": [
            "setuptools-demo=setuptools_demo.cli:main",
        ],
    },
    
    # Classifiers
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
    ],
    
    # Python version requirement
    python_requires=">=3.8",
    
    # Include package data
    include_package_data=True,
    package_data={
        "setuptools_demo": ["data/*.json", "templates/*.html"],
    },
    
    # Zip safe
    zip_safe=False,
)