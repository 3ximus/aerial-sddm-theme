import QtQuick

Item {
    id: overlayFader
    property Item content
    property real overlayOpacity: 0
    state: "off"
    z: 1

    Behavior on overlayOpacity {
        NumberAnimation { target: overlayFader; property: "overlayOpacity"; duration: 1000; easing.type: Easing.InOutQuad }
    }

    states: [
        State {
            name: "on"
            PropertyChanges { target: content; opacity: 1 }
            PropertyChanges { target: overlayFader; overlayOpacity: 1 }
        },
        State {
            name: "off"
            PropertyChanges { target: content; opacity: 0 }
            PropertyChanges { target: overlayFader; overlayOpacity: 0 }
        }
    ]

    transitions: [
        Transition {
            from: "off"
            to: "on"
            NumberAnimation { target: content; property: "opacity"; duration: 500 }
        },
        Transition {
            from: "on"
            to: "off"
            NumberAnimation { target: content; property: "opacity"; duration: 500 }
        }
    ]

    Rectangle {
        anchors.fill: parent
        z: 2
        visible: overlayFader.overlayOpacity > 0
        color: "#000000"
        opacity: overlayFader.overlayOpacity * 0.7
    }
}