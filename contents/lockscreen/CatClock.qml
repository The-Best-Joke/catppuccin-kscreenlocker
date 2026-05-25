import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import "." as LockScreenLocal

ColumnLayout {
    id: clock

    property date currentTime: new Date()
    property color textColor: LockScreenLocal.CatPalette.text

    spacing: Kirigami.Units.smallSpacing

    PlasmaComponents3.Label {
        Layout.alignment: Qt.AlignRight
        text: Qt.formatTime(clock.currentTime, "hh:mm")
        color: clock.textColor
        font.family: LockScreenLocal.ThemeConfig.fontFamily
        font.pointSize: 64
        font.bold: true
        renderType: Text.NativeRendering
    }

    PlasmaComponents3.Label {
        Layout.alignment: Qt.AlignRight
        text: Qt.formatDate(clock.currentTime, "dddd, dd MMMM yyyy")
        color: clock.textColor
        font.family: LockScreenLocal.ThemeConfig.fontFamily
        font.pointSize: 18
        font.bold: true
        renderType: Text.NativeRendering
    }
}
