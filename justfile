# SPDX-FileCopyrightText: 2025 Alejandro Salazar <alejandro.s@berkeley.edu>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Convenience recipes for catppuccin-kscreenlocker.
# Requires `just` (https://github.com/casey/just) and Plasma 6.

_default:
    @just --list

# Launch the greeter against the test mirror (no sudo, no system files).
test flavor="mocha" accent="mauve":
    ./install.sh --test --flavor {{flavor}} --accent {{accent}}

# Print the sudo commands install would execute (no writes).
plan flavor="mocha" accent="mauve":
    ./install.sh --flavor {{flavor}} --accent {{accent}}

# Install for real. Overwrites /usr/share/plasma/shells/.../lockscreen.
install flavor="mocha" accent="mauve":
    ./install.sh --flavor {{flavor}} --accent {{accent}} --apply

# Restore the original lockscreen from .bak.
uninstall:
    ./install.sh --uninstall --apply

# List supported flavors and accents.
list:
    @./install.sh --list

# Print the installer version.
version:
    @./install.sh --version

# Run shellcheck against the project's shell scripts (CI parity).
lint:
    shellcheck --severity=warning install.sh palette-data.sh

# Remove the user-local test mirror.
clean:
    rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/plasma/shells/catppuccin-lockscreen"
