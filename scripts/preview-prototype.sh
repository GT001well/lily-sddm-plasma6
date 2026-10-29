#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
prototype_url="file://$project_dir/prototype/index.html"

if ! command -v xdg-open >/dev/null 2>&1; then
    printf 'xdg-open is not available. Open this file manually:\n%s\n' "$prototype_url" >&2
    exit 1
fi

printf 'Opening HTML layout prototype: %s\n' "$prototype_url"
exec xdg-open "$prototype_url"
