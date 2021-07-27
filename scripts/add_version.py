#!/usr/bin/env python3

import sys

if len(sys.argv) < 2:
    print("Usage: add_version.py <version>...")
    exit()

def create_tags(array):
    if len(array):
        strings = ", ".join([f"\"{tag}\"" for tag in array])
        return f"tags=[{strings}]"
    else:
        return ""

for version in sys.argv[1:]:
    path = version
    version_id = version
    tags = []
    if "beta" in version:
        path = version.replace("-", "/")
        tags = ["beta"]
    elif "rc" in version:
        path = version.replace("-", "/")
        tags = ["beta", "rc"]
    else:
        version += "-stable"

    print(f"""[{version_id}]
{create_tags(tags)}
config_version=4
OSX.64="{path}/Godot_v{version}_osx.universal.zip"
OSX.arm64="{path}/Godot_v{version}_osx.universal.zip"
Windows.32="{path}/Godot_v{version}_win32.exe.zip"
Windows.64="{path}/Godot_v{version}_win64.exe.zip"
X11.32="{path}/Godot_v{version}_x11.32.zip"
X11.64="{path}/Godot_v{version}_x11.64.zip"
source="{path}/godot-{version}.tar.xz"

[{version_id}-mono]
{create_tags(tags + ["mono"])}
config_version=4
OSX.64="{path}/mono/Godot_v{version}_mono_osx.universal.zip"
OSX.arm64="{path}/mono/Godot_v{version}_mono_osx.universal.zip"
Windows.32="{path}/mono/Godot_v{version}_mono_win32.zip"
Windows.64="{path}/mono/Godot_v{version}_mono_win64.zip"
X11.32="{path}/mono/Godot_v{version}_mono_x11_32.zip"
X11.64="{path}/mono/Godot_v{version}_mono_x11_64.zip"
source="{path}/godot-{version}.tar.xz"
""")
