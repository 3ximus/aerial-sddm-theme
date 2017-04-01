curl 'http://a1.phobos.apple.com/us/r1000/000/Features/atv/AutumnResources/videos/entries.json' 2>/dev/null | grep -o 'http.*\.mov' | sort -R > playlist.m3u
