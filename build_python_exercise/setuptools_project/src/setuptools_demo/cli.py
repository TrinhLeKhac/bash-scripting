#!/usr/bin/env python3
"""
Command line interface for setuptools demo
"""

import click
from .core import Calculator, DataProcessor
from .utils import format_output


@click.group()
@click.version_option(version="1.0.0")
def main():
    """Setuptools Demo CLI Application"""
    pass


@main.command()
@click.argument('a', type=float)
@click.argument('b', type=float)
@click.option('--operation', '-o', 
              type=click.Choice(['add', 'subtract', 'multiply', 'divide']),
              default='add', help='Mathematical operation to perform')
def calc(a, b, operation):
    """Perform mathematical calculations"""
    calculator = Calculator()
    
    operations = {
        'add': calculator.add,
        'subtract': calculator.subtract,
        'multiply': calculator.multiply,
        'divide': calculator.divide
    }
    
    try:
        result = operations[operation](a, b)
        click.echo(format_output(f"{a} {operation} {b} = {result}"))
    except ValueError as e:
        click.echo(f"Error: {e}", err=True)
        raise click.Abort()


@main.command()
@click.argument('numbers', nargs=-1, type=float, required=True)
@click.option('--format', '-f', 
              type=click.Choice(['text', 'json']),
              default='text', help='Output format')
def process(numbers, format):
    """Process a list of numbers"""
    processor = DataProcessor()
    processor.load_data(list(numbers))
    
    if format == 'json':
        click.echo(processor.to_json())
    else:
        click.echo(format_output(f"Data: {numbers}"))
        click.echo(format_output(f"Mean: {processor.calculate_mean():.2f}"))
        click.echo(format_output(f"Median: {processor.calculate_median():.2f}"))


if __name__ == '__main__':
    main()