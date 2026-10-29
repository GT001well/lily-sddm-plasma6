#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
full_preview="$project_dir/docs/preview.png"
kcm_preview="$project_dir/assets/preview.png"

"$project_dir/scripts/render-qml-preview.py"

if command -v magick >/dev/null 2>&1; then
    magick "$full_preview" -resize 960x540 -colors 256 "PNG8:$kcm_preview"
elif command -v convert >/dev/null 2>&1; then
    convert "$full_preview" -resize 960x540 -colors 256 "PNG8:$kcm_preview"
else
    printf 'ImageMagick is required to generate %s\n' "$kcm_preview" >&2
    exit 1
fi

printf 'Rendered %s and %s\n' "$full_preview" "$kcm_preview"
