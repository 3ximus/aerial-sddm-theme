#!/usr/bin/env python3
"""Regenerate the bundled playlists from Apple's current aerial manifest.

Apple publishes the list of aerial videos as entries.json inside
resources-<N>.tar on sylvan.apple.com. This script downloads it and writes
one .m3u per playlist into the playlists/ directory next to this script.

Plain http:// URLs are used on purpose: sylvan.apple.com's TLS certificate
doesn't validate, so GStreamer refuses the https:// URLs.

Usage: scripts/update-playlists.py [--manifest-version N]
"""
import argparse
import io
import json
import tarfile
import urllib.request
from pathlib import Path

PLAYLISTS = Path(__file__).resolve().parent.parent / "playlists"
MANIFEST_URL = "http://sylvan.apple.com/Aerials/resources-{}.tar"

# 1080p H.264 is the safest default: it hardware-decodes almost everywhere,
# whereas Apple's HEVC files are 10-bit, which many GPUs can't decode.
HD = "url-1080-H264"
UHD = "url-4K-SDR"  # HEVC 10-bit


def load_assets(version: int) -> tuple[list[dict], dict[str, str]]:
    with urllib.request.urlopen(MANIFEST_URL.format(version), timeout=60) as r:
        tar = tarfile.open(fileobj=io.BytesIO(r.read()))
    data = json.load(tar.extractfile("entries.json"))
    categories = {c["id"]: c["localizedNameKey"].removeprefix("AerialCategory").lower()
                  for c in data["categories"]}
    return data["assets"], categories


def http(url: str) -> str:
    return url.replace("https://", "http://", 1)


def write(name: str, assets: list[dict], key: str = HD) -> None:
    urls = [http(a[key]) for a in sorted(assets, key=lambda a: (a["accessibilityLabel"], a[key]))
            if a.get(key)]
    (PLAYLISTS / f"{name}.m3u").write_text("".join(u + "\n" for u in urls))
    print(f"{name}.m3u: {len(urls)} videos")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--manifest-version", type=int, default=16)
    args = ap.parse_args()

    assets, categories = load_assets(args.manifest_version)
    by_category: dict[str, list[dict]] = {name: [] for name in categories.values()}
    for a in assets:
        for c in a.get("categories", []):
            by_category[categories[c]].append(a)

    # The manifest has no time-of-day field any more: treat space footage and
    # shots labelled "Night" as night, everything else as day.
    def is_night(a: dict) -> bool:
        return a in by_category.get("space", []) or "night" in a["accessibilityLabel"].lower()

    write("day", [a for a in assets if not is_night(a)])
    write("night", [a for a in assets if is_night(a)])
    write("all", assets)
    write("4k", assets, UHD)
    for name, items in by_category.items():
        write(name, items)
    # Kept for existing configs that point at it.
    write("undersea", by_category.get("underwater", []))


if __name__ == "__main__":
    main()
