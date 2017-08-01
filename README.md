# Aerial theme for SDDM

SDDM theme with Apple TV Aerial videos

Videos are played randomly and diferent playlists are used based on time of day (only day and night diferenciation, night between 5pm - 5am) its possible to tweak to have more time diferentiation, the one used is provided with the videos.


### Dependencies

It is necessary to have the Phonon GStreamer backend for qt5, GStreamer ffmpeg Plugin and GStreamer Plugins Good
- For Arch linux : `pacman -S gst-libav phonon-qt5-gstreamer gst-plugins-good`

Havent tryed for other distros...

### Installation

Simply clone the repository and copy it to `/usr/share/sddm/themes/` like this:
```
git clone git@github.com:3ximus/aerial-sddm-theme.git
mv aerial-sddm-theme /usr/share/sddm/themes
```
*Note that super user priviledges are needed to move files into that directory.*

The theme can be tested by running `sddm-greeter --theme <path-to-this-repository>`

### Other notes

This theme streams the HD videos so a good internet connection is necessary.
If there is no active connection or the video can't be played the background will fallback to the image background.jpg

### Changing settings in `theme.conf.user`

You can change a few settings in this file
- `background` - default background image
- `background_day` and `background_night` - video playlists
- `displayFont` - font
- `showLoginButton` - if set to false will hide the login button
- `passwordLeftMargin` and `usernameLeftMargin` - set margin between input boxes and labels, some fonts are messy and allows fixing of overlap
- `relativePositionX` and `relativePositionY` - position the login text box and clock

Example config (not the same as the screenshots):

```
[General]
background_day=playlist_day.m3u
background_night=playlist_night.m3u
displayFont="Misc Fixed"
showLoginButton=false
passwordLeftMargin=15
usernameLeftMargin=15
```

## Preview

![preview1](preview1.gif)
![preview2](preview2.gif)
![preview3](preview3.gif)

## License

Theme is licensed under GPL.
