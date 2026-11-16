# Aerial theme for SDDM

SDDM theme with Apple TV Aerial videos

Videos are played randomly and different playlists are used based on time of day (only day and night diferenciation, night between 5pm - 5am) its possible to tweak to have more time diferentiation, the one used is provided with the videos.


### Dependencies

It is necessary to have the Phonon GStreamer backend for qt5, GStreamer ffmpeg Plugin and GStreamer Plugins Good
- For Arch linux : `pacman -S gst-libav phonon-qt5-gstreamer gst-plugins-good qt5-quickcontrols qt5-graphicaleffects qt5-multimedia`
- For Gentoo : these settings allowed me to make the theme work

    * `media-libs/gst-plugins-good`
    * `USE="alsa gstreamer qml widgets" dev-qt/qtmultimedia`
    * `USE="widgets" dev-qt/qtquickcontrols`
    * `dev-qt/qtgraphicaleffects`
    * `USE="gstreamer" media-libs/phonon`
    * `media-plugins/gst-plugins-openh264` (optional for video)
    * `media-plugins/gst-plugins-libde265` (optional for video)

 - For Kubuntu: `apt install gstreamer1.0-libav phonon4qt5-backend-gstreamer gstreamer1.0-plugins-good qml-module-qtquick-controls qml-module-qtgraphicaleffects qml-module-qtmultimedia qt5-default`
 - For Lubuntu 22.04: `sudo apt-get install gstreamer1.0-libav qml-module-qtmultimedia libqt5multimedia5-plugins`
 - For Debian 12 LXQt: `sudo apt-get install gstreamer1.0-libav qml-module-qtmultimedia libqt5multimedia5-plugins`
 - For Fedora 36 LXQt spin: `sudo dnf install git qt5-qtgraphicaleffects qt5-qtquickcontrols gstreamer1-libav`. Make sure setup [RPM Fusion Repo](https://rpmfusion.org/Configuration) first to get gstreamer1-libav package.

Havent tryed for other distros...

### Installation

Simply clone the repository and copy it to `/usr/share/sddm/themes/` like this:
```
git clone git@github.com:3ximus/aerial-sddm-theme.git
mv aerial-sddm-theme /usr/share/sddm/themes
```
*Note that super user priviledges are needed to move files into that directory.*

The theme can be tested by running `sddm-greeter --test-mode --theme <path-to-this-repository>`

### Other notes

This theme streams the HD videos so a good internet connection is necessary.
If there is no active connection or the video can't be played the background will fallback to the image background.jpg

### Local videos

Streaming means the first video takes a while to appear at every boot, and nothing plays if the network isn't up yet. Playing videos from disk avoids both:

```
sudo mkdir /usr/share/sddm/themes/aerial-sddm-theme/videos
sudo chown $USER /usr/share/sddm/themes/aerial-sddm-theme/{videos,playlists}
/usr/share/sddm/themes/aerial-sddm-theme/scripts/download-videos.py 5
```

then set `bgVidDay=playlists/local.m3u` and `bgVidNight=playlists/local.m3u` in `theme.conf.user`. Run the script again to add more videos (`--help` for options).

Some things to keep in mind:

- **Keep the videos outside your home directory.** The greeter runs as the `sddm` user, which usually can't read `/home/<you>`, so videos there work in `--test-mode` but not at boot.
- **Prefer H.264.** Apple's HEVC files are 10-bit, which many GPUs (e.g. Intel before Kaby Lake, older NVIDIA) can't decode in hardware. Software decoding takes one or two CPU cores at 1080p and stutters, especially during the first seconds after boot. The download script fetches H.264 by default.
- **Hardware decoding.** Install your VA-API driver and GStreamer's VA plugin (on Arch: `intel-media-driver` or `libva-mesa-driver`, plus `gst-plugin-va`) and check `vainfo` lists H.264 decoding. On machines with two GPUs the decoder may be registered under a device-specific name (`varenderD129h264dec`) and the software decoder still wins. If so, demote it for the greeter in your SDDM config:
  ```
  [General]
  GreeterEnvironment=GST_PLUGIN_FEATURE_RANK=avdec_h264:SECONDARY
  ```

You can also build a playlist from your own videos:

`find <path-to-your-directory> -maxdepth 1 -type f > <playlist-file>`

If you would like to use the same videos but offline, simply download them using your shell, e.g. :

```
while read -r link; do
    wget "$link"
done < playlist_file
```

### Changing settings in `Main.qml`

You can change a few settings in this file
- `font.bold` - set true or false to enable or disable bold font

### Changing settings in `theme.conf.user`

You can change a few settings in this file
- `dayTimeStart` and `dayTimeEnd` - set your day start/end time
- `bgImgDay` and `bgImgNight` - default background day/night image, now support GIF animated image
- `bgVidDay` and `bgImgNight` - video day/night playlists
- `displayFont` - font
- `clockFontSize`, `dateFontSize`, `labelFontSize`, `errorMsgFontSize` and `actionBarFontSize` - customize font size
- `clockFontColor`, `labelFontColor` and `actionBarFontColor` - customize font color
- `dateFormat` and `timeFormat` - customize [date and time](https://doc.qt.io/qt-5/qml-qtqml-date.html) format
- `showLoginButton` - if set to false will hide the login button
- `showClearPasswordButton` - if set to false will hide the clear password button that appears when text is inputed
- `passwordLeftMargin` and `usernameLeftMargin` - set margin between input boxes and labels, some fonts are messy and allows fixing of overlap
- `relativePositionX` and `relativePositionY` - position the login text box and clock
- `showTopBar` - if set to false will hide the wm/keyboard top bar

Example config (not the same as the screenshots):

```
[General]
bgVidDay=playlist_day.m3u
bgVidNight=playlist_night.m3u
displayFont="Misc Fixed"
showLoginButton=false
passwordLeftMargin=15
usernameLeftMargin=15
showTopBar=true
```

### Note that some configs names have changed from previous values:
```
day_time_start => dayTimeStart
day_time_end => dayTimeEnd
background_vid_day => bgVidDay
background_vid_night => bgVidNight
languageBoxFontSize => actionBarFontSize
```

## Preview

![preview1](screens/preview1.gif)
![preview2](screens/preview2.gif)
![preview3](screens/preview3.gif)

## Using my custom theme.conf.user

![custom](screens/custom.gif)

## License

Theme is licensed under GPL.
