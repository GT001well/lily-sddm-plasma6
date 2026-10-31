#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/lib-check.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib-check.sh"
main_qml="$project_dir/Main.qml"
metadata="$project_dir/metadata.desktop"
theme_conf="$project_dir/theme.conf"
license_file="$project_dir/LICENSE"

require_file "$main_qml" "Main.qml is missing"
if [[ -f "$main_qml" ]]; then
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

        if [[ "$value" =~ ^[0-9]+$ ]]; then
            continue
        fi

        if [[ "$value" =~ ^root\.([A-Za-z_][A-Za-z0-9_]*)$ ]] &&
              rg -q "^[[:space:]]*readonly property int ${BASH_REMATCH[1]}:" "$main_qml"; then
            continue
        fi

        fail "font.pixelSize at line $line_number is not an integer: $value"
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

require_file "$metadata" "metadata.desktop is missing"
if [[ -f "$metadata" ]]; then
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

fi

require_file "$theme_conf" "theme.conf is missing"
if [[ -f "$theme_conf" ]]; then
    require_fixed_match "$theme_conf" "autoSurfaceColors=true" \
        "theme.conf is missing default autoSurfaceColors=true"
fi

require_file "$license_file" "LICENSE is missing"

for asset in \
    assets/wallpaper.webp \
    assets/preview.png \
    assets/icons/check.svg \
    assets/icons/chevron-down.svg \
    assets/icons/eye.svg \
    assets/icons/eye-off.svg \
    assets/icons/power.svg \
    assets/icons/restart.svg \
    assets/icons/sleep.svg \
    assets/icons/user-switch.svg; do
    require_file "$project_dir/$asset" "theme asset is missing: $asset"
done

for removed_asset in \
    assets/avatar.webp \
    assets/avatar-circle.webp; do
    require_absent "$project_dir/$removed_asset" \
        "removed avatar asset must not be present: $removed_asset"
done

if command -v qmllint >/dev/null 2>&1 && [[ -f "$main_qml" ]]; then
    qml_import_dir=""
    if command -v qmake6 >/dev/null 2>&1; then
        qml_import_dir="$(qmake6 -query QT_INSTALL_QML 2>/dev/null || true)"
    fi

    if [[ ! -d "$qml_import_dir" ]]; then
        for candidate in \
            /usr/lib/qt6/qml \
            /usr/lib64/qt6/qml \
            /usr/lib/*-linux-gnu/qt6/qml; do
            if [[ -d "$candidate" ]]; then
                qml_import_dir="$candidate"
                break
            fi
        done
    fi

    qmllint_args=()
    if [[ -d "$qml_import_dir" ]]; then
        qmllint_args=(-I "$qml_import_dir")
    fi

    if ! qmllint "${qmllint_args[@]}" "$main_qml"; then
        failed=1
    fi
fi

finish_checks "Theme checks passed."
