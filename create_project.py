#!/usr/bin/env python3
import os
import plistlib
from pathlib import Path

# Create Info.plist
info_plist = {
    'CFBundleDevelopmentRegion': 'en',
    'CFBundleExecutable': '$(EXECUTABLE_NAME)',
    'CFBundleIdentifier': '$(PRODUCT_BUNDLE_IDENTIFIER)',
    'CFBundleInfoDictionaryVersion': '6.0',
    'CFBundleName': '$(PRODUCT_NAME)',
    'CFBundlePackageType': 'APPL',
    'CFBundleShortVersionString': '1.0',
    'CFBundleVersion': '1',
    'LSRequiresIPhoneOS': True,
    'UIApplicationSceneManifest': {
        'UIApplicationSupportsMultipleScenes': False,
    },
    'UILaunchScreen': {},
    'UIRequiredDeviceCapabilities': ['armv7'],
    'UISupportedInterfaceOrientations': [
        'UIInterfaceOrientationPortrait',
        'UIInterfaceOrientationLandscapeLeft',
        'UIInterfaceOrientationLandscapeRight'
    ],
    'UISupportedInterfaceOrientations~ipad': [
        'UIInterfaceOrientationPortrait',
        'UIInterfaceOrientationPortraitUpsideDown',
        'UIInterfaceOrientationLandscapeLeft',
        'UIInterfaceOrientationLandscapeRight'
    ]
}

info_plist_path = 'RickyApp/RickyApp/Info.plist'
with open(info_plist_path, 'wb') as f:
    plistlib.dump(info_plist, f)

print(f"Created Info.plist at {info_plist_path}")
