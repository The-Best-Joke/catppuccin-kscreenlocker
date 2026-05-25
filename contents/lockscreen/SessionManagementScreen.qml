/*
    SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick

import QtQuick.Layouts

import "." as LockScreenLocal
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

FocusScope {
    id: root

    /*
     * Any message to be displayed to the user, visible above the text fields.
     * Currently used to surface the Caps Lock state.
     */
    property alias notificationMessage: notificationsLabel.text

    /*
     * A list of Items (typically ActionButtons) to be shown in a Row beneath the prompts
     */
    property alias actionItems: actionItemsLayout.children

    /*
     * Whether to show or hide the list of action items as a whole.
     */
    property alias actionItemsVisible: actionItemsLayout.visible

    /*
     * A model with a list of users to show in the view.
     * There are different implementations in sddm greeter (UserModel) and
     * KScreenLocker (SessionsModel), so some roles will be missing.
     *
     * type: {
     *  name: string,
     *  realName: string,
     *  homeDir: string,
     *  icon: string,
     *  iconName?: string,
     *  needsPassword?: bool,
     *  displayNumber?: string,
     *  vtNumber?: int,
     *  session?: string
     *  isTty?: bool,
     * }
     */
    property alias userListModel: userListView.model
    property bool showUserAvatar: true

    /*
     * Self explanatory
     */
    property alias userListCurrentIndex: userListView.currentIndex
    property alias userListCurrentItem: userListView.currentItem
    property bool showUserList: true

    property alias userList: userListView

    property real fontSize: Kirigami.Theme.defaultFont.pointSize + 2

    default property alias _children: innerLayout.children

    signal userSelected()

    // FIXME: move this component into a layout, rather than abusing
    // anchors and implicitly relying on other components' built-in
    // whitespace to avoid items being overlapped.
    UserList {
        id: userListView
        visible: root.showUserList && y > 0
        showAvatar: root.showUserAvatar
        anchors {
            bottom: parent.verticalCenter
            // We only need an extra bottom margin when text is constrained,
            // since only in this case can the username label be a multi-line
            // string that would otherwise overflow.
            bottomMargin: constrainText ? Math.round(Kirigami.Units.gridUnit * 1.5) : 0
            left: parent.left
            right: parent.right
        }
        fontSize: root.fontSize
        // bubble up the signal
        onUserSelected: root.userSelected()
    }

    //goal is to show the prompts, in ~16 grid units high, then the action buttons
    //but collapse the space between the prompts and actions if there's no room
    //ui is constrained to 16 grid units wide, or the screen
    ColumnLayout {
        id: prompts
        spacing: LockScreenLocal.CatTheme.sectionGap
        anchors.top: parent.verticalCenter
        anchors.topMargin: LockScreenLocal.CatTheme.sectionGap
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        PlasmaComponents3.Label {
            id: notificationsLabel
            visible: text.length > 0
            font.pointSize: root.fontSize
            Layout.maximumWidth: Kirigami.Units.gridUnit * 16
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.PlainText
            wrapMode: Text.WordWrap
            font.italic: true
        }
        ColumnLayout {
            id: innerLayout
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.maximumWidth: Kirigami.Units.gridUnit * 16
            Layout.maximumHeight: Kirigami.Units.gridUnit * 10
        }
        Item {
            Layout.alignment: Qt.AlignHCenter
            implicitHeight: actionItemsLayout.implicitHeight
            implicitWidth: actionItemsLayout.implicitWidth
            GridLayout {
                id: actionItemsLayout
                anchors.centerIn: parent

                readonly property int spacing: Kirigami.Units.largeSpacing
                rowSpacing: spacing
                columnSpacing: spacing

                readonly property int buttonCount: visibleChildren.length
                readonly property int singleRowWidth: (children[0].implicitWidth * buttonCount) + (spacing * (buttonCount - 1))
                columns: singleRowWidth < root.width ? buttonCount : Math.ceil(buttonCount / 2)
            }
        }
        Item {
            Layout.fillHeight: true
        }
    }
}
