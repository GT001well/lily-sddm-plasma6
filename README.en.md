# Lily SDDM

A frosted-glass login theme for SDDM, built for Plasma 6 and Qt 6.
The accent color is derived from the current wallpaper, so the login screen
stays in tune with the background.

After upgrading Plasma from 6.7.5 to 6.8, the previously configured SDDM theme
stopped working and the login screen fell back to the original SDDM interface.
This theme was rebuilt and is maintained for my own needs.

[中文说明](README.md)

## Preview

![Lily SDDM theme preview](docs/preview.png)

## Contents

- [Preview](#preview)
- [Common commands](#common-commands)
- [Installation](#installation)
- [Compatibility and dependencies](#compatibility-and-dependencies)
- [License](#license)

## Common commands

Run `make` or `make help` to list every available entry point:

| Command | Purpose |
| --- | --- |
| `make check` | Check the theme, prototype and multi-resolution layout |
| `make check-layout` | Run only the multi-resolution layout checks |
| `make preview` | Preview with the real SDDM Qt 6 greeter |
| `make prototype` | Open the HTML layout prototype |
| `make render-preview` | Regenerate the full and KCM previews |
| `make install` | Install the theme; honors `PREFIX` and `DESTDIR` |

## Installation

The project does not maintain distribution package metadata. Install it
directly from source. The target system must provide Plasma 6, Qt 6 SDDM,
the Qt Quick Effects QML module and the Qt SVG image plugin. Distribution
packages can be built separately according to each distribution's rules.

Builds and login tests have only been run on Arch, Plasma 6, Qt 6.12 and
SDDM 0.21.

Run the checks before installation:

```bash
make check
```

Install directly into the system directories:

```bash
sudo make install
```

To stage the installation first:

```bash
make install DESTDIR="$PWD/stage" PREFIX=/usr
```

After installation, select the Lily theme under "Login Screen (SDDM)" in
Plasma System Settings. The theme preview comes from the installed
`assets/preview.png`.

## Compatibility and dependencies

Tested environment:

- SDDM 0.21.0-7
- Qt 6.12.0
- Plasma 6.8.2
- Greeter: `/usr/bin/sddm-greeter-qt6`

The Qt Quick Effects QML module and the Qt SVG image plugin are required at
runtime. Install the corresponding components from the target distribution's
software repository.

The theme does not use Kirigami, PlasmaComponents, Breeze Components,
Qt Quick Controls or `Qt5Compat.GraphicalEffects`. The blurred side rail is
produced by `MultiEffect` at runtime.

After a wallpaper is selected, the greeter samples it once at startup and
derives the accent color, glass tint and the low-saturation dark surfaces for
controls and dialogs. `autoColors=false` disables all automatic colors;
`autoSurfaceColors=false` keeps the automatic accent while using the fixed
surface colors from `theme.conf`. See
[NOTE/DEVELOPMENT.md](NOTE/DEVELOPMENT.md) for the color sampling details.

When checking dependencies or compatibility, run `make check` first. It
validates QML imports, metadata, assets and the prototype, and also checks the
layout at 720p, 1440p, 4K, ultrawide and portrait when PySide6 is installed.
Use `make preview` to verify rendering and interaction with the real greeter.
`make render-preview` only regenerates preview images with optional PySide6
and ImageMagick; it does not replace verification with the real greeter.

## License

The project code and icons are licensed under `GPL-3.0-or-later`. The default
wallpaper is Breeze Next (Hanabi) by Krystian Zajdel, licensed under
CC-BY-SA-4.0. The full GPL text is in `LICENSE`, and `make install` places it
under `/usr/share/licenses/lily-sddm-plasma6/`.
