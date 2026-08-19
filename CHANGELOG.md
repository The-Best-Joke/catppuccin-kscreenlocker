<!--
SPDX-FileCopyrightText: 2025 Alejandro Salazar <alejandro.s@berkeley.edu>
SPDX-License-Identifier: GPL-2.0-or-later
-->

# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Fixed

- **Sleep and Hibernate buttons now appear.** They were bound to the
  `root.suspendToRamSupported` / `root.suspendToDiskSupported` properties
  inherited from Breeze, which kscreenlocker stopped setting in v6.6.90
  (commit 9e622c8, "Drop custom session management code") — leaving both
  bindings permanently `false`, so only Switch User rendered. They now use
  `sessionManagement.canSuspend` / `canHibernate` and call
  `sessionManagement.suspend()` / `hibernate()`, matching the upstream
  plasma-desktop fix and the mechanism Switch User already used. The dead
  properties and their `suspendToRam()` / `suspendToDisk()` signals are
  dropped from `LockScreen.qml`; `viewVisible` stays, since the greeter
  still writes it.
- **Screen Locking settings reach the lockscreen again.** The install
  replaced the target directory wholesale, dropping the `config.xml` that
  kscreenlocker reads (`shell_integration.cpp`, via `KConfigLoader` →
  `KConfigPropertyMap`) to build the QML `config` object. Without it the
  "show clock" / "hide clock when idle" / "show media controls" toggles
  silently did nothing, and Plasma's own `WallpaperFader` lost its
  `config.alwaysShowClock` input. `install.sh` now carries the host's
  `config.xml` and `config.qml` into both the installed tree and the
  `--test` mirror, sourced from the pristine `.bak` when one exists.

## [0.3.0] - 2026-05-25

First tagged release. Establishes the install model
(`install.sh --apply` overwriting the system shell-package lockscreen,
gated behind `--apply`, with a one-time `.bak` of the original),
ships per-flavor preview assets, and aligns the repo layout with the
catppuccin org convention.

### Changed (breaking)

- **Install path moved from `~/.local/share/plasma/look-and-feel/` to the
  system shell package at
  `/usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen/`.**
  Plasma 6.x kscreenlocker hardcodes that path and ignores the
  `[Greeter]Theme=` key in `kscreenlockerrc`, so the previous install
  location was never actually loaded at lock time. Installing now
  requires `sudo` and overwrites a system directory.
- **`install.sh --apply` is required for any destructive operation.**
  Without it the script is a dry run that prints the `sudo` commands it
  would execute. An earlier `--apply` flag with different semantics
  (delegated to `lookandfeeltool`, clobbered the user's color scheme)
  was removed in a prior release; the new `--apply` is scoped strictly
  to the lockscreen directory.
- **Only one variant is active at a time.** Multi-variant coexistence
  (a directory per flavor + accent) was a property of the old
  look-and-feel install path; the new model overwrites the system
  lockscreen directory, so a new install replaces the previous one.
- **`--uninstall` no longer takes positional `FLAVOR ACCENT` arguments.**
  There is only one active install, so `--uninstall --apply` restores
  from the one-time `.bak` of the original system lockscreen.
- **`metadata.json` removed** from the repo. The system target is a
  flat QML directory inside the existing `org.kde.plasma.desktop`
  shell package, not a standalone KPackage.

### Added

- `--test` mode rebuilds a user-local shell mirror at
  `~/.local/share/plasma/shells/catppuccin-lockscreen/` and launches
  the greeter in a window. No `sudo`, no system files touched. Use to
  preview a (flavor, accent) before `--apply`.
- `--version` flag prints the installer version.
- Interactive `prompt_choice` upgraded to a numbered-list selector that
  accepts numbers, names, or Enter for the default.
- `LICENSE` file (GPL-2.0-or-later) and consistent SPDX headers across
  shell scripts and project-authored QML.
- `CHANGELOG.md`, GitHub Actions `shellcheck` workflow, `SECURITY.md`
  (modelled on the catppuccin org SECURITY policy).
- `justfile` exposing common dev tasks (`just test`, `just install`,
  `just lint`, `just clean`, etc.).
- Plasma-6 guard: `install.sh` calls `plasmashell --version` on
  startup for `--apply`, `--test`, and `--uninstall` and refuses to
  proceed if it isn't Plasma 6.x. Prevents bricking a Plasma 5
  install.
- Per-flavor preview screenshots under `assets/` + four-flavor hero
  (`assets/preview.webp`), referenced by the README.

### Fixed

- `CatPalette.qml` now imports `QtQuick` (the `color` type lives there),
  not `QtQml`. As a standalone singleton it previously could not resolve
  `color`; consumers happened to load `QtQuick` first which masked the
  issue. The greeter's QML error
  (`Type CatPalette unavailable -- color is not a type`) is resolved.
- Default `fontFamily` in `ThemeUserConfig.qml` is now `""` (system
  default via `Kirigami.Theme.defaultFont.family`). The previous default
  `"JetBrainsMono Nerd Font"` would silently fall through to a Qt
  substitution if not installed; the new default renders consistently
  out of the box. Users wanting the intended look install JetBrains Mono
  Nerd Font and set `fontFamily` to it.

### Removed

- The look-and-feel install path. `lookandfeeltool` / `plasma-apply-lookandfeel`
  must not be used with this package -- they replace the entire global
  theme surface.
- `showClock`, `showClockOnlyWhenUiVisible`, `showMediaControls` removed
  from `ThemeUserConfig.qml` / `ThemeConfig.qml`. KDE's screen-locking
  settings are the single source of truth for these; the old per-theme
  values were only a fallback for builds where kscreenlocker didn't
  inject the corresponding `config` keys, which doesn't apply to Plasma
  6.x. `LockScreenUi.qml` now falls back to literal KDE defaults
  (`alwaysShowClock: true`, `hideClockWhenIdle: false`,
  `showMediaControls: true`) on the off chance the keys are missing.
