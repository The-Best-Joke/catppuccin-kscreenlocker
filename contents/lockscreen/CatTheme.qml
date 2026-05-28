// SPDX-FileCopyrightText: 2025 Alejandro Salazar <alejandro.s@berkeley.edu>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma Singleton

import QtQml
import org.kde.kirigami as Kirigami

QtObject {
    // Bundled SVGs (see contents/lockscreen/icons/). Kirigami.Icon renders
    // these as masks and recolors them via its `color` property, so the
    // SVGs themselves are monochrome (fill="currentColor").
    readonly property url suspendIcon: Qt.resolvedUrl("icons/moon.svg")
    readonly property url hibernateIcon: Qt.resolvedUrl("icons/hibernate.svg")
    readonly property url switchUserIcon: Qt.resolvedUrl("icons/switch-user.svg")

    readonly property int sectionGap: Math.round(Kirigami.Units.gridUnit / 2)
}
