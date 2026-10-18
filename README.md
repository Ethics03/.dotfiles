# dotfiles

My Arch Linux / Hyprland desktop, with Catppuccin Mocha colors and muted blue accents.
Managed with Git and GNU Stow. Each top-level package mirrors its paths in `$HOME`,
following [ThePrimeagen's layout](https://github.com/ThePrimeagen/.dotfiles).

![Hyprland desktop with Waybar, Neovim, Kitty, tmux, Fastfetch and Thunar](.github/assets/desktop.png)

```text
hypr/.config/hypr/hyprland.lua  → ~/.config/hypr/hyprland.lua
kitty/.config/kitty/kitty.conf  → ~/.config/kitty/kitty.conf
tmux/.tmux.conf                → ~/.tmux.conf
```

## Packages

| Package | Contents |
| --- | --- |
| `hypr` | Hyprland, monitors, Hypridle, Hyprlock, Hyprtoolkit, screenshots and wallpaper picker |
| `waybar` | Bar layout, CSS and SVG icons |
| `walker` | Launcher configuration and Mocha theme |
| `services` | User services for Walker, Elephant, Waybar and awww |
| `kitty`, `fish`, `starship`, `tmux` | Terminal, shell, prompt and multiplexer |
| `mako`, `fastfetch` | Notifications and system information |
| `nvim` | LazyVim configuration and plugin lockfile |
| `gtk`, `qt6ct` | GTK, Qt, fonts and cursor preferences |
| `thunar` | File manager preferences and custom actions |
| `applications` | Default apps, wallpaper launcher and native Wayland flags |
| `wireplumber` | Keep Bluetooth high-fidelity playback; select headset mode manually |

## Link configs

Install Stow, clone the repo, and move any conflicting configs into a backup first.
Stow reports conflicts instead of replacing existing files.

```sh
sudo pacman -S --needed stow
git clone https://github.com/Ethics03/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
stow --simulate --verbose --target="$HOME" */
stow --target="$HOME" */
systemctl --user daemon-reload
```

The explicit target matters: the repo lives in `~/dev`, while the links belong in
the home directory. To link or unlink individual packages:

```sh
stow --target="$HOME" kitty tmux
stow --delete --target="$HOME" kitty tmux
```

## Save changes

Edit the usual files under `~/.config`; the symlinks point into this repo.
Git tracks local edits immediately. Commit and push when ready:

```sh
cd ~/dev/dotfiles
git status
git diff
git add <changed-files>
git commit -m "Describe the config change"
git push
```

On another checkout, use `git pull --ff-only` with a clean working tree, then
`stow --restow --target="$HOME" */` to refresh links for added or removed files.
Reload affected applications as needed. There is no automatic commit or push job.

## Requirements

The current desktop uses these Arch packages:

```text
hyprland hypridle hyprlock hyprpolkitagent waybar kitty fish starship tmux
mako awww grim slurp wl-clipboard libnotify brightnessctl playerctl python
thunar tumbler gvfs qt6ct nwg-look breeze-icons inter-font ttf-jetbrains-mono-nerd
pipewire pipewire-pulse wireplumber bluez blueman pavucontrol
network-manager-applet power-profiles-daemon
xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
fastfetch neovim fd ripgrep fzf lazygit tree-sitter-cli stow
```

Walker uses `walker-bin`, `elephant` and `elephant-desktopapplications` from the AUR.
Hyprland starts the user services after importing the Wayland session environment.
NetworkManager, Bluetooth and power-profiles-daemon also need their system services.
The application defaults reference Helium, Vesktop and spotify-launcher.

Theme assets are installed separately:

- [Catppuccin GTK](https://github.com/catppuccin/gtk):
  `catppuccin-mocha-blue-standard+default` in `~/.local/share/themes`.
- [Bibata cursors](https://github.com/ful1e5/Bibata_Cursor):
  `Bibata-Modern-Classic` in `~/.local/share/icons`.

GTK 4 additionally uses these links, created by nwg-look on the current machine.
After installing the theme, recreate them if absent:

```sh
ln -s "$HOME/.local/share/themes/catppuccin-mocha-blue-standard+default/gtk-4.0/assets" "$HOME/.config/gtk-4.0/assets"
ln -s "$HOME/.local/share/themes/catppuccin-mocha-blue-standard+default/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
ln -s "$HOME/.local/share/themes/catppuccin-mocha-blue-standard+default/gtk-4.0/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"
```

Keep wallpaper images in `~/Pictures/Wallpapers`; press **Super + W** to choose one.
Wallpapers, theme distributions, application data, credentials and caches are not
stored here. System files such as SDDM, boot configuration and drivers are managed
separately.

## Machine-specific settings

This is a personal setup using Hyprland's Lua configuration. Before using it on
another machine, review `hypr/.config/hypr/monitors.lua` (display names/scales) and
`waybar/.config/waybar/config.jsonc` (outputs, backlight device and battery name).
The Qt palette path, GTK 2 include, Thunar wallpaper action and wallpaper desktop
entry currently reference `/home/nev`; adjust those paths for another username.

Bluetooth uses the laptop mic with A2DP playback. In pavucontrol's Configuration
tab, choose **Headset Head Unit (mSBC)** when the headphone mic is needed, then
select it as the voice-chat input. Choose **High Fidelity Playback (AAC)** and the
laptop input to restore stereo quality. WirePlumber reads the versioned policy
at its next start; runtime changes made with `wpctl settings --save` take precedence.

## Shortcuts

| Shortcut | Action |
| --- | --- |
| Super + Q / E / R | Kitty / Thunar / Walker |
| Super + L / F / W | Lock / fullscreen / wallpapers |
| Print / Shift + Print | Full screenshot / selected region |
| Super + 1–0 | Switch workspace |
| Super + Shift + 1–0 | Move window to workspace |
| Super + Ctrl + M | Toggle mirror / extended layout |
| Super + Ctrl + O / I | Disable or restore external / laptop display |
| Ctrl + Space | tmux prefix |
