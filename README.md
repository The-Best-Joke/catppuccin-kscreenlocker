<!--
SPDX-FileCopyrightText: 2025 Alejandro Salazar <alejandro.s@berkeley.edu>
SPDX-License-Identifier: GPL-2.0-or-later
-->

# Catppuccin kscreenlocker

A [Catppuccin](https://catppuccin.com/)-themed lock screen for **KDE Plasma 6**.
Pick any of the four flavors (Latte, Frappé, Macchiato, Mocha) paired with any
of the fourteen accent colors; the installer generates the palette and replaces
the system lockscreen QML in place.

## Screenshots

> Generated with `scripts/capture-screenshots.sh` (see [Screenshots](#screenshot-helper) below).

| Latte | Frappé | Macchiato | Mocha |
|---|---|---|---|
| ![latte-mauve](docs/screenshots/latte-mauve.png) | ![frappe-mauve](docs/screenshots/frappe-mauve.png) | ![macchiato-mauve](docs/screenshots/macchiato-mauve.png) | ![mocha-mauve](docs/screenshots/mocha-mauve.png) |

## Requirements

- KDE Plasma 6.x (tested on 6.6).
- A Wayland session (the install path is Plasma-6-Wayland-specific; X11 may
  work but is not tested).
- `sudo` rights — the installer overwrites a system directory.
- Recommended: [JetBrains Mono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases) for the intended typography (see [Fonts](#fonts) below).

## Install

```sh
# Preview in a window first (no sudo, no system files touched):
./install.sh --test

# Once happy, install for real (prompts for sudo; backs up the original lockscreen):
./install.sh --apply
```

The installer is a **dry run by default** — any invocation without `--apply`
just prints the `sudo` commands it would run. Pass `--apply` to actually
execute them.

All commands:

```sh
./install.sh                                        # interactive dry-run
./install.sh --flavor mocha --accent mauve          # non-interactive dry-run
./install.sh --flavor mocha --accent mauve --apply  # actual install
./install.sh --test                                 # preview in a window
./install.sh --uninstall --apply                    # restore the original
./install.sh --list                                 # list flavors and accents
./install.sh --version                              # print installer version
./install.sh --help
```

### What the installer does

1. Backs up the system lockscreen to a sibling `.bak` directory (once,
   on the first apply; never overwritten by subsequent applies).
2. Writes the chosen flavor's palette into a `CatPalette.qml` singleton.
3. Replaces
   `/usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen/`
   with the themed QML tree.
4. Sets permissions to 755.

`--uninstall --apply` restores from `.bak`. The backup is preserved.

### Why sudo?

Plasma 6 kscreenlocker hardcodes the lockscreen path to the system
`org.kde.plasma.desktop` shell package; it does not consult the
`[Greeter]Theme=` key in `kscreenlockerrc` and does not look in
user-local Plasma directories. Themeing the lockscreen therefore
requires overwriting that one system directory. See
[`CONTRIBUTING.md`](CONTRIBUTING.md) for the longer explanation
and the upstream source references that establish this.

## Configuration

### Behavioral toggles (System Settings)

These are read from KDE's screen-locking settings; no theme files to edit:

- Show clock (with the "hide when idle" sub-toggle).
- Show media controls.

Find them under **System Settings → Workspace → Screen Locking**.

### Per-theme overrides (`ThemeUserConfig.qml`)

Everything else — font, layout-label visibility, user-image visibility —
lives in `ThemeUserConfig.qml`:

```qml
QtObject {
    property string fontFamily: ""        // "" = system default
    property bool   showLayoutLabel: false // shown only with >1 keyboard layout
    property bool   showUserImage: true
}
```

To change a value, edit the file in this repo and re-run
`./install.sh --apply`. (You can also `sudo $EDITOR
/usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen/ThemeUserConfig.qml`
directly, but those edits are clobbered on the next install.)

### Fonts

The default is the system font (empty string in `ThemeUserConfig.qml`).
For the intended look, install **[JetBrains Mono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases)** and set:

```qml
property string fontFamily: "JetBrainsMono Nerd Font"
```

Any installed font family name works. If you set a font that isn't
installed, Qt silently substitutes — there's no visible warning. Empty
string is the safest default.

## How it looks

The palette comes from a single QML singleton, `CatPalette.qml`, written
by the installer per (flavor, accent):

- **Eight neutrals** from the Catppuccin spec: `base`, `mantle`, `crust`,
  `surface0`, `surface1`, `overlay0`, `subtext0`, `text`.
- **One accent** — the unlock button + selected-user halo.
- **Semantic `red`** — auth-failure border, sleep/hibernate/switch-user
  action buttons. (These stay Catppuccin red across all accents; they
  read as power-related danger affordances regardless of the rest of the
  theme.)
- **`rosewater`** — action-button hover.

Derived shades (hover, active, alpha-tinted variants) are computed at
the call site via `Qt.lighter`, `Qt.darker`, `Qt.rgba(c.r, c.g, c.b, a)`
— no per-accent branching, every accent ramps correctly.

## Local development

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the testing workflow,
code style, and the constraints that came out of the wider
investigation (no `lookandfeeltool`, no INI files, no
`[Greeter]Theme=` writes — explained in detail there).

Short version: edit anything under `contents/lockscreen/`, run
`./install.sh --test` to preview without touching the system.

### Screenshot helper

```sh
scripts/capture-screenshots.sh              # one shot per flavor (with mauve)
scripts/capture-screenshots.sh --accents    # mocha with every accent
scripts/capture-screenshots.sh --all        # 4 flavors x 14 accents = 56 shots
scripts/capture-screenshots.sh mocha:peach latte:teal
```

Outputs to `docs/screenshots/<flavor>-<accent>.png`. Requires
`spectacle` and a running Wayland Plasma session; greeter windows pop
briefly during capture, so don't run it while you're using the desktop.

## License

GPL-2.0-or-later. See [`LICENSE`](LICENSE).

QML files inherited from upstream KDE Plasma retain their original
copyright notices and SPDX headers; project-authored files carry the
project's own SPDX headers.
