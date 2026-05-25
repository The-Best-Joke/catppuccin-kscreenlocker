// =============================================================
//  >>>  EDIT THIS FILE TO CONFIGURE THE CATPPUCCIN LOCKSCREEN  <<<
//
//  This is the ONLY file you need to touch. Change a value to
//  the right of a colon (`true` or `false`) and re-lock the
//  screen. Do not add quotes; these are real booleans.
// =============================================================

import QtQml

QtObject {
    // Font family for all lockscreen text.
    // Leave as an empty string ("") to use the system default font.
    property string fontFamily: "JetBrainsMono Nerd Font"

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
