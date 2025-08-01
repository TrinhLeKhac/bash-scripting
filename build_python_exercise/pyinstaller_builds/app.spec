# -*- mode: python ; coding: utf-8 -*-
"""
PyInstaller spec file for advanced executable creation
Demonstrates various PyInstaller configuration options
"""

import sys
from pathlib import Path

# Application configuration
APP_NAME = 'PyInstallerDemo'
APP_VERSION = '1.0.0'
APP_DESCRIPTION = 'PyInstaller Demo Application'

# Build configuration
block_cipher = None
debug = False
console = True

# Analysis configuration
a = Analysis(
    ['app.py'],
    pathex=[],
    binaries=[],
    datas=[
        # Include data files
        ('data/*', 'data'),
        ('config.json', '.'),
    ],
    hiddenimports=[
        # Add hidden imports if needed
        'pkg_resources.py2_warn',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        # Exclude unnecessary modules to reduce size
        'tkinter',
        'matplotlib',
        'numpy',
        'scipy',
        'pandas',
    ],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

# PYZ configuration (Python bytecode archive)
pyz = PYZ(
    a.pure, 
    a.zipped_data,
    cipher=block_cipher
)

# Executable configuration
exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name=APP_NAME,
    debug=debug,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,  # Enable UPX compression
    upx_exclude=[],
    runtime_tmpdir=None,
    console=console,
    disable_windowed_traceback=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    # Windows specific
    version='version_info.txt',
    icon='icon.ico' if sys.platform == 'win32' else None,
    # macOS specific
    bundle_identifier='com.example.pyinstallerdemo' if sys.platform == 'darwin' else None,
)

# macOS App Bundle (optional)
if sys.platform == 'darwin':
    app = BUNDLE(
        exe,
        name=f'{APP_NAME}.app',
        icon='icon.icns',
        bundle_identifier='com.example.pyinstallerdemo',
        version=APP_VERSION,
        info_plist={
            'CFBundleDisplayName': APP_NAME,
            'CFBundleShortVersionString': APP_VERSION,
            'CFBundleVersion': APP_VERSION,
            'NSHighResolutionCapable': True,
            'LSMinimumSystemVersion': '10.13.0',
        },
    )