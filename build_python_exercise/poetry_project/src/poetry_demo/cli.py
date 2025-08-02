#!/usr/bin/env python3
"""
CLI module for poetry-demo package
"""

from typing import Optional

import click
import requests
from pydantic import BaseModel, ValidationError

from poetry_demo import __version__


class DemoConfig(BaseModel):
    """Configuration model using pydantic"""

    name: str
    url: Optional[str] = None
    verbose: bool = False


@click.command()
@click.option("--name", default="World", help="Name to greet")
@click.option("--url", help="URL to fetch data from")
@click.option("--verbose", is_flag=True, help="Enable verbose output")
@click.version_option(version=__version__)
def main(name: str, url: Optional[str], verbose: bool) -> None:
    """Poetry Demo CLI - Modern Python packaging demonstration"""

    try:
        config = DemoConfig(name=name, url=url, verbose=verbose)
    except ValidationError as e:
        click.echo(f"Configuration error: {e}", err=True)
        msg = "Invalid configuration"
        raise click.ClickException(msg) from e

    if config.verbose:
        click.echo(f"Poetry Demo v{__version__}")
        click.echo(f"Configuration: {config.dict()}")

    # Greeting
    click.echo(f"Hello, {config.name}!")

    # Optional URL fetch
    if config.url:
        try:
            click.echo(f"Fetching data from: {config.url}")
            response = requests.get(config.url, timeout=10)
            response.raise_for_status()

            click.echo(f"Status: {response.status_code}")
            click.echo(
                f"Content-Type: {response.headers.get('content-type', 'unknown')}"
            )

            if config.verbose and "json" in response.headers.get("content-type", ""):
                data = response.json()
                click.echo("Response data:")
                for key, value in list(data.items())[:3]:  # Show first 3 items
                    click.echo(f"  {key}: {value}")

        except requests.RequestException as e:
            click.echo(f"Error fetching data: {e}", err=True)
            msg = f"Failed to fetch from {config.url}"
            raise click.ClickException(msg) from e

    if config.verbose:
        click.echo("Demo completed successfully!")


if __name__ == "__main__":
    main()  # type: ignore
