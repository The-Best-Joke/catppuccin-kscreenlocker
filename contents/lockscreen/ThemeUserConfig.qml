// SPDX-FileCopyrightText: 2025 Alejandro Salazar <alejandro.s@berkeley.edu>
// SPDX-License-Identifier: GPL-2.0-or-later
//
// =============================================================
//  >>>  EDIT THIS FILE TO CONFIGURE THE CATPPUCCIN LOCKSCREEN  <<<
//
//  This is the ONLY file you need to touch. Change a value to
//  the right of a colon (`true` or `false`) and re-lock the
//  screen. Do not add quotes; these are real booleans.
//
//  After editing here, re-run `./install.sh --apply` from the
//  repo. Editing the installed copy under /usr/share/ directly
//  works too but requires sudo and is overwritten on next apply.
// =============================================================

import QtQml

QtObject {
    // Font family for all lockscreen text.
    // Empty string ("") = use the system default font (Kirigami).
    // For the intended look, install "JetBrainsMono Nerd Font" and
    // set it here. Any installed font family name will work.
    property string fontFamily: ""

    // Show the clock at all.
    property bool showClock: true

    // Only show the clock while the unlock UI is visible.
    property bool showClockOnlyWhenUiVisible: false

    // Show the keyboard-layout label (only appears with >1 layout).
    property bool showLayoutLabel: false

    // Show the user's avatar image.
    property bool showUserImage: true

    // Show media playback controls when something is playing.
    property bool showMediaControls: true
}
