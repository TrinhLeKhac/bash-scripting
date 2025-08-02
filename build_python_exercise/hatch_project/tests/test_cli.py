"""
Tests for hatch_demo CLI module
"""

import pytest
from click.testing import CliRunner

from hatch_demo import __version__
from hatch_demo.cli import main


def test_version():
    """Test that version is defined"""
    assert __version__ == "1.0.0"


def test_cli_basic():
    """Test basic CLI functionality"""
    runner = CliRunner()
    result = runner.invoke(main, ["--name", "Test"])

    assert result.exit_code == 0
    assert "Hello, Test!" in result.output


def test_cli_verbose():
    """Test CLI with verbose flag"""
    runner = CliRunner()
    result = runner.invoke(main, ["--name", "Test", "--verbose"])

    assert result.exit_code == 0
    assert "Hello, Test!" in result.output
    assert f"Hatch Demo v{__version__}" in result.output
    assert "Demo completed successfully!" in result.output


def test_cli_help():
    """Test CLI help"""
    runner = CliRunner()
    result = runner.invoke(main, ["--help"])

    assert result.exit_code == 0
    assert "Hatch Demo CLI" in result.output
    assert "--name" in result.output
    assert "--url" in result.output
    assert "--verbose" in result.output


def test_cli_version_option():
    """Test CLI version option"""
    runner = CliRunner()
    result = runner.invoke(main, ["--version"])

    assert result.exit_code == 0
    assert __version__ in result.output


@pytest.mark.parametrize("name", ["Alice", "Bob", "Charlie"])
def test_cli_different_names(name):
    """Test CLI with different names"""
    runner = CliRunner()
    result = runner.invoke(main, ["--name", name])

    assert result.exit_code == 0
    assert f"Hello, {name}!" in result.output
