#!/usr/bin/env python3

import configparser, io, requests, re, subprocess, sys, urllib

mirror = "https://downloads.tuxfamily.org/godotengine/"

old_config = configparser.ConfigParser()
old_config.read("data/versions.cfg")

def request(page):
    print("Downloading", mirror + page)
    try:
        request = urllib.request.Request(mirror + page, method="GET")
        response = urllib.request.urlopen(request)
        return response.read().decode()
    except Exception as e:
        print(e)
        print(page)

discovered_versions = []

versions = re.findall(r">(\d+\.\d+(?:\.\d+)*)<", request(""))
for version in versions:
    if version in old_config.sections() or version.startswith("2") or version.startswith("1"):
        # skip if we already know about a stable version of this release, there's
        # probably nothing new
        continue

    data = request(version + "/")
    rcs = re.findall(r">((?:rc|beta)\d+)<", data)
    for rc in rcs:
        discovered_versions.append(f"{version}-{rc}")
    if f"godot-{version}-stable.tar.xz" in data:
        discovered_versions.append(version)

new_cfg_string = ""

discovered_versions = [version for version in discovered_versions if version not in old_config.sections()]

if len(discovered_versions) == 0:
    sys.exit(0)

def create_tags(array):
    if len(array):
        strings = ", ".join([f"\"{tag}\"" for tag in array])
        return f"tags=[{strings}]"
    else:
        return ""

for version in discovered_versions:
    print("ADDING", version)

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

    new_cfg_string += f"""[{version_id}]
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

"""

check = subprocess.run(["./scripts/check_versions.py"], input=new_cfg_string.encode()).returncode
if check != 0:
    print("check_versions.py failed!")
    exit(1)

with open("data/versions.cfg", "a") as file:
    file.write("\n\n")
    file.write(new_cfg_string)

print("Updating info.cfg...")
info = configparser.ConfigParser()
info.read("data/info.cfg")
info["general"]["versions_cfg"] = str(info.getint("general", "versions_cfg") + 1)
with open("data/info.cfg", "w") as file:
    info.write(file, space_around_delimiters=False)

subprocess.run(["git", "add", "data/info.cfg", "data/versions.cfg"])
subprocess.run(["git", "commit", "-m", "versions.cfg: " + ", ".join(discovered_versions)])
subprocess.run(["git", "push", "-o", "merge_request.create"])