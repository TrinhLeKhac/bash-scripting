#!/usr/bin/env python3
"""
Setup script for conda-demo package
"""

from setuptools import setup, find_packages

setup(
    name="conda-demo",
    version="1.0.0",
    description="Conda packaging demo for scientific Python",
    long_description="""
    This package demonstrates how to create conda packages
    for scientific Python applications with proper dependency
    management and cross-platform support.
    """,
    author="Demo Author",
    author_email="demo@example.com",
    url="https://github.com/example/conda-demo",
    packages=find_packages(),
    python_requires=">=3.8",
    install_requires=[
        "requests>=2.28.0",
        "click>=8.0.0",
        "pydantic>=1.10.0"
    ],
    entry_points={
        'console_scripts': [
            'conda-demo=conda_demo.cli:main',
        ],
    },
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
    ],
)