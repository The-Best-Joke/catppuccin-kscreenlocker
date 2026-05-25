# CLAUDE.md — Catppuccin kscreenlocker

Guidance for future Claude Code sessions on this repo.

## What this repo is

A generator for a Plasma 6 kscreenlocker theme, parameterized by Catppuccin
flavor + accent. The deliverable is the QML tree under `contents/lockscreen/`,
plus an `install.sh` that overwrites the system lockscreen directory with that
tree and a per-(flavor, accent) `CatPalette.qml`.

## How the lockscreen is actually loaded — IMPORTANT

On Plasma 6.x, **kscreenlocker hardcodes the lockscreen path** to the system
shell package:

```
/usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen/
```

The lock-time greeter (`/usr/libexec/kscreenlocker_greet`) calls
`m_shellIntegration->defaultShell()`, which returns `org.kde.plasma.desktop`
and ignores any user override. `KSldApp` never passes `--shell` to the greeter
in real lock flow — only `--immediateLock`, `--graceTime`, `--nolock`,
`--ksldfd`. The `--shell` CLI flag is honored solely in `--testing` mode.

Consequences:

- **`[Greeter]Theme=` in `~/.config/kscreenlockerrc` is dead** for the real
  lock flow on this Plasma version. Setting it does nothing visible.
- Installing under `~/.local/share/plasma/look-and-feel/` does nothing —
  kscreenlocker never looks there.
- Installing under `~/.local/share/plasma/shells/<name>/` does nothing for
  real locks (it works only with `--testing --shell <name>`).
- **The only way to theme the real lockscreen is to overwrite the system
  directory above.** This is what `install.sh --apply` does, with sudo and a
  one-time `.bak` of the original.

This finding came after burning a session chasing the `[Greeter]Theme=`
path. Verified by `QT_LOGGING_RULES='qt.qml*=true'` against
`kscreenlocker_greet --testing`, which showed it loading
`file:///usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen/LockScreen.qml`
regardless of the configured Theme value. Cross-checked against the
[Silent-KLockscreen](https://github.com/Khip01/Silent-KLockscreen) installer,
which targets the same system path for the same reason.

## Repo location — IMPORTANT

This repo lives at `~/Projects/catppuccin-kscreenlocker/`.

**Never relocate it under any path the install script writes to** — the older
self-deleting bug (when the repo lived under `~/.local/share/plasma/look-and-feel/`)
was an `rm -rf "$dest"` of a destination that turned out to be the repo's own
working tree, `.git` included. The current installer's target is
`/usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen`, which
is on a disjoint subtree, but the principle stands.

## Three relevant lockscreen locations

| Location | Purpose | Modified by |
|---|---|---|
| `~/Projects/catppuccin-kscreenlocker/contents/lockscreen/` | Source / dev tree | hand edits |
| `~/.local/share/plasma/shells/catppuccin-lockscreen/contents/lockscreen/` | **Testing mirror** — for `--testing --shell catppuccin-lockscreen`. Not in this repo. | `install.sh --test` (auto) |
| `/usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen/` | **Real install target** — what locks actually load | `install.sh --apply` (sudo) |

### Testing mirror is managed by `install.sh --test`

`install.sh --test` rebuilds the shell-package mirror from the current repo
state (full file copy + generated `CatPalette.qml` for the chosen flavor +
accent + a generated `metadata.json` for the shell package) and then launches
the greeter against it. This is the canonical test workflow; no sudo, no
system files touched.

```sh
./install.sh --test                          # prompts for flavor + accent
./install.sh --test --flavor mocha --accent peach
```

The mirror is local-only — never commit it.

If you need to drive the greeter manually (e.g. with `QT_LOGGING_RULES` for
QML debug output), run `--test` once to sync the mirror, then:

```sh
QT_LOGGING_RULES='qt.qml*=true' \
  /usr/libexec/kscreenlocker_greet --testing --shell catppuccin-lockscreen
```

The greeter does not keep a `.qmlc` cache for this package, so QML edits
compile fresh each launch.

## Testing

Preview before applying (user-local mirror, no sudo):

```sh
./install.sh --test
```

Test the actual installed result (after `install.sh --apply`):

```sh
/usr/libexec/kscreenlocker_greet --testing
```

(No `--shell` — falls back to `defaultShell()` = `org.kde.plasma.desktop`,
which is now your installed theme.)

## install.sh contract

- Install is dry-run by default. Prints every sudo command it would run.
- `--apply` actually executes the writes (sudo prompts you).
- First `--apply` per machine backs up the original `lockscreen/` to
  `lockscreen.bak` (sibling dir, root-owned). Subsequent applies do not
  overwrite the backup.
- `--uninstall --apply` restores from `.bak` and keeps the backup in place.
- `--test` rebuilds the user-local shell mirror and launches the greeter
  in a window. No sudo, no system files. Use to preview before `--apply`.
- No `metadata.json` written into the system target — the target is a
  flat QML directory inside the system shell package, not a standalone
  KPackage. (`--test` does write a small `metadata.json` into the *mirror*,
  since that one is a real Plasma/Shell package.)

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
  scheme and aurorae window decoration in a prior session.
- **Don't suggest `kwriteconfig6 --file kscreenlockerrc --group Greeter --key Theme …`.**
  See "How the lockscreen is actually loaded" above — that key is not
  consulted at lock time on Plasma 6.x. A previous version of this file
  recommended it; that advice was wrong.
- **`install.sh --apply` is the only activation path.** It is destructive
  (sudo `rm -rf` of `/usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen`
  before copying the new tree) — that's why it's gated behind `--apply` and
  why a `.bak` is created on first run. Earlier sessions removed an
  `--apply` flag with different semantics (it shelled out to
  `lookandfeeltool` and clobbered the user's color scheme). The current
  `--apply` is unrelated to that and safe in scope — it touches only
  `…/contents/lockscreen/` and its sibling `.bak`.
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

When this repo was rebuilt after the older `install.sh`'s `rm -rf`
self-deleted the prior tree, the following sibling content was not in the
shell mirror and is currently absent:

- `contents/defaults/`
- `contents/previews/` (fullscreenpreview.jpg, preview.png, splash.png)
- `contents/splash/images/` (busywidget.svg, Logo.png)

These were look-and-feel companions and are not required for the current
install path (which only consumes `contents/lockscreen/`). Restore from a
Breeze package skeleton only if Global Theme integration is ever needed.
