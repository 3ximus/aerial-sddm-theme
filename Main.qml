import QtQuick 2.15
import SddmComponents 2.0
import QtMultimedia 6.11

import "components" as Theme

Rectangle {
    // Main Container
    id: container

    // Default config used for test-mode when SDDM doesn't inject `config`
    property var config: ({
        displayFont: "Sans",
        clockFontColor: "white",
        clockFontSize: 48,
        dateFontSize: 16,
        relativePositionX: 0.5,
        relativePositionY: 0.25,
        timeFormat: "hh:mm",
        dateFormat: "dddd, dd MMMM yyyy",
        bgVidDay: "http://sylvan.apple.com/Aerials/2x/Videos/comp_CH_C007_C011_PSNK_v02_SDR_PS_FINAL_20180709_SDR_2K_HEVC.mov\\nhttp://sylvan.apple.com/Aerials/2x/Videos/comp_CH_C002_C005_PSNK_v05_SDR_PS_FINAL_20180709_SDR_2K_HEVC.mov\\nhttp://sylvan.apple.com/Aerials/2x/Videos/comp_CH_C007_C004_PSNK_v02_SDR_PS_FINAL_20180709_SDR_2K_HEVC.mov\\nhttp://sylvan.apple.com/Aerials/2x/Videos/HK_H004_C013_2K_SDR_HEVC.mov\\nhttp://sylvan.apple.com/Aerials/2x/Videos/comp_A103_C002_0205DG_v12_SDR_FINAL_20180706_SDR_2K_HEVC.mov\\nhttp://sylvan.apple.com/Aerials/2x/Videos/comp_A108_C001_v09_SDR_FINAL_22062018_SDR_2K_HEVC.mov\\nhttp://sylvan.apple.com/Aerials/2x/Videos/comp_GMT308_139K_142NC_CARIBBEAN_DAY_v09_SDR_FINAL_22062018_SDR_2K_HEVC.mov\\nhttp://sylvan.apple.com/Aerials/2x/Videos/comp_A105_C003_0212CT_FLARE_v10_SDR_PS_FINAL_20180711_SDR_2K_HEVC.mov\\nhttp://sylvan.apple.com/Aerials/2x/Videos/comp_A009_C001_010181A_v09_SDR_PS_FINAL_20180725_SDR_2K_HEVC.mov\\nhttp://sylvan.apple.com/Aerials/2x/Videos/comp_A114_C001_0305OT_v10_SDR_FINAL_22062018_SDR_2K_HEVC.mov\\nhttp://sylvan.apple.com/Aerials/2x/Videos/comp_A001_C004_1207W5_v23_SDR_FINAL_20180706_SDR_2K_HEVC.mov",
        bgVidNight: "http://sylvan.apple.com/Aerials/2x/Videos/comp_GMT312_162NC_139M_1041_AFRICA_NIGHT_v14_SDR_FINAL_20180706_SDR_2K_HEVC.mov\\nhttp://sylvan.apple.com/Aerials/2x/Videos/comp_GMT329_113NC_396B_1105_CHINA_v04_SDR_FINAL_20180706_F900F2700_SDR_2K_HEVC.mov\\nhttp://sylvan.apple.com/Aerials/2x/Videos/comp_A083_C002_1130KZ_v04_SDR_PS_FINAL_20180725_SDR_2K_HEVC.mov\\nhttp://sylvan.apple.com/Aerials/2x/Videos/comp_GMT329_117NC_401C_1037_IRELAND_TO_ASIA_v48_SDR_PS_FINAL_20180725_F0F6300_SDR_2K_HEVC.mov\\nhttp://sylvan.apple.com/Aerials/2x/Videos/comp_LA_A006_C004_v01_SDR_FINAL_PS_20180730_SDR_2K_HEVC.mov",
        bgImgDay: "components/resources/background.jpg",
        bgImgNight: "components/resources/background.jpg",
        showLoginButton: "true",
        showTopBar: "true",
        actionBarFontColor: "white",
        actionBarFontSize: 12,
        labelFontSize: 14,
        labelFontColor: "white",
        usernameLeftMargin: 10,
        passwordLeftMargin: 10,
        showClearPasswordButton: "true",
        errorMsgFontColor: "red",
        errorMsgFontSize: 14,
        dayTimeStart: 6,
        dayTimeEnd: 18,
        autofocusInput: "false"
    })

    // Keep a copy of the QML defaults so we can detect when values are still defaults
    property var _defaults: (function() { try { return JSON.parse(JSON.stringify(config)) } catch (e) { return {} } })()

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: (typeof session !== 'undefined' && session.index !== undefined) ? session.index : 0
    property var languageModel: []
    property bool previewMode: false

    function rebuildLanguageModel() {
        if (!keyboard || !keyboard.layouts) {
            languageModel = []
            return
        }

        var entries = []
        for (var i = 0; i < keyboard.layouts.length; ++i) {
            var entry = keyboard.layouts[i]
            var name = ""

            if (entry && typeof entry === "object") {
                name = (entry.name !== undefined) ? entry.name : ((entry.label !== undefined) ? entry.label : String(entry))
            } else {
                name = String(entry)
            }

            entries.push({ name: name, value: i })
        }

        languageModel = entries
    }

    // Inherited from SDDMComponents
    TextConstants {
        id: textConstants
    }

    // Set SDDM actions
    Connections {
        target: sddm
        function onLoginFailed() {
            error_message.color = config.errorMsgFontColor
            error_message.text = textConstants.loginFailed
        }
    }

    // Set Font (FontLoader.name is read-only in Qt6; use a simple QtObject to hold the family)
    QtObject {
        id: textFont
        property string name: config.displayFont
    }

    // Background Fill
    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    // Set Background Image
    Image {
        id: backgroundImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
    }

    // Set Animated GIF Background Image
    AnimatedImage {
        id: animatedBackground
        anchors.fill: parent
        fillMode: AnimatedImage.PreserveAspectCrop
    }

    // Primary background video slot
    MediaPlayer {
        id: primaryPlayer
        autoPlay: true
        audioOutput: primaryAudio
        videoOutput: primaryVideo
    }
    AudioOutput {
        id: primaryAudio
        muted: container.videoAudioMuted
    }

    VideoOutput {
        id: primaryVideo
        fillMode: VideoOutput.PreserveAspectCrop
        anchors.fill: parent
        MouseArea {
            id: primaryVideoMouseArea
            anchors.fill: parent;
            onPressed: {
                container.toggleLoginOverlay()
                if (config.autofocusInput == "true")
                    container.focusLoginInput()
            }
        }
        Keys.onPressed: {
            container.showLoginOverlay()
        }
    }
    Theme.LoginOverlayFader {
        id: loginOverlayFader
        z: 0
        visible: true
        anchors.fill: parent
        state: "off"
        content: login_container
    }

    // Secondary background video slot, used for crossfades
    MediaPlayer {
        id: secondaryPlayer
        autoPlay: true
        audioOutput: secondaryAudio
        videoOutput: secondaryVideo
    }
    AudioOutput {
        id: secondaryAudio
        muted: container.videoAudioMuted
    }

    VideoOutput {
        id: secondaryVideo
        fillMode: VideoOutput.PreserveAspectCrop
        anchors.fill: parent
        opacity: 0
        MouseArea {
            id: secondaryVideoMouseArea
            enabled: false
            anchors.fill: parent;
            onPressed: {
                container.toggleLoginOverlay()
                if (config.autofocusInput == "true")
                    container.focusLoginInput()
            }
        }
        Behavior on opacity {
            NumberAnimation { easing.type: Easing.InOutSine; duration: 2600 }
        }
        Keys.onPressed: {
            container.showLoginOverlay()
        }
    }

    property MediaPlayer activePlayer: primaryPlayer
    property bool videoAudioMuted: true

    function toggleLoginOverlay() {
        loginOverlayFader.state = loginOverlayFader.state === "off" ? "on" : "off"
    }

    function showLoginOverlay() {
        loginOverlayFader.state = "on"
        focusLoginInput()
    }

    function focusLoginInput() {
        if (username_input_box.text === "")
            username_input_box.focus = true
        else
            password_input_box.focus = true
    }

    function loadConfigFileSync(filename) {
        if (!previewMode) {
            return false
        }

        var url = Qt.resolvedUrl(filename)
        var xhr = new XMLHttpRequest()
        try {
            xhr.open('GET', url, false)
            xhr.send()
            if (xhr.status === 200 || xhr.status === 0) {
                var physicalLines = xhr.responseText.split(/\r?\n/)
                var lines = []
                var pendingLine = ""
                for (var physicalIndex = 0; physicalIndex < physicalLines.length; physicalIndex++) {
                    var physicalLine = physicalLines[physicalIndex].trim()
                    var continued = physicalLine.length > 0
                        && physicalLine.charAt(physicalLine.length - 1) === "\\"
                    if (continued)
                        physicalLine = physicalLine.substring(0, physicalLine.length - 1)
                    pendingLine += physicalLine
                    if (!continued) {
                        lines.push(pendingLine)
                        pendingLine = ""
                    }
                }
                if (pendingLine.length > 0)
                    lines.push(pendingLine)
                var inGeneral = false
                for (var i = 0; i < lines.length; i++) {
                    var l = lines[i].trim()
                    if (l.length === 0) continue
                    if (l.charAt(0) === '#') continue
                    if (l.charAt(0) === '[') {
                        inGeneral = (l.toLowerCase() === '[general]')
                        continue
                    }
                    if (!inGeneral) continue
                    var idx = l.indexOf('=')
                    if (idx === -1) continue
                    var key = l.substring(0, idx).trim()
                    var val = l.substring(idx+1).trim()
                    // remove surrounding quotes if present
                    if (val.length >= 2 && ((val.charAt(0) === '"' && val.charAt(val.length-1) === '"') || (val.charAt(0) === "'" && val.charAt(val.length-1) === "'"))) {
                        val = val.substring(1, val.length-1)
                    }
                    // type coercion: numbers and booleans
                    if (!isNaN(Number(val))) {
                        val = Number(val)
                    } else if (val === 'true' || val === 'false') {
                        // keep strings "true"/"false" if other code expects that, but coerce here to boolean
                        val = (val === 'true')
                    }
                    // Only overwrite when current value is undefined or still the original default.
                    if (config[key] === undefined || config[key] === _defaults[key]) {
                        config[key] = val
                    }
                }
                return true
            }
        } catch (e) {
            // ignore
        }
        return false
    }

    // Timer event to handle fade between videos
    Timer {
        interval: 600;
        running: true; repeat: true
        onTriggered: {
            if (activePlayer.duration != -1 && activePlayer.position > activePlayer.duration - 9000) {
                if (secondaryVideo.opacity == 0) {
                    secondaryPlayer.play()
                } else {
                    primaryPlayer.play()
                }
            }
            if (activePlayer.duration != -1 && activePlayer.position > activePlayer.duration - 2400) {
                if (secondaryVideo.opacity == 0) {
                    primaryVideoMouseArea.enabled = false
                    activePlayer = secondaryPlayer
                    secondaryVideo.opacity = 1
                    triggerTimer.start()
                    secondaryVideoMouseArea.enabled = true
                } else {
                    secondaryVideoMouseArea.enabled = false
                    activePlayer = primaryPlayer
                    secondaryVideo.opacity = 0
                    triggerTimer.start()
                    primaryVideoMouseArea.enabled = true
                }
            }
        }
    }

    Timer {
        id: triggerTimer
        interval: 1600; running: false; repeat: false
        onTriggered: {
            if (secondaryVideo.opacity == 1)
                primaryPlayer.stop()
            else
                secondaryPlayer.stop()
        }
    }

    function videoUrls(value) {
        if (value === undefined || value === null || value === "")
            return []

        var entries = Array.isArray(value)
            ? value
            : String(value).replace(/\\n/g, "\n").split(/\r?\n/)
        var urls = []
        for (var i = 0; i < entries.length; i++) {
            var entry = String(entries[i]).trim()
            if (entry.length > 0)
                urls.push(Qt.resolvedUrl(entry))
        }
        return urls
    }

    function playRandomVideoList(value) {
        var items = videoUrls(value)
        if (items.length === 0) {
            console.warn("No background videos configured")
            return
        }

        primaryPlayer.source = items[Math.floor(Math.random() * items.length)]
        secondaryPlayer.source = items[Math.floor(Math.random() * items.length)]
        primaryPlayer.play()
        secondaryPlayer.play()
    }



    // Clock and Login Area
    Rectangle {
        id: rectangle
        z: 10
        anchors.fill: parent
        color: "transparent"

        Column {
            id: clock
            property date dateTime: new Date()
            property color color: config.clockFontColor
            y: parent.height * config.relativePositionY - clock.height / 2
            x: parent.width * config.relativePositionX - clock.width / 2

            Timer {
                interval: 100; running: true; repeat: true;
                onTriggered: clock.dateTime = new Date()
            }

            Text {
                id: time
                anchors.horizontalCenter: parent.horizontalCenter
                color: clock.color
                text : Qt.formatTime(clock.dateTime, config.timeFormat || "hh:mm")
                font.pointSize: config.clockFontSize
                font.family: textFont.name
                font.bold: true
            }

            Text {
                id: date
                anchors.horizontalCenter: parent.horizontalCenter
                color: clock.color
                text : Qt.formatDate(clock.dateTime, config.dateFormat || "dddd, dd MMMM yyyy")
                font.family: textFont.name
                font.pointSize: config.dateFontSize
                font.bold: true
            }
        }


        Rectangle {
            id: login_container
            z: 20
            y: clock.y + clock.height + 30
            width: clock.width
            height: parent.height * 0.08
            color: "transparent"
            anchors.left: clock.left

            Rectangle {
                id: username_row
                height: parent.height * 0.36
                color: "transparent"
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
                transformOrigin: Item.Center
                anchors.margins: 10

                Text {
                    id: username_label
                    width: parent.width * 0.27
                    height: parent.height * 0.66
                    horizontalAlignment: Text.AlignLeft
                    font.family: textFont.name
                    font.pixelSize: config.labelFontSize
                    font.bold: true
                    color: config.labelFontColor
                    text: "Username"
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextBox {
                    id: username_input_box
                    height: parent.height
                    text: userModel.lastUser
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: username_label.right
                    anchors.leftMargin: config.usernameLeftMargin
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    font: textFont.name
                    color: "#25000000"
                    borderColor: "transparent"
                    textColor: config.labelFontColor

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(username_input_box.text, password_input_box.text, session.index)
                            event.accepted = true
                        }
                    }

                    KeyNavigation.backtab: password_input_box
                    KeyNavigation.tab: password_input_box
                }
            }

            Rectangle {
                id: password_row
                y: username_row.height + 10
                height: parent.height * 0.36
                color: "transparent"
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Text {
                    id: password_label
                    width: parent.width * 0.27
                    text: textConstants.password
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignLeft
                    font.family: textFont.name
                    font.bold: true
                    font.pixelSize: config.labelFontSize
                    color: config.labelFontColor
                }

                Theme.PasswordBox {
                    id: password_input_box
                    height: parent.height
                    font: textFont.name
                    color: "#25000000"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: parent.height // this sets button width, this way its a square
                    anchors.left: password_label.right
                    anchors.leftMargin: config.passwordLeftMargin
                    borderColor: "transparent"
                    textColor: config.labelFontColor
                    tooltipBG: "#25000000"
                    tooltipFG: "#dc322f"
                    // image handled by Theme.PasswordBox; keep default
                    onTextChanged: {
                        if (password_input_box.text == "") {
                            clear_passwd_button.visible = false
                        }
                        if (password_input_box.text != "" && config.showClearPasswordButton != "false") {
                            clear_passwd_button.visible = true
                        }
                    }

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(username_input_box.text, password_input_box.text, session.index)
                            event.accepted = true
                        }
                    }

                    KeyNavigation.backtab: username_input_box
                    KeyNavigation.tab: login_button
                }

                Button {
                    id: clear_passwd_button
                    height: parent.height
                    width: parent.height
                    color: "transparent"
                    text: "x"
                    textColor: config.labelFontColor
                    font: textFont.name

                    border.color: "transparent"
                    border.width: 0
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.leftMargin: 0
                    anchors.rightMargin: parent.height

                    disabledColor: "#dc322f"
                    activeColor: "#393939"
                    pressedColor: "#2aa198"

                    onClicked: {
                        password_input_box.text=''
                        password_input_box.focus = true
                    }
                }

                Button {
                    id: login_button
                    height: parent.height
                    color: "#393939"
                    text: ">"
                    border.color: "#00000000"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: password_input_box.right
                    anchors.right: parent.right
                    disabledColor: "#dc322f"
                    activeColor: "#268bd2"
                    pressedColor: "#2aa198"
                    textColor: config.labelFontColor
                    font: textFont.name

                    onClicked: sddm.login(username_input_box.text, password_input_box.text, session.index)

                    KeyNavigation.backtab: password_input_box
                    KeyNavigation.tab: reboot_button
                }

                Text {
                    id: error_message
                    height: parent.height
                    font.family: textFont.name
                    font.pixelSize: config.errorMsgFontSize
                    font.bold: true
                    //color: "white"
                    anchors.top: password_input_box.bottom
                    anchors.left: password_input_box.left
                    anchors.leftMargin: 0
                }
            }

        }
    }

    // Top Bar
    Rectangle {
        id: actionBar
        z: 20
        width: parent.width
        height: parent.height * 0.04
        anchors.top: parent.top;
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"
        visible: config.showTopBar != "false"

        Row {
            id: row_left
            anchors.left: parent.left
            anchors.margins: 5
            height: parent.height
            spacing: 10

            ComboBox {
                id: session
                width: 145
                height: 20
                anchors.verticalCenter: parent.verticalCenter

                color: "transparent"
                menuColor: "transparent"
                arrowColor: "transparent"
                textColor: "#f3f3f3"
                borderColor: "transparent"
                borderWidth: 0

                font.family: textFont.name
                font.pixelSize: config.actionBarFontSize
                font.bold: true

                rowDelegate: Component {
                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        color: session.textColor
                        font: session.font
                        text: (parent && parent.modelItem && parent.modelItem.name !== undefined) ? parent.modelItem.name : ""
                    }
                }

                model: sessionModel
                index: (sessionModel && sessionModel.lastIndex !== undefined) ? sessionModel.lastIndex : 0

                KeyNavigation.backtab: shutdown_button
                KeyNavigation.tab: password_input_box
            }

            ComboBox {
                id: language
                visible: languageModel.length > 0
                model: languageModel
                index: (keyboard && keyboard.currentLayout !== undefined) ? keyboard.currentLayout : 0
                width: 50
                height: 20
                anchors.verticalCenter: parent.verticalCenter

                color: "transparent"
                menuColor: "transparent"
                arrowColor: "transparent"
                textColor: "#f3f3f3"
                borderColor: "transparent"
                borderWidth: 0

                font.family: textFont.name
                font.pixelSize: config.actionBarFontSize
                font.bold: true

                rowDelegate: Component {
                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        color: language.textColor
                        font: language.font
                        text: (parent && parent.modelItem && parent.modelItem.name !== undefined) ? parent.modelItem.name : ""
                    }
                }

                onValueChanged: {
                    if (keyboard && index >= 0)
                        keyboard.currentLayout = index
                }

                Connections {
                    target: keyboard

                    function onLayoutsChanged() {
                        rebuildLanguageModel()
                    }

                    function onCurrentLayoutChanged() {
                        if (language.index !== keyboard.currentLayout)
                            language.index = keyboard.currentLayout
                    }
                }

                KeyNavigation.backtab: session
                KeyNavigation.tab: username_input_box
            }
        }

        Row {
            id: row_right
            height: parent.height
            anchors.right: parent.right
            anchors.margins: 5
            spacing: 10

            ImageButton {
                id: videoAudioButton
                height: parent.height
                source: Qt.resolvedUrl(container.videoAudioMuted
                    ? "components/resources/volume-muted.svg"
                    : "components/resources/volume-on.svg")

                onClicked: container.videoAudioMuted = !container.videoAudioMuted
                KeyNavigation.backtab: login_button
                KeyNavigation.tab: reboot_button
            }

            ImageButton {
                id: reboot_button
                height: parent.height
                source: Qt.resolvedUrl("components/resources/reboot.svg")

                visible: sddm.canReboot
                onClicked: sddm.reboot()
                KeyNavigation.backtab: videoAudioButton
                KeyNavigation.tab: shutdown_button
            }

            ImageButton {
                id: shutdown_button
                height: parent.height
                source: Qt.resolvedUrl("components/resources/shutdown.svg")
                visible: sddm.canPowerOff
                onClicked: sddm.powerOff()
                KeyNavigation.backtab: reboot_button
                KeyNavigation.tab: session
            }
        }
    }

    Component.onCompleted: {
        previewMode = (typeof Qt.application !== 'undefined'
            && Qt.application.arguments
            && Qt.application.arguments.indexOf('--test-mode') !== -1)

        // Only load a local config override in preview mode; in real SDDM runtime the
        // config is injected by SDDM and should not rely on local XHR access.
        if (previewMode) {
            loadConfigFileSync("theme.conf.user")
        }

        try {
            console.log("runtime theme config:", JSON.stringify(config))
        } catch (e) {
            console.log("runtime theme config: (non-serializable)") 
        }

        primaryVideo.focus = true
        rebuildLanguageModel()

        // load and randomize playlist
        var time = parseInt(new Date().toLocaleTimeString(Qt.locale(),'h'))
        if ( time >= config.dayTimeStart && time <= config.dayTimeEnd ) {
            playRandomVideoList(config.bgVidDay)
            
            if ( config.bgImgDay !== null ) {
                var fileType = config.bgImgDay.substring(config.bgImgDay.lastIndexOf(".") + 1)
                if (fileType === "gif") {
                    animatedBackground.source = config.bgImgDay
                } else {
                    backgroundImage.source = config.bgImgDay
                }
            }
        } else {
            playRandomVideoList(config.bgVidNight)

            if ( config.bgImgNight !== null ) {
                var fileType = config.bgImgNight.substring(config.bgImgNight.lastIndexOf(".") + 1)
                if (fileType === "gif") {
                    animatedBackground.source = config.bgImgNight
                } else {
                    backgroundImage.source = config.bgImgNight
                }
            }
        }

        // Playlist values are pipe-separated URLs supplied through theme config.

        if (config.showLoginButton == "false") {
            login_button.visible = false
            password_input_box.anchors.rightMargin = 0
            clear_passwd_button.anchors.rightMargin = 0
        }
        clear_passwd_button.visible = false
    }
}
