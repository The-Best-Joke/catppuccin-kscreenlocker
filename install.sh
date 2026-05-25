#!/usr/bin/env bash
# Install a Catppuccin lock-screen look-and-feel package into
# ~/.local/share/plasma/look-and-feel/Catppuccin-{Flavor}-{Accent}/.
# Run with --help for options.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=palette-data.sh
source "$SCRIPT_DIR/palette-data.sh"

DEST_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/look-and-feel"

usage() {
    cat <<EOF
Usage: $(basename "$0") [--flavor FLAVOR] [--accent ACCENT]
       $(basename "$0") --uninstall FLAVOR ACCENT
       $(basename "$0") --list
       $(basename "$0") --help

Flavors: ${FLAVORS[*]}
Accents: ${ACCENTS[*]}

Defaults: --flavor mocha --accent mauve

With no flags, prompts interactively.

To activate after installing, set the lock-screen theme in
System Settings -> Workspace -> Screen Locking, or run:
    kwriteconfig6 --file kscreenlockerrc --group Greeter --key Theme \\
        Catppuccin-{Flavor}-{Accent}
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

import QtQml

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

write_metadata_json() {
    local id="$1" name="$2" src="$3" dest="$4"
    if command -v python3 >/dev/null 2>&1; then
        python3 - "$src" "$dest" "$id" "$name" <<'PY'
import json, sys
src, dest, new_id, new_name = sys.argv[1:5]
with open(src) as f:
    meta = json.load(f)
meta["KPlugin"]["Id"] = new_id
meta["KPlugin"]["Name"] = new_name
with open(dest, "w") as f:
    json.dump(meta, f, indent=4)
    f.write("\n")
PY
    else
        sed -e "s/\"Id\": \"[^\"]*\"/\"Id\": \"$id\"/" \
            -e "s/\"Name\": \"[^\"]*\"/\"Name\": \"$name\"/" \
            "$src" >"$dest"
    fi
}

install_variant() {
    local flavor="$1" accent="$2"
    local id name dest
    id="Catppuccin-$(title "$flavor")-$(title "$accent")"
    name="Catppuccin $(title "$flavor") $(title "$accent")"
    dest="$DEST_ROOT/$id"

    # Hard refuse if the repo itself sits at the destination path. This
    # script does `rm -rf "$dest"` and would delete its own source tree.
    if [[ -d "$dest" ]] && [[ "$(realpath "$SCRIPT_DIR")" == "$(realpath "$dest")" ]]; then
        printf 'Refusing to install over the repo itself (%s).\n' "$dest" >&2
        printf 'Move the repo out of %s and rerun.\n' "$DEST_ROOT" >&2
        exit 1
    fi

    printf 'Installing %s -> %s\n' "$id" "$dest"
    rm -rf "$dest"
    mkdir -p "$dest/contents"
    cp -r "$SCRIPT_DIR/contents/." "$dest/contents/"
    write_palette_qml "$flavor" "$accent" "$dest/contents/lockscreen/CatPalette.qml"
    write_metadata_json "$id" "$name" "$SCRIPT_DIR/metadata.json" "$dest/metadata.json"

    printf 'Done.\n'
    printf 'Apply via System Settings -> Workspace -> Screen Locking -> Theme, or:\n'
    printf '  kwriteconfig6 --file kscreenlockerrc --group Greeter --key Theme %s\n' "$id"
    printf '  (then lock the screen to load it)\n'
    printf 'Note: do NOT use lookandfeeltool/plasma-apply-lookandfeel with this\n'
    printf 'package -- it will reset your color scheme and window decorations\n'
    printf 'because this package ships only a lock screen, no other components.\n'
}

uninstall_variant() {
    local flavor="$1" accent="$2"
    contains "$flavor" "${FLAVORS[@]}"  || { printf 'Invalid flavor: %s\n' "$flavor" >&2; exit 1; }
    contains "$accent" "${ACCENTS[@]}"  || { printf 'Invalid accent: %s\n' "$accent" >&2; exit 1; }
    local id="Catppuccin-$(title "$flavor")-$(title "$accent")"
    local dest="$DEST_ROOT/$id"
    if [[ ! -d "$dest" ]]; then
        printf 'Not installed: %s\n' "$dest" >&2
        exit 1
    fi
    if [[ "$(realpath "$SCRIPT_DIR")" == "$(realpath "$dest")" ]]; then
        printf 'Refusing to uninstall the repo itself (%s).\n' "$dest" >&2
        exit 1
    fi
    printf 'Remove %s? [y/N] ' "$dest"
    local confirm; read -r confirm
    [[ "$confirm" == "y" || "$confirm" == "Y" ]] || { printf 'Aborted.\n'; exit 0; }
    rm -rf "$dest"
    printf 'Removed.\n'
}

list_options() {
    printf 'Flavors: %s\n' "${FLAVORS[*]}"
    printf 'Accents: %s\n' "${ACCENTS[*]}"
}

# --- arg parsing ---
FLAVOR=""
ACCENT=""
MODE="install"
UNINSTALL_FLAVOR=""
UNINSTALL_ACCENT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --flavor)    FLAVOR="$2"; shift 2 ;;
        --accent)    ACCENT="$2"; shift 2 ;;
        --apply)     printf 'Error: --apply was removed. Applying via lookandfeeltool resets unrelated\n' >&2
                     printf 'system theme components (color scheme, window decoration). Set the lock\n' >&2
                     printf 'screen via System Settings -> Workspace -> Screen Locking, or run:\n' >&2
                     printf '  kwriteconfig6 --file kscreenlockerrc --group Greeter --key Theme Catppuccin-{Flavor}-{Accent}\n' >&2
                     exit 1 ;;
        --list)      MODE="list"; shift ;;
        --uninstall) MODE="uninstall"; UNINSTALL_FLAVOR="${2:-}"; UNINSTALL_ACCENT="${3:-}"; shift 3 ;;
        --help|-h)   usage; exit 0 ;;
        *)           printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 1 ;;
    esac
done

case "$MODE" in
    list)
        list_options
        ;;
    uninstall)
        uninstall_variant "$UNINSTALL_FLAVOR" "$UNINSTALL_ACCENT"
        ;;
    install)
        if [[ -z "$FLAVOR" && -z "$ACCENT" ]]; then
            FLAVOR="$(prompt_choice 'Flavor' mocha "${FLAVORS[@]}")"
            ACCENT="$(prompt_choice 'Accent' mauve "${ACCENTS[@]}")"
        else
            FLAVOR="${FLAVOR:-mocha}"
            ACCENT="${ACCENT:-mauve}"
        fi
        contains "$FLAVOR" "${FLAVORS[@]}" || { printf 'Invalid flavor: %s\n' "$FLAVOR" >&2; exit 1; }
        contains "$ACCENT" "${ACCENTS[@]}" || { printf 'Invalid accent: %s\n' "$ACCENT" >&2; exit 1; }
        install_variant "$FLAVOR" "$ACCENT"
        ;;
esac
