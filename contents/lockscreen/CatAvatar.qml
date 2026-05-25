import QtQuick

Item {
    id: avatar

    property url source
    property int avatarSize: 100

    implicitWidth: avatarSize
    implicitHeight: avatarSize

    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("assets/defaultIcon.png")
        fillMode: Image.PreserveAspectCrop
    }

    Image {
        anchors.fill: parent
        source: avatar.source
        fillMode: Image.PreserveAspectCrop
        visible: source.toString().length > 0
    }

    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("assets/mask.svg")
    }

    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("assets/ring.svg")
    }
}
