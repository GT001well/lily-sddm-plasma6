#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/lib-check.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib-check.sh"
staging_dir="$(mktemp -d "${TMPDIR:-/tmp}/lily-sddm-package.XXXXXX")"

cleanup() {
    rm -rf "$staging_dir"
}
trap cleanup EXIT

for packaging_file in \
    debian/control \
    debian/rules \
    debian/copyright \
    packaging/rpm/lily-sddm-plasma6.spec; do
    require_file "$project_dir/$packaging_file" \
        "packaging metadata is missing: $packaging_file"
done

metadata_version="$(sed -n 's/^Version=//p' "$project_dir/metadata.desktop" | head -n 1)"
rpm_version="$(
    awk '$1 == "Version:" { print $2; exit }' \
        "$project_dir/packaging/rpm/lily-sddm-plasma6.spec"
)"
debian_version="$(
    sed -n '1s/.*(\([^)]*\)).*/\1/p' "$project_dir/debian/changelog" |
        sed 's/-[^-]*$//'
)"
debian_source_format="$(sed -n '1p' "$project_dir/debian/source/format")"
debian_package_version="$(
    sed -n '1s/.*(\([^)]*\)).*/\1/p' "$project_dir/debian/changelog"
)"

if [[ "$debian_source_format" != "3.0 (quilt)" ]]; then
    fail "Debian source format must be 3.0 (quilt)"
fi
if [[ ! "$debian_package_version" =~ ^.+-[0-9]+$ ]]; then
    fail "Debian version must include a revision: $debian_package_version"
fi

for version_entry in \
    "RPM:$rpm_version" \
    "Debian:$debian_version"; do
    if [[ "${version_entry#*:}" != "$metadata_version" ]]; then
        fail "version mismatch: ${version_entry%%:*} has ${version_entry#*:}, expected $metadata_version"
    fi
done

rpm_spec="$project_dir/packaging/rpm/lily-sddm-plasma6.spec"
debian_control="$project_dir/debian/control"

require_match "$rpm_spec" 'qt6-qtsvg' \
    "RPM spec must require the Fedora Qt SVG package"
require_match "$rpm_spec" 'libQt6Svg6' \
    "RPM spec must require the openSUSE Qt SVG package"
require_match "$debian_control" 'qml6-module-qtquick-effects' \
    "Debian control must require the Qt Quick Effects QML module"
require_match "$debian_control" '^Build-Depends:.*ripgrep' \
    "Debian control must require ripgrep for project checks"
require_match "$rpm_spec" '^BuildRequires:[[:space:]]+ripgrep$' \
    "RPM spec must require ripgrep for project checks"
require_fixed_match "$rpm_spec" '%doc %{_docdir}/%{name}/README.en.md' \
    "RPM spec must package README.en.md"

if [[ -f "$project_dir/PKGBUILD" ]]; then
    pkgbuild="$project_dir/PKGBUILD"
    arch_version="$(sed -n 's/^pkgver=//p' "$project_dir/PKGBUILD" | head -n 1)"
    if [[ "$arch_version" != "$metadata_version" ]]; then
        fail "version mismatch: PKGBUILD has $arch_version, expected $metadata_version"
    fi
    require_match "$pkgbuild" 'qt6-svg' \
        "PKGBUILD must require qt6-svg for SVG icons"
    require_match "$pkgbuild" "makedepends=\\('ripgrep'\\)" \
        "PKGBUILD must require ripgrep for project checks"
    require_match "$pkgbuild" '^source=\(.+\)$' \
        "PKGBUILD must declare a downloadable source"
    require_match "$pkgbuild" "^sha256sums=\\('[0-9a-f]{64}'\\)$" \
        "PKGBUILD must declare a concrete SHA-256 checksum"
    # shellcheck disable=SC2016
    require_fixed_match "$pkgbuild" 'make -C "$srcdir/$pkgname-$pkgver"' \
        "PKGBUILD must build from the extracted source directory"
fi

if ! make -C "$project_dir" install DESTDIR="$staging_dir" PREFIX=/usr >/dev/null; then
    fail "common install target failed"
else
    theme_dir="$staging_dir/usr/share/sddm/themes/lily-sddm-plasma6"
    for installed_file in \
        Main.qml metadata.desktop theme.conf \
        assets/wallpaper.webp \
        assets/preview.png assets/icons/check.svg \
        LICENSE CC-BY-SA-4.0.txt; do
        require_one_of "common install target is missing: $installed_file" \
            "$theme_dir/$installed_file" \
            "$staging_dir/usr/share/licenses/lily-sddm-plasma6/$installed_file"
    done
fi

finish_checks "Packaging checks passed."
