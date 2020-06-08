#!/usr/bin/python3
import argparse
import os
import re
import subprocess
import sys
from random import choice
from urllib.parse import quote


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("wdir", help="Path to wallpapers folder")
    args = parser.parse_args()
    all_wallpapers = list()

    r = re.compile(r".*\.(jp?g|png)", flags=re.IGNORECASE)

    with os.scandir(args.wdir) as it:
        for entry in it:
            if not entry.name.startswith('.') and entry.is_file() and r.match(entry.name):
                all_wallpapers.append(entry.name)

    if not all_wallpapers:
        print("Not found wallpapers")
        return 1
    chosen = choice(all_wallpapers)
    full_path = os.path.join(args.wdir, chosen)
    uri = f"file://{quote(full_path)}"
    print(f"Chosen {uri} wallpaper")

    subprocess.check_call(["gsettings", "set", "org.gnome.desktop.background", "picture-uri", uri])


if __name__ == "__main__":
    sys.exit(main())
