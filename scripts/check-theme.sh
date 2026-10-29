#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
main_qml="$project_dir/Main.qml"
metadata="$project_dir/metadata.desktop"
theme_conf="$project_dir/theme.conf"
license_file="$project_dir/LICENSE"
failed=0

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    failed=1
}

if [[ ! -f "$main_qml" ]]; then
    fail "Main.qml is missing"
else
    while IFS= read -r import_line; do
        read -r _ module version _ <<<"$import_line"

        if [[ "$module" == "QtQuick" ]]; then
            continue
        fi

        if [[ "$module" == "QtQuick.Effects" ]]; then
            continue
        fi

        if [[ "$module" == "SddmComponents" && "$version" == "2.0" ]]; then
            continue
        fi

        fail "unsupported QML import: $import_line"
    done < <(rg --no-line-number '^\s*import\s+' "$main_qml")

    while IFS=: read -r line_number line_text; do
        value="${line_text#*font.pixelSize:}"
        value="${value%%;*}"
        value="${value%%//*}"
        value="${value//[[:space:]]/}"

        if [[ ! "$value" =~ ^[0-9]+$ ]]; then
            fail "font.pixelSize at line $line_number is not an integer: $value"
        fi
    done < <(rg -n 'font\.pixelSize\s*:' "$main_qml")

    if rg -n '\bComboBox\b' "$main_qml" >/dev/null; then
        fail "SddmComponents.ComboBox is forbidden for this theme"
    fi

    while IFS=: read -r line_number line_text; do
        if [[ "$line_text" =~ source:[[:space:]]*\"[^/\"] && \
              "$line_text" != *"Qt.resolvedUrl("* ]]; then
            fail "relative image source at line $line_number is not resolved"
        fi
    done < <(rg -n '^\s*source\s*:' "$main_qml" || true)
fi

if [[ ! -f "$metadata" ]]; then
    fail "metadata.desktop is missing"
else
    for required in \
        'Theme-API=2.0' \
        'QtVersion=6' \
        'License=GPL-3.0-or-later' \
        'MainScript=Main.qml' \
        'ConfigFile=theme.conf'; do
        if ! rg -Fqx -- "$required" "$metadata"; then
            fail "metadata.desktop is missing required entry: $required"
        fi
    done

    screenshot_path="$(sed -n 's/^Screenshot=//p' "$metadata" | head -n 1)"
    if [[ -n "$screenshot_path" && ! -f "$project_dir/$screenshot_path" ]]; then
        fail "metadata.desktop screenshot is missing: $screenshot_path"
    fi

    metadata_version="$(sed -n 's/^Version=//p' "$metadata" | head -n 1)"
    package_version="$(sed -n 's/^pkgver=//p' "$project_dir/PKGBUILD" | head -n 1)"
    if [[ -n "$metadata_version" && -n "$package_version" && "$metadata_version" != "$package_version" ]]; then
        fail "metadata.desktop and PKGBUILD versions differ: $metadata_version != $package_version"
    fi
fi

if [[ ! -f "$theme_conf" ]]; then
    fail "theme.conf is missing"
elif ! rg -Fqx -- 'autoSurfaceColors=true' "$theme_conf"; then
    fail "theme.conf is missing default autoSurfaceColors=true"
fi

if [[ ! -f "$license_file" ]]; then
    fail "LICENSE is missing"
fi

for asset in \
    assets/wallpaper.webp \
    assets/avatar.webp \
    assets/avatar-circle.webp \
    assets/preview.png \
    assets/icons/check.svg \
    assets/icons/chevron-down.svg \
    assets/icons/eye.svg \
    assets/icons/eye-off.svg \
    assets/icons/power.svg \
    assets/icons/restart.svg \
    assets/icons/sleep.svg \
    assets/icons/user-switch.svg; do
    if [[ ! -f "$project_dir/$asset" ]]; then
        fail "theme asset is missing: $asset"
    fi
done

if command -v qmllint >/dev/null 2>&1 && [[ -f "$main_qml" ]]; then
    if ! qmllint -I /usr/lib/qt6/qml "$main_qml"; then
        failed=1
    fi
fi

if (( failed != 0 )); then
    exit 1
fi

printf 'Theme checks passed.\n'
