"""
CLI main module for flit-demo
"""

import click
import requests
from typing import Optional
from . import __version__, __author__

@click.command()
@click.option('--name', default='World', help='Name to greet')
@click.option('--url', help='URL to fetch data from')
@click.option('--verbose', is_flag=True, help='Enable verbose output')
def main(name: str, url: Optional[str], verbose: bool):
    """Flit Demo CLI - Lightweight packaging demonstration"""
    
    if verbose:
        click.echo(f"Flit Demo v{__version__}")
        click.echo(f"Author: {__author__}")
    
    # Greeting
    click.echo(f"Hello, {name}!")
    
    # Optional URL fetch
    if url:
        try:
            click.echo(f"Fetching data from: {url}")
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            
            click.echo(f"Status: {response.status_code}")
            click.echo(f"Content-Type: {response.headers.get('content-type', 'unknown')}")
            
            if verbose and 'json' in response.headers.get('content-type', ''):
                data = response.json()
                click.echo("Response data:")
                for key, value in list(data.items())[:3]:  # Show first 3 items
                    click.echo(f"  {key}: {value}")
                    
        except requests.RequestException as e:
            click.echo(f"Error fetching data: {e}", err=True)
    
    if verbose:
        click.echo("Demo completed successfully!")

if __name__ == '__main__':
    main()