# Aerial theme for sddm

SDDM theme with Apple TV Aerial videos

This theme streams the videos so internet connection is necessary

### Dependencies

It is necessary to have the Phonon GStreamer backend for qt5 and the GStreamer ffmpeg Plugin
- For Arch linux : `pacman -S gst-libav phonon-qt5-gstreamer`

### Changing settings in `theme.conf.user`:

You can change the font and the background.
The background can be either an image, a video or a playlist (.m3u) file, for example:

```
[General]
background="playlist.m3u"
displayFont="Montserrat"
```

## Screenshot

...

## NOTES

If there is no active connection or the video can't be played

## License

Theme is licensed under GPL.
Main.qml file is MIT licensed.
