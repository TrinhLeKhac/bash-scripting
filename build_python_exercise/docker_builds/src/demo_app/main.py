#!/usr/bin/env python3
"""
Main application module for Docker demo
"""

import click
import requests
from flask import Flask, jsonify
from . import __version__

app = Flask(__name__)

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({"status": "healthy", "version": __version__})

@app.route('/')
def home():
    """Home endpoint"""
    return jsonify({
        "message": "Docker Demo App",
        "version": __version__,
        "endpoints": ["/health", "/api/data"]
    })

@app.route('/api/data')
def get_data():
    """Fetch external data"""
    try:
        response = requests.get("https://httpbin.org/json", timeout=5)
        return jsonify({"status": "success", "data": response.json()})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@click.command()
@click.option('--host', default='0.0.0.0', help='Host to bind to')
@click.option('--port', default=8000, help='Port to bind to')
@click.option('--debug', is_flag=True, help='Enable debug mode')
def main(host, port, debug):
    """Run the demo application"""
    if debug:
        click.echo(f"Starting Demo App v{__version__} in debug mode")
        app.run(host=host, port=port, debug=True)
    else:
        click.echo(f"Starting Demo App v{__version__}")
        app.run(host=host, port=port)

if __name__ == '__main__':
    main()