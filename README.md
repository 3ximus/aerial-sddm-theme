# Aerial theme for sddm

SDDM theme with Apple TV Aerial videos

### Dependencies

It is necessary to have the Phonon GStreamer backend for qt5 and the GStreamer ffmpeg Plugin
- For Arch linux : `pacman -S gst-libav phonon-qt5-gstreamer`

### Other notes

This theme streams the videos so internet connection is necessary
If there is no active connection or the video can't be played the background will fallback to the image background.jpg

### Changing settings in `theme.conf.user`

You can change the font and the background.
The background can be either an image, a video or a playlist (.m3u) file, for example:

```
[General]
background="playlist.m3u"
displayFont="Montserrat"
```

## Preview

![preview1](preview1.gif)
![preview2](preview2.gif)

### TODO

- [ ] Randomize playlist each time inside QML
- [ ] Pick Videos based on time of day

Feel free to contribute to these ;)


## License

Theme is licensed under GPL.
Main.qml file is MIT licensed.
