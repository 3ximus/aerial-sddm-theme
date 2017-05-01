import QtQuick 2.0
import SddmComponents 2.0
import QtMultimedia 5.8

Rectangle {
    // Main Container
    id: container
    //width: 1920
    //height: 1080

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    // Inherited from SDDMComponents
    TextConstants {
        id: textConstants
    }

    // Set SDDM actions
    Connections {
        target: sddm
        onLoginSucceeded: {
        }

        onLoginFailed: {
            error_message.color = "#dc322f"
            error_message.text = textConstants.loginFailed
        }
    }

    // Set Font

    FontLoader {
        id: textFont; name: config.displayFont
    }

    // Set Background Image
    Repeater {
        model: screenModel
        Background {
            id: background
            x: geometry.x; y: geometry.y; width: geometry.width; height:geometry.height
            source: config.background
            fillMode: Image.PreserveAspectCrop
            onStatusChanged: {
                if (status == Image.Error && source != config.defaultBackground) {
                    source = config.defaultBackground
                }
            }
        }
    }

    // Set Background Video
    MediaPlayer {
        id: mediaplayer
        autoPlay: true
        muted: true
        playlist: Playlist {
            id: playlist
            playbackMode: Playlist.Random
            onLoaded: {
                mediaplayer.play()
            }
        }
    }

    VideoOutput {
        fillMode: VideoOutput.PreserveAspectCrop
        anchors.fill: parent
        source: mediaplayer
    }

    MouseArea {
        anchors.fill: parent;
        onPressed: {
            playlist.shuffle();
            playlist.next();
        }
    }

    // Clock and Login Area
    Rectangle {
        id: rectangle
        anchors.fill: parent
        color: "transparent"

        Clock {
            id: clock
            y: parent.height * 0.60
            color: "white"
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.1
            timeFont.family: textFont.name
            dateFont.family: textFont.name
        }

        Rectangle {
            id: login_container

            //y: parent.height * 0.8
            y: clock.y + clock.height + 30
            width: clock.width
            height: parent.height * 0.08
            color: "transparent"
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.1

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
                    font.bold: true
                    font.pixelSize: 16
                    color: "white"
                    text: "Username"
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextBox {
                    id: username_input_box
                    height: parent.height
                    text: userModel.lastUser
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: username_label.right
                    anchors.leftMargin: 0
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    font: textFont.name
                    color: "#25000000"
                    borderColor: "transparent"
                    textColor: "white"

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(username_input_box.text, password_input_box.text, session.index)
                            event.accepted = true
                        }
                    }

                    KeyNavigation.backtab: password_input_box; KeyNavigation.tab: password_input_box
                }

                Text {
                    id: error_message
                    height: parent.height
                    font.family: textFont.name
                    font.pixelSize: 12
                    color: "white"
                    anchors.left: username_input_box.left
                    anchors.leftMargin: 0
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
                    font.pixelSize: 16
                    color: "white"
                }

                PasswordBox {
                    id: password_input_box
                    height: parent.height
                    font: textFont.name
                    color: "#25000000"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: parent.height // this sets button width, this way its a square
                    anchors.left: password_label.right
                    anchors.leftMargin: 0
                    borderColor: "transparent"
                    textColor: "white"
                    tooltipBG: "#25000000"
                    tooltipFG: "#dc322f"
                    image: "warning_red.png"

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(username_input_box.text, password_input_box.text, session.index)
                            event.accepted = true
                        }
                    }

                    KeyNavigation.backtab: username_input_box; KeyNavigation.tab: login_button
                }

                Button {
                    id: login_button
                    height: parent.height
                    color: "#393939"
                    text: ">"
                    anchors.verticalCenter: parent.verticalCenter
                    border.color: "#00000000"
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.left: password_input_box.right
                    anchors.leftMargin: 0
                    disabledColor: "#dc322f"
                    activeColor: "#268bd2"
                    pressedColor: "#2aa198"
                    textColor: "white"
                    font: textFont.name

                    onClicked: sddm.login(username_input_box.text, password_input_box.text, session.index)

                    KeyNavigation.backtab: password_input_box; KeyNavigation.tab: reboot_button
                }
            }

        }

    }

    // Top Bar
    Rectangle {
        id: actionBar
        width: parent.width
        height: parent.height * 0.04
        anchors.top: parent.top;
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"

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
                arrowColor: "transparent"
                textColor: "white"
                borderColor: "transparent"
                hoverColor: "#5692c4"

                model: sessionModel
                index: sessionModel.lastIndex

                KeyNavigation.backtab: shutdown_button; KeyNavigation.tab: password_input_box
            }

            ComboBox {
                id: language

                model: keyboard.layouts
                index: keyboard.currentLayout
                width: 50
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"
                arrowColor: "transparent"
                textColor: "white"
                borderColor: "transparent"
                hoverColor: "#5692c4"

                onValueChanged: keyboard.currentLayout = id

                Connections {
                    target: keyboard

                    onCurrentLayoutChanged: combo.index = keyboard.currentLayout
                }

                rowDelegate: Rectangle {
                    color: "transparent"

                    Text {
                        anchors.margins: 4
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        verticalAlignment: Text.AlignVCenter

                        text: modelItem ? modelItem.modelData.shortName : "zz"
                        font.family: textFont.name
                        font.pixelSize: 14
                        color: "white"
                    }
                }
                KeyNavigation.backtab: session; KeyNavigation.tab: username_input_box
            }
        }

        Row {
            id: row_right
            height: parent.height
            anchors.right: parent.right
            anchors.margins: 5
            spacing: 10

            ImageButton {
                id: reboot_button
                height: parent.height
                source: "reboot.svg"

                visible: sddm.canReboot
                onClicked: sddm.reboot()
                KeyNavigation.backtab: login_button; KeyNavigation.tab: shutdown_button
            }

            ImageButton {
                id: shutdown_button
                height: parent.height
                source: "shutdown.svg"
                visible: sddm.canPowerOff
                onClicked: sddm.powerOff()
                KeyNavigation.backtab: reboot_button; KeyNavigation.tab: session
            }
        }
    }

    Component.onCompleted: {
        // Set Focus
        if (username_input_box.text == "")
            username_input_box.focus = true
        else
            password_input_box.focus = true

        // load and randomize playlist
        var time = parseInt(new Date().toLocaleTimeString(Qt.locale(),'h'))
        if ( time >= 5 && time <= 17 )
            playlist.load(Qt.resolvedUrl(config.background_day), 'm3u')
        else
            playlist.load(Qt.resolvedUrl(config.background_night), 'm3u')

        for (var k = 0; k < Math.ceil(Math.random() * 10) ; k++) {
            playlist.shuffle()
        }
    }
}

