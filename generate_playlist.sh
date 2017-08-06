#!/bin/bash

if [ "$1" == "local" ]; then
    python -c '
import os
day=open("playlist_day.m3u", "w")
night=open("playlist_night.m3u", "w")
for x in os.listdir("./playlist_videos/day"):
    day.write("./playlist_videos/day/" + x + "\n")
for x in os.listdir("./playlist_videos/night"):
    night.write("./playlist_videos/night/" + x + "\n")
day.close()
night.close()
'
    echo "Generated local video playlist successful!"

else

    curl 'http://a1.phobos.apple.com/us/r1000/000/Features/atv/AutumnResources/videos/entries.json' 2>/dev/null | python2 -c '
import sys, json;
day=open("playlist_day.m3u", "w")
night=open("playlist_night.m3u", "w")
for x in json.load(sys.stdin):
	for asset in x["assets"]:
		if asset["timeOfDay"] == "night":
			night.write(asset["url"]+"\n")
		elif asset["timeOfDay"] == "day":
			day.write(asset["url"]+"\n")
		else:
			print "Unknown time of day %s" % asset["timeOfDay"]
day.close()
night.close()
'
    echo "Generated internet video playlist successful!"
fi
