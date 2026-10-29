#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
prototype_dir="$project_dir/prototype"
failed=0

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    failed=1
}

for file in index.html styles.css app.js; do
    if [[ ! -f "$prototype_dir/$file" ]]; then
        fail "prototype/$file is missing"
    fi
done

if [[ ! -f "$project_dir/assets/wallpaper.webp" ]]; then
    fail "assets/wallpaper.webp is missing"
fi

if [[ ! -f "$project_dir/assets/avatar.webp" ]]; then
    fail "assets/avatar.webp is missing"
fi

if command -v node >/dev/null 2>&1 && [[ -f "$prototype_dir/app.js" ]]; then
    node --check "$prototype_dir/app.js" || failed=1
fi

if [[ -f "$prototype_dir/styles.css" ]]; then
    missing_tokens="$(
        comm -23 \
            <(rg -o 'var\(--[a-z0-9-]+' "$prototype_dir/styles.css" |
                sed 's/var(//' | sort -u) \
            <(rg -o '^\s*--[a-z0-9-]+' "$prototype_dir/styles.css" |
                sed 's/^[[:space:]]*//' | sort -u)
    )"

    if [[ -n "$missing_tokens" ]]; then
        fail "undefined CSS tokens: $missing_tokens"
    fi

    direct_colors="$(
        awk '
            /:root \{/ { in_root = 1 }
            in_root && /^\}/ { in_root = 0; next }
            !in_root { print }
        ' "$prototype_dir/styles.css" |
            rg -n '(#[0-9a-fA-F]{3,8}|\b(rgb|rgba|hsl|hsla)\s*\()' || true
    )"

    if [[ -n "$direct_colors" ]]; then
        fail "colors outside :root tokens: $direct_colors"
    fi

    login_content_animation="$(
        sed -n '/^\.login-content {/,/^}/p' "$prototype_dir/styles.css" |
            rg 'animation\s*:' || true
    )"

    if [[ -n "$login_content_animation" ]]; then
        fail "login content must not animate on page load: $login_content_animation"
    fi

    if rg -n 'mask-image\s*:.*linear-gradient' "$prototype_dir/styles.css" >/dev/null; then
        fail "the glass rail must keep a hard right edge"
    fi
fi

if [[ -f "$prototype_dir/index.html" ]]; then
    rg -Fq 'src="../assets/avatar.webp"' "$prototype_dir/index.html" ||
        fail "avatar asset is not referenced by the prototype"

    duplicate_ids="$(
        rg -o 'id="[^"]+"' "$prototype_dir/index.html" |
            sed 's/^id="//; s/"$//' |
            sort |
            uniq -d
    )"

    if [[ -n "$duplicate_ids" ]]; then
        fail "duplicate HTML ids: $duplicate_ids"
    fi

    if [[ -f "$prototype_dir/app.js" ]]; then
        while IFS= read -r element_id; do
            if ! rg -Fq "id=\"$element_id\"" "$prototype_dir/index.html"; then
                fail "JavaScript selector references a missing id: #$element_id"
            fi
        done < <(
            rg -o 'querySelector\("#[A-Za-z0-9_-]+' "$prototype_dir/app.js" |
                sed 's/.*#//'
        )
    fi
fi

if [[ -f "$prototype_dir/styles.css" ]]; then
    rg -Fq 'url("../assets/wallpaper.webp")' "$prototype_dir/styles.css" ||
        fail "wallpaper asset is not referenced by the prototype"

    hidden_menu_count="$(
        rg -F -c 'aria-hidden="true" inert' "$prototype_dir/index.html" || true
    )"
    hidden_menu_count="${hidden_menu_count:-0}"

    if (( hidden_menu_count < 2 )); then
        fail "popover menus must start hidden and inert in HTML"
    fi
fi

if (( failed != 0 )); then
    exit 1
fi

printf 'Prototype checks passed.\n'
