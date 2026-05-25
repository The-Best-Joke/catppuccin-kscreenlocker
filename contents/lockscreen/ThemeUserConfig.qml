// SPDX-FileCopyrightText: 2025 Alejandro Salazar <alejandro.s@berkeley.edu>
// SPDX-License-Identifier: GPL-2.0-or-later
//
// =============================================================
//  >>>  EDIT THIS FILE TO CONFIGURE THE CATPPUCCIN LOCKSCREEN  <<<
//
//  These are the toggles that DON'T have a corresponding setting
//  in System Settings -> Workspace -> Screen Locking. Everything
//  else (show clock, hide clock when idle, show media controls)
//  is read from KDE directly -- change those in System Settings.
//
//  Change a value to the right of a colon and re-run
//  `./install.sh --apply` from the repo. (Editing the installed
//  copy under /usr/share/ directly works but requires sudo and is
//  overwritten on the next install.)
// =============================================================

import QtQml

QtObject {
    // Font family for all lockscreen text.
    // Empty string ("") = use the system default font (Kirigami).
    // For the intended look, install "JetBrainsMono Nerd Font" and
    // set it here. Any installed font family name will work.
    property string fontFamily: ""

    // Show the keyboard-layout label (only appears with >1 layout).
    property bool showLayoutLabel: false

    // Show the user's avatar image.
    property bool showUserImage: true
}
