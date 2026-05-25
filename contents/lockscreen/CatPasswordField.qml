// SPDX-FileCopyrightText: 2025 Alejandro Salazar <alejandro.s@berkeley.edu>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

import "." as LockScreenLocal

PlasmaExtras.PasswordField {
    id: passwordField

    property color baseColor: Qt.rgba(LockScreenLocal.CatPalette.surface0.r, LockScreenLocal.CatPalette.surface0.g, LockScreenLocal.CatPalette.surface0.b, 0.25)
    property color focusColor: Qt.rgba(LockScreenLocal.CatPalette.surface1.r, LockScreenLocal.CatPalette.surface1.g, LockScreenLocal.CatPalette.surface1.b, 0.38)
    property color textColor: LockScreenLocal.CatPalette.text
    property color selectionAccent: LockScreenLocal.CatPalette.overlay0
    property color borderColor: Qt.rgba(LockScreenLocal.CatPalette.accent.r, LockScreenLocal.CatPalette.accent.g, LockScreenLocal.CatPalette.accent.b, 0.55)
    property int controlWidth: 260
    property int controlHeight: 36
    property int dotSpacing: 4
    property bool failed: false

    implicitWidth: controlWidth
    implicitHeight: controlHeight
    font.family: LockScreenLocal.ThemeConfig.fontFamily
    font.pointSize: Kirigami.Theme.defaultFont.pointSize
    font.bold: true
    font.letterSpacing: text.length > 0 ? dotSpacing : 0
    color: textColor
    placeholderTextColor: LockScreenLocal.CatPalette.subtext0
    selectionColor: selectionAccent
    selectedTextColor: LockScreenLocal.CatPalette.crust
    horizontalAlignment: TextInput.AlignHCenter
    passwordCharacter: "•"
    renderType: Text.NativeRendering
    rightActions: []

    background: Rectangle {
        id: bg
        implicitWidth: passwordField.controlWidth
        implicitHeight: passwordField.controlHeight
        radius: 3
        property color restingColor: passwordField.activeFocus || passwordField.hovered ? passwordField.focusColor : passwordField.baseColor
        color: restingColor
        border.width: passwordField.failed ? 2 : 1
        border.color: passwordField.failed ? LockScreenLocal.CatPalette.red : passwordField.borderColor

        Behavior on color {
            PropertyAnimation {
                duration: 300
            }
        }

        ColorAnimation {
            id: bgDim
            target: bg
            property: "color"
            to: Qt.tint(bg.restingColor, Qt.rgba(LockScreenLocal.CatPalette.accent.r, LockScreenLocal.CatPalette.accent.g, LockScreenLocal.CatPalette.accent.b, 0.18))
            duration: 60
        }

        ColorAnimation {
            id: bgLift
            target: bg
            property: "color"
            to: bg.restingColor
            duration: 200
        }

        Rectangle {
            id: borderHalo
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: LockScreenLocal.CatPalette.accent
            border.width: 0
            opacity: 0
        }

        ParallelAnimation {
            id: haloOn
            NumberAnimation { target: borderHalo; property: "opacity"; to: 1.0; duration: 70 }
            NumberAnimation { target: borderHalo; property: "border.width"; to: 1; duration: 70 }
        }

        ParallelAnimation {
            id: haloOff
            NumberAnimation { target: borderHalo; property: "opacity"; to: 0; duration: 240 }
            NumberAnimation { target: borderHalo; property: "border.width"; to: 0; duration: 240 }
        }
    }

    ColorAnimation {
        id: textDim
        target: passwordField
        property: "color"
        to: Qt.rgba(LockScreenLocal.CatPalette.text.r, LockScreenLocal.CatPalette.text.g, LockScreenLocal.CatPalette.text.b, 0.25)
        duration: 70
    }

    ColorAnimation {
        id: textLift
        target: passwordField
        property: "color"
        to: passwordField.textColor
        duration: 220
    }

    Timer {
        id: idleTimer
        interval: 250
        repeat: false
        onTriggered: {
            textLift.start()
            bgLift.start()
            haloOff.start()
        }
    }

    function dim() {
        textLift.stop(); textDim.restart()
        bgLift.stop();   bgDim.restart()
        haloOff.stop();  haloOn.restart()
    }

    function liftNow() {
        idleTimer.stop()
        textDim.stop(); textLift.restart()
        bgDim.stop();   bgLift.restart()
        haloOn.stop();  haloOff.restart()
    }

    onTextChanged: {
        if (text.length > 0) {
            dim()
            idleTimer.restart()
        } else {
            liftNow()
        }
    }

    onActiveFocusChanged: if (!activeFocus) liftNow()
}
