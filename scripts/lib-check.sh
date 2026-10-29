# shellcheck shell=bash

# shellcheck disable=SC2034
project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
failed=0

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    failed=1
}

require_file() {
    local path="$1"
    local message="$2"
    if [[ ! -f "$path" ]]; then
        fail "$message"
    fi
}

require_executable() {
    local path="$1"
    local message="$2"
    if [[ ! -x "$path" ]]; then
        fail "$message"
    fi
}

require_absent() {
    local path="$1"
    local message="$2"
    if [[ -e "$path" ]]; then
        fail "$message"
    fi
}

require_one_of() {
    local message="$1"
    shift
    local path
    for path in "$@"; do
        if [[ -f "$path" ]]; then
            return
        fi
    done
    fail "$message"
}

require_match() {
    local path="$1"
    local pattern="$2"
    local message="$3"
    if ! rg -q -- "$pattern" "$path"; then
        fail "$message"
    fi
}

require_fixed_match() {
    local path="$1"
    local text="$2"
    local message="$3"
    if ! rg -Fq -- "$text" "$path"; then
        fail "$message"
    fi
}

finish_checks() {
    if (( failed != 0 )); then
        exit 1
    fi
    printf '%s\n' "$1"
}
