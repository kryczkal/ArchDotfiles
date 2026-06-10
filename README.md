# Arch Dotfiles

Personal dotfiles and bootstrap scripts for Arch Linux with River (Wayland).

## Quick Start

```bash
# Fresh Arch install → working environment in one command:
git clone https://github.com/kryczkal/ArchDotfiles.git
cd ArchDotfiles
./bootstrap.sh --profile desktop-nvidia
```

## Available Profiles

| Profile | Description |
|---|---|
| `desktop-nvidia` | Desktop with NVIDIA proprietary drivers |
| `desktop-nouveau` | Desktop with open-source nouveau drivers |
| `laptop` | Laptop (integrated GPU, battery/brightness support) |

## What Gets Installed

The bootstrap runs modules in phases:

| Phase | What |
|---|---|
| `00-system` | Locale, clock, user groups |
| `01-packages` | Paru (AUR helper), linux headers |
| `02-shell` | Zsh, Powerlevel10k, Rust CLI tools (bat, lsd, fd, etc.) |
| `03-desktop` | River WM, Waybar, Rofi, Mako, PipeWire, screenshots, clipboard |
| `04-gpu` | NVIDIA proprietary or nouveau drivers |
| `05-apps` | Yazi, Nautilus, OBS |
| `99-finalize` | Stow dotfiles, SSH key, GPG key |

## Dotfiles (Stow Packages)

Configs are managed with [GNU Stow](https://www.gnu.org/software/stow/). Packages:

- **common** — shell (zsh/p10k + `~/.config/shell/`), nvim, tmux, alacritty, river, rofi, lsd, bottom, zed, swayidle, mimeapps, `~/.local/bin` scripts
- **desktop** — waybar config (desktop variant, GPU temp monitoring)
- **laptop** — waybar config (laptop variant, battery/brightness)
- **nvidia** — chromium flags for NVIDIA
- **default-gpu** — chromium flags for non-NVIDIA

On conflicts the repo wins: existing real files are backed up to `*.pre-stow`
before linking (never `--adopt`).

### Shell options

`~/.zshrc` / `~/.zprofile` are thin, stowed loaders — the actual options live
in topical files under `~/.config/shell/` (`env.sh`, `path.sh`, `aliases.sh`,
`functions.sh`, `zsh/bat-help.zsh`). Edit those, not the rc files.
Machine-local one-offs and secrets go in `~/.config/shell/local.sh`
(gitignored, sourced last if present).

Committing dotfile changes from anywhere:

```bash
dots status     # git in this repo from any cwd
dots-commit     # stage all + commit with generated summary + push
```

## Usage

```bash
./bootstrap.sh --help       # Show usage and profiles
./bootstrap.sh --list       # List profiles
./bootstrap.sh --dry-run --profile laptop   # Preview without installing
```

## Runtime Scripts

Utility scripts in `scripts/` for day-to-day use (not part of bootstrap):

- `chromium-app-manager.sh` — Create/manage Chromium PWA shortcuts
- `display-settings.sh` — Monitor arrangement via way-displays
- `input-enabler.sh` — Map input devices to outputs (tablets, etc.)
