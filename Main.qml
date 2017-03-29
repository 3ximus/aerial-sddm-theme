import QtQuick 2.0
import SddmComponents 2.0
import QtMultimedia 5.8

Rectangle {
    // Main Container
    id: container
    width: 1920
    height: 1080

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
		loops: MediaPlayer.Infinite
		source: config.background
		muted: true
	}

	VideoOutput {
		fillMode: VideoOutput.PreserveAspectCrop
		anchors.fill: parent
		source: mediaplayer
	}

    // Clock and Login Area
    Rectangle {
        id: rectangle
        anchors.fill: parent
        color: "transparent"

        Rectangle {
            id: login_container
            y: 566
            width: parent.width * 0.3
            height: parent.height * 0.2
            color: "transparent"
            anchors.left: parent.left
            anchors.leftMargin: 174

            Row {
                id: username_row
                anchors.right: parent.right
                anchors.rightMargin: 100
                anchors.left: parent.left
                anchors.leftMargin: 100
                transformOrigin: Item.Center
                anchors.margins: 10
                spacing: 10

                Text {
                    id: username_label
                    width: 376
                    text: textConstants.userName
                    horizontalAlignment: Text.AlignHCenter
                    font.family: textFont.name
                    font.bold: true
                    font.pixelSize: 16
                    color: "white"
                }

                TextBox {
                    id: username_input_box
                    width: parent.width
                    text: userModel.lastUser
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

                    KeyNavigation.backtab: layoutBox; KeyNavigation.tab: password_input_box
                }

                Text {
                    id: error_message
                    font.family: textFont.name
                    font.pixelSize: 12
                    color: "white"
                    anchors.left: username_input_box.left
                    anchors.leftMargin: 376
                }
            }

            Row {
                id: password_row
                anchors.right: parent.right
                anchors.rightMargin: 100
                anchors.left: parent.left
                anchors.leftMargin: 100
                anchors.top: username_row.bottom
                anchors.topMargin: 10
                spacing: 10

                Text {
                    id: password_label
                    width: parent.width
                    text: textConstants.password
                    horizontalAlignment: Text.AlignHCenter
                    font.family: textFont.name
                    font.bold: true
                    font.pixelSize: 16
                    color: "white"
                }

                PasswordBox {
                    id: password_input_box
                    width: parent.width
                    font: textFont.name
                    color: "#25000000"
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
            }

            Button {
                id: login_button
                text: textConstants.login
                anchors.top: password_input_box.bottom
                anchors.topMargin: 5
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                color: "#404753"
                disabledColor: "#dc322f"
                activeColor: "#268bd2"
                pressedColor: "#2aa198"
                textColor: "white"
                font: textFont.name

                onClicked: sddm.login(username_input_box.text, password_input_box.text, session.index)

                KeyNavigation.backtab: password_input_box; KeyNavigation.tab: reboot_button
            }

        }

        Clock {
            id: clock
            y: 405
            color: "white"
            anchors.left: parent.left
            anchors.leftMargin: 268
            timeFont.family: textFont.name
            dateFont.family: textFont.name
        }
    }

    // Top Bar
    Rectangle {
        id: actionBar
        anchors.top: parent.top;
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width; height: 40
        color: "transparent"

        Row {
            id: row_left
            anchors.left: parent.left
            anchors.margins: 5
            height: parent.height
            spacing: 10

            Text {
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter

                font.family: textFont.name
                verticalAlignment: Text.AlignVCenter
                color: "transparent"
            }

            ComboBox {
                id: session
                width: 145
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"
                textColor: "white"
                borderColor: "transparent"
                hoverColor: "#073642"
                arrowColor: "#25000000"

                model: sessionModel
                index: sessionModel.lastIndex

                KeyNavigation.backtab: shutdown_button; KeyNavigation.tab: layoutBox
            }

            Text {
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter

                font.family: textFont.name
                font.pixelSize: 16
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                color: "white"
            }

            ComboBox {
                id: language

                model: keyboard.layouts
                index: keyboard.currentLayout
                width: 50
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"
                textColor: "white"
                borderColor: "transparent"
                hoverColor: "#073642"
                arrowIcon: "arrow.svg"
                arrowColor: "#25000000"

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


    // Set Focus
    Component.onCompleted: {
        if (username_input_box.text == "")
            username_input_box.focus = true
        else
            password_input_box.focus = true
    }
}

