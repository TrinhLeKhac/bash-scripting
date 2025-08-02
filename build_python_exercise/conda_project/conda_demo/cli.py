#!/usr/bin/env python3
"""
CLI module for conda-demo package
"""

import click
import requests
from pydantic import BaseModel
from typing import Optional

class DemoConfig(BaseModel):
    """Configuration model using pydantic"""
    name: str
    version: str = "1.0.0"
    debug: bool = False

@click.group()
@click.version_option(version="1.0.0")
def main():
    """Conda Demo CLI - A demonstration of conda packaging"""
    pass

@main.command()
@click.option('--name', default='World', help='Name to greet')
@click.option('--debug', is_flag=True, help='Enable debug mode')
def hello(name: str, debug: bool):
    """Say hello with optional debug info"""
    config = DemoConfig(name=name, debug=debug)
    
    click.echo(f"Hello, {config.name}!")
    
    if config.debug:
        click.echo(f"Debug mode: {config.debug}")
        click.echo(f"Version: {config.version}")

@main.command()
@click.option('--url', default='https://httpbin.org/json', help='URL to fetch')
def fetch(url: str):
    """Fetch data from URL using requests"""
    try:
        click.echo(f"Fetching data from: {url}")
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        
        click.echo("Response received:")
        click.echo(f"Status: {response.status_code}")
        click.echo(f"Content-Type: {response.headers.get('content-type', 'unknown')}")
        
        if 'json' in response.headers.get('content-type', ''):
            data = response.json()
            click.echo("JSON Data:")
            for key, value in data.items():
                click.echo(f"  {key}: {value}")
        else:
            click.echo(f"Content: {response.text[:200]}...")
            
    except requests.RequestException as e:
        click.echo(f"Error fetching data: {e}", err=True)
        raise click.ClickException(f"Failed to fetch from {url}")

@main.command()
def info():
    """Show package information"""
    click.echo("Conda Demo Package Information:")
    click.echo("=" * 40)
    click.echo(f"Name: conda-demo")
    click.echo(f"Version: 1.0.0")
    click.echo(f"Description: Conda packaging demonstration")
    click.echo(f"Dependencies: requests, click, pydantic")
    click.echo(f"Python: >=3.8")

if __name__ == '__main__':
    main()