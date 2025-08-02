#!/usr/bin/env python3
"""
Setup script for demo-app Docker package
"""

from setuptools import setup, find_packages

setup(
    name="demo-app",
    version="1.0.0",
    description="Docker demo application",
    author="Demo Author",
    author_email="demo@example.com",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    python_requires=">=3.8",
    install_requires=[
        "requests>=2.28.0",
        "click>=8.0.0",
        "flask>=2.3.0",
        "gunicorn>=20.1.0"
    ],
    entry_points={
        'console_scripts': [
            'demo-app=demo_app.main:main',
        ],
    },
)