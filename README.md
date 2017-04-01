# Aerial theme for sddm

SDDM theme with Apple TV Aerial videos

Videos are played randomly and diferent playlists are used based on time of day (only day and night diferenciation, night between 5pm - 5am) its possible to tweak to have more time diferentiation, the one used is provided with the videos.


### Dependencies

It is necessary to have the Phonon GStreamer backend for qt5 and the GStreamer ffmpeg Plugin
- For Arch linux : `pacman -S gst-libav phonon-qt5-gstreamer`

Havent tryed for other distros...

### Other notes

This theme streams the videos so internet connection is necessary.
If there is no active connection or the video can't be played the background will fallback to the image background.jpg

### Changing settings in `theme.conf.user`

You can change the font and the background.
To set background image use `background`, for video playlists use `background_day` and `background_night`. Other keywords can be used, you just need to change the loaded config name near the end of the Main.qml file.

Example:


```
[General]
background="image.jpg"
background_day="playlist_day.m3u"
background_night="playlist_night.m3u"
displayFont="Montserrat"
```

## Preview

![preview1](preview1.gif)
![preview2](preview2.gif)
![preview3](preview3.gif)

## License

Theme is licensed under GPL.
