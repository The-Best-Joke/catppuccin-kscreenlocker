# CLAUDE.md — Catppuccin kscreenlocker

Guidance for future Claude Code sessions on this repo.

## What this repo is

A generator for Plasma 6 look-and-feel packages themed to any Catppuccin
flavor + accent combination. The deliverable is the **kscreenlocker** theme
under `contents/lockscreen/`. The repo doubles as the development workspace
and as the source of truth `install.sh` copies from.

## Repo location — IMPORTANT

This repo lives at `~/Projects/catppuccin-kscreenlocker/`.

**Never relocate it back under `~/.local/share/plasma/look-and-feel/`.** An
earlier rev did, and `install.sh`'s `rm -rf "$dest"` happily deleted the
entire working tree (including `.git`). The current `install.sh` has a
`realpath` guard that refuses to install over the repo, but the cleanest
defense is to keep `SCRIPT_DIR` and `DEST_ROOT` on disjoint subtrees.

## Two-package setup — IMPORTANT

There are **two copies** of the lock screen on this machine:

1. **This repo** — the source/dev tree:
   `~/Projects/catppuccin-kscreenlocker/`
2. **Shell package** — local testing only, NOT in this repo:
   `~/.local/share/plasma/shells/catppuccin-lockscreen/`

The shell package exists solely because `kscreenlocker_greet --testing --shell`
can load it quickly. **It is a mirror.** Every edit to a file under
`contents/lockscreen/` in this repo MUST be copied to the matching file in the
shell package, or testing will show stale behavior.

```sh
REPO=~/Projects/catppuccin-kscreenlocker/contents/lockscreen
SH=~/.local/share/plasma/shells/catppuccin-lockscreen/contents/lockscreen
cp "$REPO/<file>" "$SH/<file>"
```

Always mirror after editing. Do not commit the shell package — it is not part
of this repo.

## Testing

```sh
/usr/libexec/kscreenlocker_greet --testing --shell catppuccin-lockscreen
```

Run from a terminal to see QML `console.warn` output. The greeter does not
keep a `.qmlc` cache for this package, so QML edits compile fresh each launch.

## Architecture

### Configuration
- **Behavioral toggles** (clock visibility, media controls) are read from
  the kscreenlocker host's injected `config` context property when available,
  with a `ThemeConfig` fallback. See `LockScreenUi.qml`'s
  `nativeAlwaysShowClock`, `nativeHideClockWhenIdle`, `nativeShowMediaControls`.
  Users flip these in System Settings → Workspace → Screen Locking.
- **Per-theme overrides** (font family, layout label visibility, user-image
  toggle) live in `ThemeUserConfig.qml`, wrapped by `ThemeConfig.qml`.
- **No INI/`.conf` config files.** Qt 6 blocks `XMLHttpRequest` from reading
  `file://` URLs without `QML_XHR_ALLOW_FILE_READ=1`, which can't be relied
  on for the locker process.

### Palette
- All colors live in `contents/lockscreen/CatPalette.qml` (singleton, ten
  values: eight Catppuccin neutrals + one `accent` + the semantic `red` and
  `rosewater`).
- `install.sh` overwrites `CatPalette.qml` per (flavor, accent) at install
  time, sourcing values from `palette-data.sh`.
- Derived shades (hover/active button states, alpha-tinted variants) are
  computed at the call site via `Qt.lighter`, `Qt.darker`, and `Qt.rgba(c.r,
  c.g, c.b, a)` — no per-accent branching needed.
- Action buttons (sleep/hibernate/switch-user) stay `red` across all
  accents — they read as semantic danger affordances.

### Conventions
- A directory with a `qmldir` is a QML module: any new singleton or QML
  *type* used by sibling files must be added to `qmldir`.
- Files needing `CatPalette`/`CatTheme`/`ThemeConfig`/etc. import the local
  module with `import "." as LockScreenLocal`.
- Spacing constants live in `CatTheme.qml` (`sectionGap`).
- `SessionManagementScreen.qml` carries the wrapper-flatten fix
  (innerLayout has the `Layout.maximumHeight: gridUnit * 10` + the
  `Layout.fillHeight: false`) that lets the layout compress upward when
  MediaControls collapses to zero height.
- The `notificationsLabel` is reserved for Caps Lock advisory only;
  auth-failure feedback is the `RejectPasswordAnimation` shake + the red
  border on the password field.
- Remove any `// DBG` debug code (hardcoded values, debug Labels) before
  considering work shippable.

## Hard-won constraints — do not relitigate

- **Never use `lookandfeeltool -a` / `plasma-apply-lookandfeel -a` on this
  package.** It applies the *entire* look-and-feel surface — global theme,
  color scheme, window decoration, plasma theme, icons, cursor, splash —
  and resets anything we don't ship to Breeze defaults. We ship only a
  lock screen, so this command nuked the user's actual Catppuccin color
  scheme and aurorae window decoration in a prior session. Apply by
  writing `[Greeter]Theme=` in `kscreenlockerrc` instead. `install.sh`'s
  `--apply` flag was removed for this reason and the flag now errors out.
- **No bundled wallpaper.** The earlier wall.png approach overstepped a
  look-and-feel theme's role; the host wallpaper is rendered by
  `WallpaperFader { source: wallpaper }` and that's correct.
- **Never assign a raw string to a `bool`.** `"false"` is truthy in QML.
- **Per-character animation on `PasswordField` is not achievable** without
  rewriting the text renderer. The monolithic-string animations (background
  pulse, border halo, text fade) live on `CatPasswordField.qml` and are
  debounced via a shared `idleTimer` so they hold during continuous typing.
- **Native config injection is best-effort.** If `kscreenlocker_greet`
  doesn't expose `config.alwaysShowClock` etc. on a given Plasma build, the
  `typeof config !== "undefined"` guard falls back to `ThemeConfig`.

## Lost in the catastrophic reinstall (recover if needed)

When this repo was rebuilt after `install.sh`'s `rm -rf` self-deleted the
prior tree, the following sibling content was not in the shell mirror and
is currently absent:

- `contents/defaults/`
- `contents/previews/` (fullscreenpreview.jpg, preview.png, splash.png)
- `contents/splash/images/` (busywidget.svg, Logo.png)

These are normal look-and-feel companions but not required for the
kscreenlocker focus. Add stubs or restore from a Breeze package skeleton if
Global Theme integration ever needs them.
