#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/lib-check.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib-check.sh"
prototype_dir="$project_dir/prototype"

for file in index.html styles.css app.js; do
    require_file "$prototype_dir/$file" "prototype/$file is missing"
done

require_file "$project_dir/assets/wallpaper.webp" "assets/wallpaper.webp is missing"

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
    require_fixed_match "$prototype_dir/index.html" 'id="avatar-fallback"' \
        "avatar initial fallback is missing from the prototype"

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
    require_fixed_match "$prototype_dir/styles.css" \
        'url("../assets/wallpaper.webp")' \
        "wallpaper asset is not referenced by the prototype"

    hidden_menu_count="$(
        rg -F -c 'aria-hidden="true" inert' "$prototype_dir/index.html" || true
    )"
    hidden_menu_count="${hidden_menu_count:-0}"

    if (( hidden_menu_count < 2 )); then
        fail "popover menus must start hidden and inert in HTML"
    fi
fi

finish_checks "Prototype checks passed."
