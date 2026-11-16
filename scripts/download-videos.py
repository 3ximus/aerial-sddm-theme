#!/usr/bin/env python3
"""Download Apple aerial videos for offline use and write a local playlist.

Picks random videos from Apple's aerial manifest that aren't already in the
destination directory, saves them as "<Label> - <apple filename>.mov", then
rewrites the playlist to list every video in that directory. Run it again
any time to add more.

Examples (run as a user that can write to the theme directory):
  scripts/download-videos.py 5
  scripts/download-videos.py 3 --category underwater --max-mb 200
  scripts/download-videos.py --playlist-only     # after deleting videos

Then point the theme at the playlist in theme.conf.user:
  bgVidDay=playlists/local.m3u
  bgVidNight=playlists/local.m3u

Keep the videos outside your home directory: the greeter runs as the `sddm`
user, which usually can't read files under /home.
"""
import argparse
import io
import json
import random
import shutil
import sys
import tarfile
import urllib.request
from pathlib import Path

THEME = Path(__file__).resolve().parent.parent
MANIFEST_URL = "http://sylvan.apple.com/Aerials/resources-{}.tar"
VIDEO_EXTS = {".mov", ".mp4", ".mkv", ".webm"}


def load_manifest(version: int) -> tuple[list[dict], dict[str, str]]:
    with urllib.request.urlopen(MANIFEST_URL.format(version), timeout=60) as r:
        tar = tarfile.open(fileobj=io.BytesIO(r.read()))
    data = json.load(tar.extractfile("entries.json"))
    categories = {c["id"]: c["localizedNameKey"].removeprefix("AerialCategory").lower()
                  for c in data["categories"]}
    return data["assets"], categories


def http(url: str) -> str:
    # sylvan.apple.com's certificate doesn't validate; plain http works.
    return url.replace("https://", "http://", 1)


def remote_size(url: str) -> int | None:
    req = urllib.request.Request(url, method="HEAD")
    try:
        with urllib.request.urlopen(req, timeout=20) as r:
            return int(r.headers.get("Content-Length", 0)) or None
    except OSError:
        return None


def download(url: str, dest: Path) -> bool:
    part = dest.with_name(dest.name + ".part")
    try:
        with urllib.request.urlopen(url, timeout=60) as r, open(part, "wb") as f:
            shutil.copyfileobj(r, f, 1 << 20)
    except OSError as e:
        part.unlink(missing_ok=True)
        print(f"  failed: {e}", file=sys.stderr)
        return False
    part.rename(dest)
    return True


def write_playlist(videos: Path, playlist: Path) -> int:
    files = sorted(p for p in videos.iterdir() if p.suffix.lower() in VIDEO_EXTS)
    playlist.parent.mkdir(parents=True, exist_ok=True)
    playlist.write_text("".join(p.resolve().as_uri() + "\n" for p in files))
    return len(files)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("count", nargs="?", type=int, default=3, help="videos to add (default 3)")
    ap.add_argument("--dest", type=Path, default=THEME / "videos",
                    help="video directory (default: <theme>/videos)")
    ap.add_argument("--playlist", type=Path, default=THEME / "playlists" / "local.m3u",
                    help="playlist to write (default: <theme>/playlists/local.m3u)")
    ap.add_argument("--category", choices=["cities", "landscapes", "space", "underwater"])
    ap.add_argument("--max-mb", type=int, default=250, help="skip larger videos (default 250)")
    ap.add_argument("--hevc", action="store_true",
                    help="download HEVC 10-bit instead of H.264 (smaller files, but many GPUs "
                         "can't decode it in hardware)")
    ap.add_argument("--manifest-version", type=int, default=16)
    ap.add_argument("--playlist-only", action="store_true", help="only rewrite the playlist")
    args = ap.parse_args()

    args.dest.mkdir(parents=True, exist_ok=True)
    if args.playlist_only:
        print(f"{args.playlist}: {write_playlist(args.dest, args.playlist)} videos")
        return 0

    assets, categories = load_manifest(args.manifest_version)
    key = "url-1080-SDR" if args.hevc else "url-1080-H264"
    have = {p.name.rsplit(" - ", 1)[-1] for p in args.dest.iterdir()}
    candidates = [
        a for a in assets
        if a.get(key)
        and not any(Path(a.get(k, "")).name in have for k in ("url-1080-SDR", "url-1080-H264"))
        and (not args.category or args.category in {categories[c] for c in a.get("categories", [])})
    ]
    random.shuffle(candidates)
    print(f"{len(have)} in {args.dest}, {len(candidates)} more available")

    got = 0
    for a in candidates:
        if got >= args.count:
            break
        url = http(a[key])
        size = remote_size(url)
        if size is None or size > args.max_mb * 1024 * 1024:
            continue
        label = "".join(c for c in a.get("accessibilityLabel", "") if c not in '/\\:*?"<>|').strip()
        dest = args.dest / f"{label or 'Aerial'} - {Path(url).name}"
        print(f"[{got + 1}/{args.count}] {dest.name} ({size // 1048576} MB)", flush=True)
        if download(url, dest):
            got += 1

    print(f"Downloaded {got}. {args.playlist}: {write_playlist(args.dest, args.playlist)} videos")
    return 0 if got == args.count else 1


if __name__ == "__main__":
    sys.exit(main())
