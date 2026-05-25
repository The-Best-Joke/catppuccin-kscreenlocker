// SPDX-FileCopyrightText: 2025 Alejandro Salazar <alejandro.s@berkeley.edu>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

import "." as LockScreenLocal

QQC2.Button {
    id: button

    property string iconName: ""
    property int controlSize: 36
    property color buttonColor: LockScreenLocal.CatPalette.red
    property color hoverColor: LockScreenLocal.CatPalette.rosewater

    implicitWidth: controlSize
    implicitHeight: controlSize
    hoverEnabled: true
    display: QQC2.AbstractButton.IconOnly

    contentItem: Kirigami.Icon {
        source: button.iconName
        implicitWidth: Kirigami.Units.iconSizes.smallMedium
        implicitHeight: implicitWidth
        // Treat the SVG as an alpha mask so the `color` recolor applies
        // regardless of the SVG's own fill (currentColor, hardcoded, etc).
        isMask: true
        color: LockScreenLocal.CatPalette.crust
        anchors.centerIn: parent
        visible: button.iconName.length > 0
    }

    background: Rectangle {
        radius: 3
        color: button.down || button.hovered ? button.hoverColor : button.buttonColor

        Behavior on color {
            PropertyAnimation {
                duration: 300
            }
        }
    }

    QQC2.ToolTip.visible: button.hovered && button.text.length > 0
    QQC2.ToolTip.text: button.text.replace("&", "")
    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
}
