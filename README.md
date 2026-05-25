# Catppuccin kscreenlocker

A [Catppuccin](https://catppuccin.com/)-themed lock screen for KDE Plasma 6. Generates a look-and-feel package for any flavor (Latte / Frappé / Macchiato / Mocha) paired with any of the fourteen Catppuccin accent colors.

The deliverable is the **kscreenlocker** theme under `contents/lockscreen/`. Wallpaper, clock visibility, and media-controls behavior are read directly from the kscreenlocker host (System Settings → Workspace → Screen Locking) — no per-theme config file required.

## Install

```sh
./install.sh                                       # interactive: pick flavor + accent
./install.sh --flavor mocha --accent mauve         # non-interactive
./install.sh --flavor latte --accent lavender --apply
./install.sh --list                                # print all flavors and accents
./install.sh --uninstall mocha mauve               # remove a variant
./install.sh --help
```

Each invocation creates `~/.local/share/plasma/look-and-feel/Catppuccin-{Flavor}-{Accent}/`. Multiple variants can coexist; only one is active at a time.

## Apply

After install, switch to the new look-and-feel via **System Settings → Workspace → Global Theme**, or pass `--apply` to the install command (uses `lookandfeeltool` / `plasma-apply-lookandfeel` if available).

Behavioral toggles — "Show clock" (with the "hide when idle" sub-toggle) and "Show media controls" — are read from **System Settings → Workspace → Screen Locking**. No theme files need editing.

## Palette

Colors come from a single QML singleton, `contents/lockscreen/CatPalette.qml`. The install script writes that file at install time using values from `palette-data.sh`, which mirrors the official Catppuccin palette. Eight neutrals (`base`, `mantle`, `crust`, `surface0`, `surface1`, `overlay0`, `subtext0`, `text`) plus the selected `accent` plus the semantic `red` (auth failure, action buttons) and `rosewater` (action-button hover).

The unlock button is the accent color; its hover/active states are derived with `Qt.lighter` / `Qt.darker` so every accent ramp works without per-accent data. The sleep / hibernate / switch-user action buttons stay Catppuccin red across all accents — they read as power-related danger affordances regardless of the rest of the theme.

## Local development

Clone or work directly in this directory. A mirror shell package at `~/.local/share/plasma/shells/catppuccin-lockscreen/` enables fast iteration via:

```sh
/usr/libexec/kscreenlocker_greet --testing --shell catppuccin-lockscreen
```

Run from a terminal so QML `console.warn` output is visible. Any edit under `contents/lockscreen/` must be mirrored into the shell package — see `CLAUDE.md`.

## Layout structure (lockscreen)

- `LockScreen.qml` / `LockScreenUi.qml` — root wiring, native-config readers, clock, footer.
- `MainBlock.qml` — password prompt, login button, action buttons, media-controls Loader.
- `SessionManagementScreen.qml` — username + prompts layout and spacing.
- `Cat*.qml` — themed widgets (avatar, clock, password field, buttons).
- `CatPalette.qml` (singleton) — the ten Catppuccin color values for this variant.
- `CatTheme.qml` (singleton) — icon names and spacing constants.
- `qmldir` — singleton declarations.

## Why no INI config file?

An earlier iteration used a `.conf` file read at runtime. Qt 6 blocks `XMLHttpRequest` from reading `file://` URLs unless `QML_XHR_ALLOW_FILE_READ=1` is set on the kscreenlocker process, which is not portable. Colors are now baked into the singleton at install time; behavioral toggles defer to the kscreenlocker host. There is nothing to configure post-install.
