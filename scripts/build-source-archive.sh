#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
package_name="lily-sddm-plasma6"
version="$(sed -n 's/^Version=//p' "$project_dir/metadata.desktop" | head -n 1)"
archive_name="${package_name}-${version}.tar.gz"
archive_path="$project_dir/dist/$archive_name"
staging_dir="$(mktemp -d "${TMPDIR:-/tmp}/lily-sddm-dist.XXXXXX")"

cleanup() {
    rm -rf "$staging_dir"
}
trap cleanup EXIT

source_dir="$staging_dir/$package_name-$version"
mkdir -p "$source_dir" "$project_dir/dist"

for source in \
    Main.qml metadata.desktop theme.conf Makefile PKGBUILD \
    README.md README.en.md CHANGELOG.md LICENSE \
    assets docs NOTE prototype scripts debian packaging; do
    cp -a "$project_dir/$source" "$source_dir/"
done

rm -rf "$source_dir/scripts/__pycache__"

tar \
    --sort=name \
    --owner=0 \
    --group=0 \
    --numeric-owner \
    -C "$staging_dir" \
    -czf "$archive_path" \
    "$package_name-$version"

printf '%s\n' "$archive_path"
