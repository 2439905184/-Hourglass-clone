#!/usr/bin/env python3

import configparser, sys, time, urllib.error, urllib.request

mirror = "https://downloads.tuxfamily.org/godotengine/"
platforms = ["source", "Windows.32", "Windows.64", "OSX.32", "OSX.64", "OSX.arm64", "X11.32", "X11.64"]

config = configparser.ConfigParser()
config.read("data/versions.cfg")

urls = []
bad_urls = []

start_time = time.time()

for version in config:
    if version == "DEFAULT": continue

    print("\u001b[1;33m{}\u001b[0m".format(version))
    for platform in platforms:
        if platform in config[version]:
            url = mirror + config[version][platform].strip("\"")
            urls.append(url)

            request = urllib.request.Request(url, method="HEAD")
            try:
                status = urllib.request.urlopen(request).status
            except urllib.error.HTTPError as e:
                status = e.code

            if status == 200:
                print("    \u001b[1;32m[200]\u001b[0m {}".format(url))
            else:
                print("    \u001b[1;31m[{}]\u001b[0m {}".format(status, url))
                bad_urls += [url]

end_time = time.time()

print("Checked {} URLs in {}s, found {} problems".format(
    len(urls), (end_time - start_time), len(bad_urls)
))

sys.exit(0 if len(bad_urls) == 0 else 1)
