// SPDX-FileCopyrightText: 2025 Alejandro Salazar <alejandro.s@berkeley.edu>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

import "." as LockScreenLocal

QQC2.Button {
    id: button

    property int controlWidth: 260
    property int controlHeight: 36

    implicitWidth: controlWidth
    implicitHeight: controlHeight
    hoverEnabled: true
    flat: true
    padding: 0
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    contentItem: Text {
        id: buttonText
        renderType: Text.NativeRendering
        text: button.text
        color: LockScreenLocal.CatPalette.crust
        font.family: LockScreenLocal.ThemeConfig.fontFamily
        font.pointSize: Kirigami.Theme.defaultFont.pointSize
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        id: buttonBackground
        radius: 3
        color: LockScreenLocal.CatPalette.accent

        states: [
            State {
                name: "pressed"
                when: button.down
                PropertyChanges {
                    target: buttonBackground
                    color: Qt.darker(LockScreenLocal.CatPalette.accent, 1.2)
                }
            },
            State {
                name: "hovered"
                when: button.hovered
                PropertyChanges {
                    target: buttonBackground
                    color: Qt.lighter(LockScreenLocal.CatPalette.accent, 1.15)
                }
            }
        ]

        Behavior on color {
            PropertyAnimation {
                duration: 300
            }
        }
    }
}
