/*
    SPDX-FileCopyrightText: 2014 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Window

import "." as LockScreenLocal
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    id: wrapper

    // If we're using software rendering, draw outlines instead of shadows
    // See https://bugs.kde.org/show_bug.cgi?id=398317
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    property bool isCurrent: true

    property string name
    property string userName
    property string avatarPath
    property string iconSource
    property bool needsPassword
    property var vtNumber
    property bool constrainText: true
    property bool showAvatar: true
    property alias nameFontSize: usernameDelegate.font.pointSize
    property real fontSize: Kirigami.Theme.defaultFont.pointSize + 2
    signal clicked()

    property real faceSize: Kirigami.Units.gridUnit * 7

    opacity: isCurrent ? 1.0 : 0.75

    Behavior on opacity {
        OpacityAnimator {
            duration: Kirigami.Units.longDuration
        }
    }

    // Draw a translucent background circle under the user picture
    Rectangle {
        visible: wrapper.showAvatar
        anchors.centerIn: imageSource
        width: imageSource.width - 2 // Subtract to prevent fringing
        height: width
        radius: width / 2

        color: Kirigami.Theme.backgroundColor
        opacity: 0.6
    }

    Item {
        id: imageSource
        visible: wrapper.showAvatar
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        Behavior on width {
            PropertyAnimation {
                from: wrapper.faceSize
                duration: Kirigami.Units.longDuration;
            }
        }
        width: wrapper.isCurrent ? wrapper.faceSize : wrapper.faceSize - Kirigami.Units.gridUnit
        height: wrapper.showAvatar ? width : 0

        LockScreenLocal.CatAvatar {
            visible: wrapper.showAvatar
            anchors.fill: parent
            source: wrapper.avatarPath
            avatarSize: imageSource.width
        }
    }

    ShaderEffect {
        visible: wrapper.showAvatar
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: imageSource.width
        height: imageSource.height

        supportsAtlasTextures: true

        readonly property Item source: ShaderEffectSource {
            sourceItem: imageSource
            // software rendering is just a fallback so we can accept not having a rounded avatar here
            hideSource: wrapper.GraphicsInfo.api !== GraphicsInfo.Software
            live: true // otherwise the user in focus will show a blurred avatar
        }

        readonly property color colorBorder: Kirigami.Theme.textColor

        fragmentShader: "qrc:/qt/qml/org/kde/breeze/components/shaders/UserDelegate.frag.qsb"
    }

    PlasmaComponents3.Label {
        id: usernameDelegate

        anchors.top: wrapper.showAvatar ? imageSource.bottom : parent.top
        anchors.topMargin: wrapper.showAvatar ? Kirigami.Units.gridUnit : 0
        anchors.horizontalCenter: parent.horizontalCenter

        font.family: LockScreenLocal.ThemeConfig.fontFamily
        font.pointSize: wrapper.fontSize + 1

        width: wrapper.constrainText ? parent.width : undefined
        text: wrapper.name
        textFormat: Text.PlainText
        style: wrapper.softwareRendering ? Text.Outline : Text.Normal
        styleColor: wrapper.softwareRendering ? Kirigami.Theme.backgroundColor : "transparent" //no outline, doesn't matter
        wrapMode: Text.WordWrap
        maximumLineCount: wrapper.constrainText ? 3 : 1
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        //make an indication that this has active focus, this only happens when reached with keyboard navigation
        font.underline: wrapper.activeFocus
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onClicked: wrapper.clicked()
    }

    Keys.onSpacePressed: wrapper.clicked()

    Accessible.name: name
    Accessible.role: Accessible.Button
    function accessiblePressAction() { wrapper.clicked() }
}
