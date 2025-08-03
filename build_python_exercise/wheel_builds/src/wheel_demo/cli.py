#!/usr/bin/env python3
"""
Command line interface for wheel demo
"""

import click
from .core import WheelProcessor, DataValidator
from .utils import hash_string, format_data
from .wheel_tools import WheelValidator, WheelBuilder, WheelAnalyzer


@click.group()
@click.version_option(version="1.0.0")
def main():
    """Wheel Demo CLI Application"""
    pass


@main.command()
@click.option('--text', '-t', help='Text to process')
@click.option('--numbers', '-n', help='Comma-separated numbers to process')
@click.option('--format', '-f', type=click.Choice(['json', 'text']), 
              default='text', help='Output format')
def info(text, numbers, format):
    """Process and display information about data"""
    processor = WheelProcessor()
    
    if text:
        result = processor.process_text(text)
        click.echo(format_data(result, format))
    elif numbers:
        try:
            num_list = [float(x.strip()) for x in numbers.split(',')]
            if DataValidator.validate_numbers(num_list):
                result = processor.process_data(num_list)
                click.echo(format_data(result, format))
            else:
                click.echo("Error: Invalid numbers provided", err=True)
        except ValueError:
            click.echo("Error: Could not parse numbers", err=True)
    else:
        click.echo("Please provide either --text or --numbers option")


@main.command()
@click.option('--hash', '-h', help='String to hash')
@click.option('--algorithm', '-a', type=click.Choice(['md5', 'sha1', 'sha256', 'sha512']),
              default='sha256', help='Hash algorithm')
@click.option('--chunk', '-c', help='Comma-separated list to chunk')
@click.option('--size', '-s', type=int, default=3, help='Chunk size')
def utils(hash, algorithm, chunk, size):
    """Utility functions"""
    if hash:
        result = hash_string(hash, algorithm)
        click.echo(f"{algorithm.upper()} hash of '{hash}': {result}")
    elif chunk:
        from .utils import chunk_list
        try:
            items = [x.strip() for x in chunk.split(',')]
            chunks = chunk_list(items, size)
            click.echo(f"Chunked into groups of {size}:")
            for i, chunk_group in enumerate(chunks, 1):
                click.echo(f"  Chunk {i}: {chunk_group}")
        except ValueError as e:
            click.echo(f"Error: {e}", err=True)
    else:
        click.echo("Please provide either --hash or --chunk option")


@main.command()
@click.option('--wheel', '-w', help='Path to wheel file to validate')
@click.option('--check-format', is_flag=True, help='Check wheel format requirements')
@click.option('--analyze', '-a', help='Analyze wheel file')
def validate(wheel, check_format, analyze):
    """Validate wheel files and format"""
    validator = WheelValidator()
    
    if wheel:
        is_valid = validator.validate_wheel_file(wheel)
        click.echo(f"Wheel file '{wheel}' is {'valid' if is_valid else 'invalid'}")
        
        if is_valid:
            info = validator.get_wheel_info(wheel)
            click.echo("\nWheel Information:")
            for key, value in info.items():
                click.echo(f"  {key}: {value}")
    elif check_format:
        builder = WheelBuilder()
        requirements = builder.check_build_requirements()
        
        click.echo("Build Requirements Check:")
        for req, available in requirements.items():
            status = "✅" if available else "❌"
            click.echo(f"  {status} {req}: {'Available' if available else 'Missing'}")
        
        tags = builder.get_wheel_tags()
        click.echo("\nWheel Tags:")
        for tag_type, tag_value in tags.items():
            click.echo(f"  {tag_type}: {tag_value}")
    elif analyze:
        analyzer = WheelAnalyzer()
        analysis = analyzer.analyze_wheel(analyze)
        
        click.echo(f"Wheel Analysis for: {analyze}")
        click.echo(f"  Exists: {analysis['exists']}")
        click.echo(f"  Valid: {analysis['valid']}")
        click.echo(f"  Size: {analysis['size_bytes']:,} bytes")
        
        if analysis['valid']:
            click.echo(f"  Files: {analysis['content_count']}")
            if analysis['info']:
                click.echo("  Metadata:")
                for key, value in analysis['info'].items():
                    if key != 'error':
                        click.echo(f"    {key}: {value}")
    else:
        click.echo("Please provide --wheel, --check-format, or --analyze option")


if __name__ == '__main__':
    main()