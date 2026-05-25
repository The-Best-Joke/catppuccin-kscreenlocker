<!--
SPDX-FileCopyrightText: 2025 Alejandro Salazar <alejandro.s@berkeley.edu>
SPDX-License-Identifier: GPL-2.0-or-later
-->

# Contributing

Thanks for your interest. This is a small, focused project — a Catppuccin-themed
lockscreen for KDE Plasma 6. The contribution surface is small but the gotchas
are real; please read this file before opening a PR.

## Quick start

```sh
git clone <fork>
cd catppuccin-kscreenlocker

# Edit anything under contents/lockscreen/, then preview without touching /usr/share:
./install.sh --test

# Once happy, install onto the real lockscreen (sudo prompt; backs up the original):
./install.sh --apply
```

## How testing works

`./install.sh --test` builds the current repo state (QML + a generated
`CatPalette.qml` for the chosen flavor + accent + a generated `metadata.json`)
into a user-local Plasma/Shell package at
`~/.local/share/plasma/shells/catppuccin-lockscreen/`, then launches the
greeter in a window:

```sh
/usr/libexec/kscreenlocker_greet --testing --shell catppuccin-lockscreen
```

No `sudo`, no system files touched. Run from a terminal so QML
`console.warn` output is visible. The greeter does not cache `.qmlc` for
this package, so QML edits compile fresh each launch.

For more verbose QML loading diagnostics:

```sh
./install.sh --test                                          # sync mirror once
QT_LOGGING_RULES='qt.qml*=true' /usr/libexec/kscreenlocker_greet \
    --testing --shell catppuccin-lockscreen
```

## How install actually works (read this!)

Plasma 6.x kscreenlocker hardcodes the path
`/usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen/`
and ignores `[Greeter]Theme=` in `kscreenlockerrc`. The only way to theme
the real lockscreen is to overwrite that system directory. `install.sh
--apply` does this via `sudo` after backing up the original to a sibling
`.bak`. `--uninstall --apply` restores from the backup.

Do **not** propose changes that:
- Use `lookandfeeltool` / `plasma-apply-lookandfeel`. They reset the
  entire global-theme surface (color scheme, window decoration, icons,
  cursor, splash). This package is lockscreen-only.
- Reintroduce `[Greeter]Theme=` writes. The key isn't read at lock time
  on Plasma 6.x.
- Install back into `~/.local/share/plasma/look-and-feel/` or any
  user-local Plasma/Shell directory (other than the testing mirror).
  kscreenlocker won't find it.

The relevant upstream code lives in
[kscreenlocker](https://invent.kde.org/plasma/kscreenlocker/) —
specifically `greeter/greeterapp.cpp` (`setShell(m_shellIntegration->defaultShell())`,
which hardcodes the package type to `Plasma/Shell` and the default ID
to `org.kde.plasma.desktop`) and `ksldapp.cpp` (the daemon side, which
never passes `--shell` to the greeter in real lock flow). Verified by
running the greeter with `QT_LOGGING_RULES='qt.qml*=true'`: the loaded
QML path is always `/usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen/LockScreen.qml`
regardless of `kscreenlockerrc` settings.

## Code style

### Shell

- `set -euo pipefail` at the top of every script.
- Quote every variable expansion. `shellcheck` runs in CI.
- Destructive commands gate behind `--apply` and use the `run_sudo`
  helper. No silent `sudo`.

### QML

- One concern per file. Components named `Cat*` are styled primitives;
  `Theme*` is configuration; bare names are layout containers.
- A directory with `qmldir` is a QML module. Any new singleton or QML
  *type* used by sibling files must be declared in `qmldir`.
- Files needing `CatPalette` / `CatTheme` / `ThemeConfig` import the
  local module with `import "." as LockScreenLocal`.
- Spacing constants live in `CatTheme.qml` (`sectionGap`). Don't sprinkle
  magic numbers across files.
- Action buttons (sleep / hibernate / switch-user) always render in
  `CatPalette.red`. They're semantic danger affordances regardless of
  accent.

### Palette and accents

- Palette values live in `palette-data.sh`. Do not edit
  `contents/lockscreen/CatPalette.qml` by hand for color tweaks — that
  file is rewritten by the installer.
- Add a new flavor by adding a `declare -A NAME=(...)` block plus
  appending to `FLAVORS=(...)`. Match the existing
  [Catppuccin style guide](https://catppuccin.com/palette).
- Derived shades (hover, active, alpha-tinted variants) are computed at
  the call site with `Qt.lighter`, `Qt.darker`, `Qt.rgba(c.r, c.g, c.b, a)`.
  No per-accent branching.

### No INI / .conf files

An earlier iteration tried `.conf` files via `XMLHttpRequest`. Qt 6
blocks `file://` URLs without `QML_XHR_ALLOW_FILE_READ=1`, which can't
be set on the locker process. Colors are baked into a singleton at
install time; behavioral toggles read from the kscreenlocker host's
injected `config` object (with `ThemeConfig` fallback).

## SPDX headers

New project files (shell, QML written by us) should start with:

```
# SPDX-FileCopyrightText: <year> <Your Name> <your@email>
# SPDX-License-Identifier: GPL-2.0-or-later
```

(`// …` for QML, `# …` for shell, `<!-- … -->` for Markdown.)

Files inherited from upstream Plasma/KDE keep their original SPDX
headers.

## Commit messages

Short, present tense subject. Body explains the "why" if it's not
obvious from the diff. Add `Co-Authored-By` lines for genuine co-authors
(including AI assistants that wrote substantive code on your behalf).
