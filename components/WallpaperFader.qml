/********************************************************************
 This file is part of the KDE project.

Copyright (C) 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*********************************************************************/

import QtQuick 2.6
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

Item {
    id: wallpaperFader
    property Item mainStack
    property Item footer
    property alias source: wallpaperBlur.source
    state: lockScreenRoot.uiVisible ? "on" : "off"
    property real factor: 20

    Behavior on factor {
        NumberAnimation {
            target: wallpaperFader
            property: "factor"
            duration: 1000
            easing.type: Easing.InOutQuad
        }
    }
    FastBlur {
        id: wallpaperBlur
        anchors.fill: parent
        radius: 50 * wallpaperFader.factor
    }
    ShaderEffect {
        id: wallpaperShader
        anchors.fill: parent
        supportsAtlasTextures: true
        property var source: ShaderEffectSource {
            sourceItem: wallpaperBlur
            live: true
            hideSource: true
            textureMirroring: ShaderEffectSource.NoMirroring
        }

        readonly property real contrast: 0.45 * wallpaperFader.factor + (1 - wallpaperFader.factor)
        readonly property real saturation: 1.7 * wallpaperFader.factor + (1 - wallpaperFader.factor)
        readonly property real intensity: wallpaperFader.factor + (1 - wallpaperFader.factor)

        property var colorMatrix: Qt.matrix4x4(
            contrast, 0,        0,        0.0,
            0,        contrast, 0,        0.0,
            0,        0,        contrast, 0.0,
            0,        0,        0,        1.0).times(Qt.matrix4x4(
                saturation, 0.0,          0.0,        0.0,
                0,          saturation,   0,          0.0,
                0,          0,            saturation, 0.0,
                0,          0,            0,          1.0)).times(Qt.matrix4x4(
                    intensity, 0,         0,         0,
                    0,         intensity, 0,         0,
                    0,         0,         intensity, 0,
                    0,         0,         0,         1
                ));
    

        fragmentShader: "
            uniform mediump mat4 colorMatrix;
            uniform mediump sampler2D source;
            varying mediump vec2 qt_TexCoord0;
            uniform lowp float qt_Opacity;

            void main(void)
            {
                mediump vec4 tex = texture2D(source, qt_TexCoord0);
                gl_FragColor = tex * colorMatrix * qt_Opacity;
            }"
    }

    states: [
        State {
            name: "on"
            PropertyChanges {
                target: mainStack
                opacity: 1
            }
            PropertyChanges {
                target: footer
                opacity: 1
            }
            PropertyChanges {
                target: wallpaperFader
                factor: 1
            }
        },
        State {
            name: "off"
            PropertyChanges {
                target: mainStack
                opacity: 0
            }
            PropertyChanges {
                target: footer
                opacity: 0
            }
            PropertyChanges {
                target: wallpaperFader
                factor: 0
            }
        }
    ]
    transitions: [
        Transition {
            from: "off"
            to: "on"
            //Note: can't use animators as they don't play well with parallelanimations
            ParallelAnimation {
                NumberAnimation {
                    target: mainStack
                    property: "opacity"
                    duration: units.longDuration
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: footer
                    property: "opacity"
                    duration: units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        },
        Transition {
            from: "on"
            to: "off"
            ParallelAnimation {
                NumberAnimation {
                    target: mainStack
                    property: "opacity"
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: footer
                    property: "opacity"
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
        }
    ]
}
