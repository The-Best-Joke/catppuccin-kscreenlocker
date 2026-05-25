// SPDX-FileCopyrightText: 2025 Alejandro Salazar <alejandro.s@berkeley.edu>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma Singleton

import QtQml
import org.kde.kirigami as Kirigami

QtObject {
    readonly property string suspendIcon: "system-suspend"
    readonly property string hibernateIcon: "system-suspend-hibernate"
    readonly property string switchUserIcon: "system-switch-user"
    readonly property int sectionGap: Math.round(Kirigami.Units.gridUnit / 2)
}
