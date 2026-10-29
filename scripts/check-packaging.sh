#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
staging_dir="$(mktemp -d "${TMPDIR:-/tmp}/lily-sddm-package.XXXXXX")"
failed=0

cleanup() {
    rm -rf "$staging_dir"
}
trap cleanup EXIT

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    failed=1
}

for packaging_file in \
    PKGBUILD \
    debian/control \
    debian/rules \
    debian/copyright \
    packaging/rpm/lily-sddm-plasma6.spec; do
    if [[ ! -f "$project_dir/$packaging_file" ]]; then
        fail "packaging metadata is missing: $packaging_file"
    fi
done

metadata_version="$(sed -n 's/^Version=//p' "$project_dir/metadata.desktop" | head -n 1)"
arch_version="$(sed -n 's/^pkgver=//p' "$project_dir/PKGBUILD" | head -n 1)"
rpm_version="$(
    awk '$1 == "Version:" { print $2; exit }' \
        "$project_dir/packaging/rpm/lily-sddm-plasma6.spec"
)"
debian_version="$(
    sed -n '1s/.*(\([^)]*\)).*/\1/p' "$project_dir/debian/changelog" |
        sed 's/-[^-]*$//'
)"

for version_entry in \
    "PKGBUILD:$arch_version" \
    "RPM:$rpm_version" \
    "Debian:$debian_version"; do
    if [[ "${version_entry#*:}" != "$metadata_version" ]]; then
        fail "version mismatch: ${version_entry%%:*} has ${version_entry#*:}, expected $metadata_version"
    fi
done

if ! rg -q 'qt6-svg' "$project_dir/PKGBUILD"; then
    fail "PKGBUILD must require qt6-svg for SVG icons"
fi
if ! rg -q 'qt6-qtsvg' "$project_dir/packaging/rpm/lily-sddm-plasma6.spec"; then
    fail "RPM spec must require the Fedora Qt SVG package"
fi
if ! rg -q 'libQt6Svg6' "$project_dir/packaging/rpm/lily-sddm-plasma6.spec"; then
    fail "RPM spec must require the openSUSE Qt SVG package"
fi
if ! rg -q 'qml6-module-qtquick-effects' "$project_dir/debian/control"; then
    fail "Debian control must require the Qt Quick Effects QML module"
fi

if ! make -C "$project_dir" install DESTDIR="$staging_dir" PREFIX=/usr >/dev/null; then
    fail "common install target failed"
else
    theme_dir="$staging_dir/usr/share/sddm/themes/lily-sddm-plasma6"
    for installed_file in \
        Main.qml metadata.desktop theme.conf \
        assets/wallpaper.webp \
        assets/preview.png assets/icons/check.svg \
        LICENSE; do
        if [[ ! -f "$theme_dir/$installed_file" && \
              ! -f "$staging_dir/usr/share/licenses/lily-sddm-plasma6/$installed_file" ]]; then
            fail "common install target is missing: $installed_file"
        fi
    done
fi

if (( failed != 0 )); then
    exit 1
fi

printf 'Packaging checks passed.\n'
