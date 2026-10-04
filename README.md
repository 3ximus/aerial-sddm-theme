# Aerial theme for SDDM

SDDM theme with Apple TV Aerial videos

Videos are selected randomly from day and night lists. The switch is controlled by `dayTimeStart` and `dayTimeEnd` in `theme.conf` (defaults: 7 and 19).


### Dependencies

This theme requires an SDDM greeter built with Qt6 and Qt 6.11 or newer. It imports `QtQuick 2.15` and `QtMultimedia 6.11`; SDDM provides the `SddmComponents 2.0` module. Install the Qt6 QML runtime, Qt Multimedia QML module, and its FFmpeg playback backend. Package names vary by distribution and release; older Qt5, GStreamer, and Phonon package instructions do not apply to this theme.


### Installation

An SDDM theme is installed as a directory containing `metadata.desktop`, `Main.qml`, the theme configuration, and its assets. The commands below use `/usr/share/sddm/themes/aerial-sddm-theme`; adjust the destination if your system uses a different SDDM theme directory.

#### With `just`

From the repository directory:

```sh
just check
just test
just install
```

`just test` runs the Qt6 SDDM greeter preview and sets `QML_XHR_ALLOW_FILE_READ=1` for that command so preview mode can read `theme.conf.user`. This variable is not needed by the installed greeter. If your Qt6 greeter is named `sddm-greeter`, run `SDDM_GREETER=sddm-greeter just test`. `just install` copies only runtime files and requires `sudo`. To create a release archive, run `just package`; it writes `build/aerial-sddm-theme.tar.gz`. The archive excludes local test configuration and repository metadata.

#### Without `just`

Test the theme directly from the repository:

```sh
QML_XHR_ALLOW_FILE_READ=1 sddm-greeter-qt6 --test-mode --theme .
```

If your Qt6 greeter is named `sddm-greeter`, use that executable name instead.

Install from the repository with standard shell tools:

```sh
sudo install -d /usr/share/sddm/themes/aerial-sddm-theme
sudo install -m 644 Main.qml metadata.desktop theme.conf /usr/share/sddm/themes/aerial-sddm-theme/
sudo cp -a components /usr/share/sddm/themes/aerial-sddm-theme/
```

To prepare the same release archive without `just`:

```
mkdir -p build/aerial-sddm-theme
cp -a Main.qml metadata.desktop theme.conf README.md LICENSE components build/aerial-sddm-theme/
tar -czf build/aerial-sddm-theme.tar.gz -C build aerial-sddm-theme
```

Extract the archive, then use the install commands above from the extracted theme directory. For local development, a symlink from `/usr/share/sddm/themes/aerial-sddm-theme` to the repository is also convenient.

### Other notes

The default playlists stream video, so they need an internet connection. Background images are configured beneath the video layers, but the theme does not currently switch to them automatically when a stream fails to load.

Edit `bgVidDay` and `bgVidNight` in `theme.conf.user` to customize the day and night videos. Separate URLs or local file paths with escaped `\n` sequences; Qt decodes each sequence as a newline between entries. A trailing backslash at the end of a physical line only wraps the config value and is not a playlist separator. Qt resolves local video paths directly, so playback no longer needs M3U file reads or `QML_XHR_ALLOW_FILE_READ`. Preview mode uses local XHR to read `theme.conf.user`; `just test` enables that access only for the preview process.

The `playlists/` directory contains sample M3U lists, including day, night, 4K, and undersea selections. They are examples only; the theme does not load these files directly. To use one, copy its video URLs into `bgVidDay` or `bgVidNight`, separating entries with escaped `\n` sequences and wrapping the config value with trailing backslashes as shown below.

### Changing settings in `Main.qml`

You can change a few settings in this file
- `font.bold` - set true or false to enable or disable bold font

### Changing settings in `theme.conf.user`

You can change a few settings in this file
- `dayTimeStart` and `dayTimeEnd` - set the hour boundaries used to choose the day/night playlist
- `bgImgDay` and `bgImgNight` - default background day/night image, now support GIF animated image
- `bgVidDay` and `bgVidNight` - escaped-`\n`-separated video URLs or local file paths for day/night
- `displayFont` - font
- `clockFontSize`, `dateFontSize`, `labelFontSize`, `errorMsgFontSize` and `actionBarFontSize` - customize font size
- `clockFontColor`, `labelFontColor` and `actionBarFontColor` - customize font color
- `dateFormat` and `timeFormat` - customize [date and time](https://doc.qt.io/qt-6/qml-qtqml-date.html) format
- `showLoginButton` - if set to false will hide the login button
- `showClearPasswordButton` - if set to false will hide the clear password button that appears when text is inputed
- `passwordLeftMargin` and `usernameLeftMargin` - set margin between input boxes and labels, some fonts are messy and allows fixing of overlap
- `relativePositionX` and `relativePositionY` - position the login text box and clock
- `showTopBar` - if set to false will hide the wm/keyboard top bar

Example config (not the same as the screenshots):

```
[General]
bgVidDay=https://example.com/day-video-1.mov\n\
    https://example.com/day-video-2.mov
bgVidNight=https://example.com/night-video-1.mov\n\
    https://example.com/night-video-2.mov
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

### Developer note: `theme.conf` vs `theme.conf.user` and `--test-mode`

- The Qt6 SDDM greeter loads `theme.conf` from the theme directory and exposes its values to QML before the theme is instantiated.
- `theme.conf.user` is provided as a separate, non-shipped override file so developers and testers can experiment without modifying the packaged `theme.conf` (useful when the theme is installed system-wide under `/usr/share/sddm/themes`).
- In this repository `Main.qml` reads `theme.conf.user` during `--test-mode` only. When testing locally, prefer editing `theme.conf.user` rather than `theme.conf`; it is not included in installs or release archives.


## License

Theme is licensed under GPL.
