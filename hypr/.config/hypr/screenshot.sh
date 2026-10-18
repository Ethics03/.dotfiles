#!/usr/bin/env bash
set -euo pipefail

mode=${1:-screen}
geometry=
case "$mode" in
    screen) ;;
    region)
        # Escape cancels without creating a file or changing the clipboard.
        geometry=$(slurp -d -b '#1e1e2e88' -c '#cba6f7' -s '#cba6f722') || exit 0
        [[ -n "$geometry" ]] || exit 0
        ;;
    *) printf 'Usage: %s [screen|region]\n' "$0" >&2; exit 2 ;;
esac

pictures="$HOME/Pictures"
if command -v xdg-user-dir >/dev/null 2>&1; then
    pictures=$(xdg-user-dir PICTURES)
fi
directory="$pictures/Screenshots"
mkdir -p -- "$directory"
file=$(mktemp "$directory/Screenshot-$(date +%Y-%m-%d_%H-%M-%S)-XXXXXX.png")
# Remove an incomplete file if capture fails.
trap 'rm -f -- "$file"' EXIT
if [[ "$mode" == region ]]; then
    grim -g "$geometry" "$file"
else
    grim "$file"
fi
trap - EXIT

if wl-copy --type image/png < "$file"; then
    notify-send --app-name=Screenshot --expire-time=4000 'Screenshot saved and copied' "$file" || true
else
    notify-send --app-name=Screenshot --urgency=normal 'Screenshot saved; clipboard copy failed' "$file" || true
    exit 1
fi
