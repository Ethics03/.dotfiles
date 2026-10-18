#!/usr/bin/env python3
"""Pick an image from Pictures/Wallpapers using Walker and apply it with awww."""

from pathlib import Path
import argparse
import os
import subprocess
import time


WALLPAPERS = Path.home() / "Pictures/Wallpapers"
IMAGE_TYPES = {".png", ".jpg", ".jpeg", ".webp", ".avif", ".gif", ".bmp", ".tif", ".tiff"}
STATE = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "hypr/wallpaper"


def notify(message):
    subprocess.run(["notify-send", "--app-name=Wallpapers", "Wallpapers", message], check=False)


def apply_wallpaper(image, restoring=False):
    if not image.is_file():
        notify(f"Image no longer exists: {image}")
        return
    subprocess.run(["systemctl", "--user", "start", "awww.service"], check=True)
    for _ in range(40):
        if subprocess.run(["awww", "query"], capture_output=True).returncode == 0:
            break
        time.sleep(0.05)
    else:
        raise RuntimeError("The wallpaper service did not become ready.")

    subprocess.run(
        ["awww", "img", "--transition-type", "none" if restoring else "fade",
         "--transition-duration", "0.6", "--transition-fps", "60", str(image)], check=True,
    )
    STATE.parent.mkdir(parents=True, exist_ok=True)
    STATE.write_text(str(image))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--restore", action="store_true", help="Restore the last selection")
    mode.add_argument("--set", type=Path, metavar="IMAGE", help="Apply an image directly")
    args = parser.parse_args()

    if args.set is not None:
        image = args.set.expanduser().resolve()
        if image.suffix.lower() not in IMAGE_TYPES:
            parser.error("Choose a supported image file")
        apply_wallpaper(image)
        return

    if args.restore:
        if STATE.is_file():
            apply_wallpaper(Path(STATE.read_text()), restoring=True)
        return

    WALLPAPERS.mkdir(parents=True, exist_ok=True)
    images = sorted(
        (p for p in WALLPAPERS.rglob("*") if p.is_file() and p.suffix.lower() in IMAGE_TYPES),
        key=lambda p: str(p.relative_to(WALLPAPERS)).casefold(),
    )
    if not images:
        notify(f"Add images to {WALLPAPERS}, then press Super + W.")
        return

    # Return Walker's selected row index, so filenames are never parsed as commands.
    names = [str(p.relative_to(WALLPAPERS)).replace("\n", " ").replace("\r", " ").strip() for p in images]
    result = subprocess.run(
        ["walker", "--dmenu", "--index", "--placeholder", "Choose wallpaper…"],
        input="\n".join(names) + "\n", text=True, capture_output=True,
    )
    selection = result.stdout.strip()
    if result.returncode or not selection:
        return
    try:
        index = int(selection)
        if not 0 <= index < len(images):
            raise ValueError("Invalid selection index")
    except ValueError:
        notify("Walker returned an invalid selection.")
        return

    apply_wallpaper(images[index])


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, subprocess.CalledProcessError) as error:
        notify(f"Could not change wallpaper: {error}")
        raise SystemExit(1)
