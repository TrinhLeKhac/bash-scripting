"""
Tests for configuration and data validation
"""

from hatch_demo.cli import DemoConfig


def test_demo_config_valid():
    """Test valid configuration"""
    config = DemoConfig(name="Test", url="https://example.com", verbose=True)

    assert config.name == "Test"
    assert config.url == "https://example.com"
    assert config.verbose is True


def test_demo_config_defaults():
    """Test configuration with defaults"""
    config = DemoConfig(name="Test")

    assert config.name == "Test"
    assert config.url is None
    assert config.verbose is False


def test_demo_config_dict():
    """Test configuration dict conversion"""
    config = DemoConfig(name="Test", verbose=True)
    config_dict = config.model_dump()

    assert config_dict["name"] == "Test"
    assert config_dict["url"] is None
    assert config_dict["verbose"] is True


def test_demo_config_validation():
    """Test configuration validation"""
    # Valid config should not raise
    config = DemoConfig(name="Valid")
    assert config.name == "Valid"

    # Test with all parameters
    config = DemoConfig(name="Test User", url="https://api.example.com", verbose=False)
    assert config.name == "Test User"
    assert config.url == "https://api.example.com"
    assert config.verbose is False
