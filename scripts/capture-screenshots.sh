#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2025 Alejandro Salazar <alejandro.s@berkeley.edu>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Capture preview screenshots of the Catppuccin lockscreen across
# (flavor, accent) combinations. Output: docs/screenshots/<flavor>-<accent>.png
#
# This script pops the greeter window on your live desktop one at a time
# and captures the active window. Keep your hands off the keyboard while
# it runs (~3s per shot). Wayland session with `spectacle` required.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
OUT_DIR="${REPO_DIR}/assets"
GREETER_BIN="/usr/libexec/kscreenlocker_greet"
TEST_SHELL_ID="catppuccin-lockscreen"

# When a captured shot uses the project's "default" accent (mauve), the
# output is named after the flavor only (latte.png, mocha.png, ...) so
# the README can reference catppuccin-style asset paths. Otherwise the
# output is <flavor>-<accent>.png. Set HERO=1 to also write preview.png.
DEFAULT_ACCENT="mauve"
HERO_SOURCE="mocha:mauve"

# shellcheck source=../palette-data.sh
source "$REPO_DIR/palette-data.sh"

# Default capture set: one shot per flavor with accent=mauve.
DEFAULT_SHOTS=(
    latte:mauve
    frappe:mauve
    macchiato:mauve
    mocha:mauve
)

usage() {
    cat <<EOF
Usage: $(basename "$0") [flavor:accent ...]
       $(basename "$0") --all
       $(basename "$0") --flavors          # one shot per flavor (default)
       $(basename "$0") --accents          # one shot per accent (on mocha)

Output:
    ${OUT_DIR}/<flavor>.png            (when accent == $DEFAULT_ACCENT)
    ${OUT_DIR}/<flavor>-<accent>.png   (otherwise)
    ${OUT_DIR}/preview.png             (copy of $HERO_SOURCE shot, used as the README hero)

Requires: Wayland Plasma session, spectacle in PATH, and that the
greeter binary at ${GREETER_BIN} exists.

Examples:
    $(basename "$0")                       # defaults: one per flavor
    $(basename "$0") mocha:mauve mocha:peach
    $(basename "$0") --accents             # mocha across every accent
EOF
}

require_tools() {
    if ! command -v spectacle >/dev/null; then
        printf 'Error: spectacle not found in PATH.\n' >&2
        exit 1
    fi
    if [[ ! -x "$GREETER_BIN" ]]; then
        printf 'Error: greeter not found at %s\n' "$GREETER_BIN" >&2
        exit 1
    fi
    if [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
        printf 'Warning: WAYLAND_DISPLAY unset -- capture may not work.\n' >&2
    fi
}

capture_one() {
    local flavor="$1" accent="$2"
    local out
    if [[ "$accent" == "$DEFAULT_ACCENT" ]]; then
        out="${OUT_DIR}/${flavor}.png"
    else
        out="${OUT_DIR}/${flavor}-${accent}.png"
    fi

    printf '[*] %-10s %s\n' "$flavor" "$accent"
    "$REPO_DIR/install.sh" --test --no-launch \
        --flavor "$flavor" --accent "$accent" >/dev/null

    "$GREETER_BIN" --testing --shell "$TEST_SHELL_ID" >/dev/null 2>&1 &
    local greeter_pid=$!

    # Give the greeter time to render before screenshotting.
    sleep 2.5

    spectacle --activewindow --background --nonotify --output "$out" \
        >/dev/null 2>&1 || true

    kill "$greeter_pid" 2>/dev/null || true
    wait "$greeter_pid" 2>/dev/null || true
    sleep 0.4

    if [[ ! -s "$out" ]]; then
        printf '    !! capture failed for %s/%s\n' "$flavor" "$accent" >&2
        return 1
    fi

    printf '    -> %s\n' "$out"

    # Mirror the hero shot to preview.png so the README's preview slot
    # is populated without an extra capture pass.
    if [[ "${flavor}:${accent}" == "$HERO_SOURCE" ]]; then
        cp -f "$out" "${OUT_DIR}/preview.png"
        printf '    -> %s (hero)\n' "${OUT_DIR}/preview.png"
    fi
}

build_shot_list() {
    case "${1:-}" in
        --all)
            local f a
            for f in "${FLAVORS[@]}"; do
                for a in "${ACCENTS[@]}"; do
                    printf '%s:%s\n' "$f" "$a"
                done
            done
            ;;
        --flavors|"")
            printf '%s\n' "${DEFAULT_SHOTS[@]}"
            ;;
        --accents)
            local a
            for a in "${ACCENTS[@]}"; do
                printf 'mocha:%s\n' "$a"
            done
            ;;
        *)
            # Positional flavor:accent pairs
            for arg in "$@"; do
                printf '%s\n' "$arg"
            done
            ;;
    esac
}

main() {
    case "${1:-}" in
        --help|-h) usage; exit 0 ;;
    esac

    require_tools
    mkdir -p "$OUT_DIR"

    local shots
    mapfile -t shots < <(build_shot_list "$@")

    if [[ ${#shots[@]} -eq 0 ]]; then
        printf 'Nothing to capture.\n' >&2
        exit 1
    fi

    printf 'Capturing %d shot(s) to %s\n\n' "${#shots[@]}" "$OUT_DIR"

    local failures=0 shot flavor accent
    for shot in "${shots[@]}"; do
        flavor="${shot%%:*}"
        accent="${shot##*:}"
        if [[ -z "$flavor" || -z "$accent" || "$flavor" == "$shot" ]]; then
            printf 'Skipping malformed entry: %s (expected flavor:accent)\n' "$shot" >&2
            failures=$((failures + 1))
            continue
        fi
        capture_one "$flavor" "$accent" || failures=$((failures + 1))
    done

    printf '\nDone. %d capture(s), %d failure(s).\n' \
        "$((${#shots[@]} - failures))" "$failures"
    [[ $failures -eq 0 ]]
}

main "$@"
