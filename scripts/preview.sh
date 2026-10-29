#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
greeter="${SDDM_GREETER:-/usr/bin/sddm-greeter-qt6}"

if [[ ! -x "$greeter" ]]; then
    printf 'SDDM Qt 6 greeter not found: %s\n' "$greeter" >&2
    exit 1
fi

printf 'Previewing %s with %s\n' "$project_dir" "$greeter"
printf 'This does not modify the system SDDM configuration.\n'

exec "$greeter" --test-mode --theme "$project_dir"
