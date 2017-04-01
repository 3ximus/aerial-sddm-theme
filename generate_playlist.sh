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
