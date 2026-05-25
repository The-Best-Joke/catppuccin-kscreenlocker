#!/usr/bin/env bash
# Install a Catppuccin lockscreen by overwriting the system
# org.kde.plasma.desktop shell package's lockscreen/ directory. That is
# the only path kscreenlocker actually loads on Plasma 6.x -- the
# [Greeter]Theme= key in kscreenlockerrc is dead for the real lock flow.
# See CLAUDE.md ("How the lockscreen is actually loaded") for the
# investigation that established this.
#
# All destructive operations require --apply. Without it, the script
# prints the sudo commands it would run instead of running them.
#
# Run with --help for options.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=palette-data.sh
source "$SCRIPT_DIR/palette-data.sh"

TARGET="/usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen"
BACKUP="${TARGET}.bak"

# Test mirror -- a user-local Plasma/Shell package the greeter can load
# in `--testing --shell` mode without touching the system shell. Built
# on demand by `--test`. Not for distribution, not committed to the repo.
TEST_SHELL_ID="catppuccin-lockscreen"
TEST_SHELL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/shells/${TEST_SHELL_ID}"
GREETER_BIN="/usr/libexec/kscreenlocker_greet"

usage() {
    cat <<EOF
Usage: $(basename "$0") [--flavor FLAVOR] [--accent ACCENT] [--apply]
       $(basename "$0") --test [--flavor FLAVOR] [--accent ACCENT]
       $(basename "$0") --uninstall [--apply]
       $(basename "$0") --list
       $(basename "$0") --help

Flavors: ${FLAVORS[*]}
Accents: ${ACCENTS[*]}

Defaults: --flavor mocha --accent mauve

Without --apply this script is a dry run -- it prints the sudo commands
it would execute. Pass --apply to actually perform the install. You will
be prompted for your sudo password.

--test syncs the current repo state + chosen palette into a user-local
shell package at:
    $TEST_SHELL_DIR
and launches the greeter in a window via:
    $GREETER_BIN --testing --shell $TEST_SHELL_ID
No sudo, no system files touched. Use to preview before --apply.

Install target: $TARGET
Backup:         $BACKUP

The original system lockscreen is backed up once on first install. The
backup is preserved across reinstalls and is restored by --uninstall.
EOF
}

contains() {
    local needle="$1"; shift
    for x in "$@"; do [[ "$x" == "$needle" ]] && return 0; done
    return 1
}

title() {
    local s="$1"
    printf '%s%s' "$(printf '%s' "${s:0:1}" | tr '[:lower:]' '[:upper:]')" "${s:1}"
}

prompt_choice() {
    local label="$1"; shift
    local default="$1"; shift
    local choices=("$@")
    local answer
    printf '%s [%s] (options: %s): ' "$label" "$default" "${choices[*]}" >&2
    read -r answer
    answer="${answer:-$default}"
    if ! contains "$answer" "${choices[@]}"; then
        printf 'Invalid choice: %s\n' "$answer" >&2
        exit 1
    fi
    printf '%s' "$answer"
}

write_palette_qml() {
    local flavor="$1" accent="$2" target="$3"
    cat >"$target" <<EOF
pragma Singleton

import QtQuick

QtObject {
    readonly property color base:     "$(palette_get "$flavor" base)"
    readonly property color mantle:   "$(palette_get "$flavor" mantle)"
    readonly property color crust:    "$(palette_get "$flavor" crust)"
    readonly property color surface0: "$(palette_get "$flavor" surface0)"
    readonly property color surface1: "$(palette_get "$flavor" surface1)"
    readonly property color overlay0: "$(palette_get "$flavor" overlay0)"
    readonly property color subtext0: "$(palette_get "$flavor" subtext0)"
    readonly property color text:     "$(palette_get "$flavor" text)"

    readonly property color accent:    "$(palette_get "$flavor" "$accent")"
    readonly property color red:       "$(palette_get "$flavor" red)"
    readonly property color rosewater: "$(palette_get "$flavor" rosewater)"
}
EOF
}

# Run a privileged command, or print it in dry-run mode.
run_sudo() {
    if [[ "$APPLY" -eq 1 ]]; then
        printf '  $ sudo %s\n' "$*"
        sudo "$@"
    else
        printf '  [dry-run] sudo %s\n' "$*"
    fi
}

ensure_target_exists() {
    if [[ ! -d "$TARGET" ]]; then
        printf 'Error: %s does not exist.\n' "$TARGET" >&2
        printf 'Is org.kde.plasma.desktop installed? (package: plasma-workspace)\n' >&2
        exit 1
    fi
}

install_theme() {
    local flavor="$1" accent="$2"
    local id="Catppuccin-$(title "$flavor")-$(title "$accent")"

    ensure_target_exists

    printf 'Installing %s\n' "$id"
    printf '  source: %s/contents/lockscreen\n' "$SCRIPT_DIR"
    printf '  target: %s\n' "$TARGET"
    if [[ "$APPLY" -ne 1 ]]; then
        printf '\nDRY RUN -- nothing will be written. Re-run with --apply.\n'
    fi
    printf '\n'

    local stage
    stage="$(mktemp -d -t catppuccin-lockscreen.XXXXXX)"
    # Expand $stage now so the trap survives this function's scope under set -u.
    # mktemp output has no shell metacharacters, so the literal interpolation is safe.
    trap "rm -rf -- '$stage'" EXIT
    cp -r "$SCRIPT_DIR/contents/lockscreen/." "$stage/"
    write_palette_qml "$flavor" "$accent" "$stage/CatPalette.qml"

    if [[ ! -d "$BACKUP" ]]; then
        printf 'Backing up original lockscreen:\n'
        run_sudo cp -rp "$TARGET" "$BACKUP"
    else
        printf 'Backup already exists at %s -- not overwriting.\n' "$BACKUP"
    fi

    printf '\nReplacing %s:\n' "$TARGET"
    run_sudo rm -rf "$TARGET"
    run_sudo cp -r "$stage" "$TARGET"
    run_sudo chmod -R 755 "$TARGET"

    printf '\n'
    if [[ "$APPLY" -eq 1 ]]; then
        printf 'Done. Test before locking:\n'
        printf '    /usr/libexec/kscreenlocker_greet --testing\n'
        printf 'Then Meta+L for the real lock.\n'
        printf '\nTo restore the original lockscreen later:\n'
        printf '    %s --uninstall --apply\n' "$0"
    else
        printf 'Dry run complete. Re-run with --apply to perform the install.\n'
    fi
}

uninstall_theme() {
    if [[ ! -d "$BACKUP" ]]; then
        printf 'No backup found at %s; nothing to restore.\n' "$BACKUP" >&2
        exit 1
    fi
    ensure_target_exists

    printf 'Restoring original lockscreen\n'
    printf '  backup: %s\n' "$BACKUP"
    printf '  target: %s\n' "$TARGET"
    if [[ "$APPLY" -ne 1 ]]; then
        printf '\nDRY RUN -- nothing will be written. Re-run with --apply.\n'
    fi
    printf '\n'

    run_sudo rm -rf "$TARGET"
    run_sudo cp -rp "$BACKUP" "$TARGET"
    run_sudo chmod -R 755 "$TARGET"

    printf '\n'
    if [[ "$APPLY" -eq 1 ]]; then
        printf 'Done. Backup retained at %s.\n' "$BACKUP"
    else
        printf 'Dry run complete. Re-run with --apply to perform the restore.\n'
    fi
}

write_test_shell_metadata() {
    local target="$1"
    cat >"$target" <<EOF
{
    "KPackageStructure": "Plasma/Shell",
    "KPlugin": {
        "Id": "${TEST_SHELL_ID}",
        "Name": "Catppuccin Lockscreen (test mirror)",
        "Description": "Local test mirror built by install.sh --test. Not for distribution.",
        "License": "MIT",
        "Version": "0.1"
    },
    "X-KDE-ParentApp": "org.kde.plasmashell",
    "X-Plasma-APIVersion": "2"
}
EOF
}

test_theme() {
    local flavor="$1" accent="$2"
    local id="Catppuccin-$(title "$flavor")-$(title "$accent")"

    if [[ ! -x "$GREETER_BIN" ]]; then
        printf 'Error: greeter binary not found at %s\n' "$GREETER_BIN" >&2
        printf 'Adjust GREETER_BIN in this script if your distro installs it elsewhere.\n' >&2
        exit 1
    fi

    printf 'Building test mirror for %s\n' "$id"
    printf '  mirror: %s\n\n' "$TEST_SHELL_DIR"

    local lockdir="$TEST_SHELL_DIR/contents/lockscreen"
    mkdir -p "$TEST_SHELL_DIR/contents"
    rm -rf "$lockdir"
    cp -r "$SCRIPT_DIR/contents/lockscreen" "$lockdir"
    write_palette_qml "$flavor" "$accent" "$lockdir/CatPalette.qml"
    write_test_shell_metadata "$TEST_SHELL_DIR/metadata.json"

    printf 'Launching greeter (close window or unlock to exit):\n'
    printf '  $ %s --testing --shell %s\n\n' "$GREETER_BIN" "$TEST_SHELL_ID"
    "$GREETER_BIN" --testing --shell "$TEST_SHELL_ID"
    printf '\nTest session ended.\n'
}

list_options() {
    printf 'Flavors: %s\n' "${FLAVORS[*]}"
    printf 'Accents: %s\n' "${ACCENTS[*]}"
}

resolve_flavor_accent() {
    if [[ -z "$FLAVOR" && -z "$ACCENT" ]]; then
        FLAVOR="$(prompt_choice 'Flavor' mocha "${FLAVORS[@]}")"
        ACCENT="$(prompt_choice 'Accent' mauve "${ACCENTS[@]}")"
    else
        FLAVOR="${FLAVOR:-mocha}"
        ACCENT="${ACCENT:-mauve}"
    fi
    contains "$FLAVOR" "${FLAVORS[@]}" || { printf 'Invalid flavor: %s\n' "$FLAVOR" >&2; exit 1; }
    contains "$ACCENT" "${ACCENTS[@]}" || { printf 'Invalid accent: %s\n' "$ACCENT" >&2; exit 1; }
}

# --- arg parsing ---
FLAVOR=""
ACCENT=""
MODE="install"
APPLY=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --flavor)    FLAVOR="$2"; shift 2 ;;
        --accent)    ACCENT="$2"; shift 2 ;;
        --apply)     APPLY=1; shift ;;
        --test)      MODE="test"; shift ;;
        --list)      MODE="list"; shift ;;
        --uninstall) MODE="uninstall"; shift ;;
        --help|-h)   usage; exit 0 ;;
        *)           printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 1 ;;
    esac
done

case "$MODE" in
    list)
        list_options
        ;;
    uninstall)
        uninstall_theme
        ;;
    test)
        resolve_flavor_accent
        test_theme "$FLAVOR" "$ACCENT"
        ;;
    install)
        resolve_flavor_accent
        install_theme "$FLAVOR" "$ACCENT"
        ;;
esac
