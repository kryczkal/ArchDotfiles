# ArchDotfiles

This repository contains a collection of scripts and configuration files for setting up and managing an Arch Linux environment. The repository is tailored to my specific workflow and includes scripts that automate the installation and configuration of various software components and system settings.

### Scripts Overview

- `generate-github-ssh.sh`: Sets up SSH for GitHub by installing `openssh`, prompting for an email address, generating an SSH key, adding it to the SSH agent, and printing the public key.
- `install-apple-fonts.sh`: Installs Apple fonts and Meslo Nerd Font.
- `install-clipboard.sh`: Installs `wl-clipboard-git` for clipboard management.
- `install-lemurs.sh`: Installs `lemurs`, enables the service, and sets up default entries.
- `install-multi-monitor-support.sh`: Installs dependencies for multi-monitor setups and guides through the configuration process.
- `install-nouveau.sh`: Installs the Nouveau driver for NVIDIA graphics cards.
- `install-paru.sh`: Installs `paru` as an AUR helper and configures it with color and parallel downloads.
- `install-powerlevel10k.sh`: Installs the `powerlevel10k` theme for the Z shell and sets it as the default theme.
- `install-river.sh`: Installs the `river` Wayland compositor and configures the environment for its use.
- `install-rofi.sh`: Installs `rofi-lbonn-wayland-git` and optionally an icon theme.
- `install-rust-cli-utilities.sh`: Installs a set of Rust command-line utilities like `bat`, `lsd`, `procs`, `hexyl`, `xplr`, `fd`, and `bottom`.
- `install-sound.sh`: Sets up the Pipewire audio system and installs associated packages.
- `install-stow.sh`: Installs GNU Stow for managing dotfiles.
- `install-waybar.sh`: Installs `waybar`, `otf-font-awesome`, and `ttf-hack-nerd` for system bar customization.
- `install-zsh.sh`: Installs Z shell, sets it as the default shell, and optionally installs `oh-my-zsh`.
- `main-installer.sh`: The main script that can be used to invoke other scripts and manage the overall setup process.

### Usage

Given the personalized nature of this repository, usage by others is not recommended as the scripts may make significant changes to the system. If you wish to use any scripts or configurations from this repository, please review and understand the contents thoroughly before executing them.

### Contribution

Contributions are not sought after, as this repository is for personal use. However, if you find an issue or have a suggestion that could improve the setup, feel free to open an issue or submit a pull request.

### License

This repository is distributed under the MIT License. See `LICENSE` for more information.

### Acknowledgments

- Thanks to all the developers and maintainers of the software used in these scripts.
- The Arch Linux community for their extensive documentation and forums.

### Disclaimer

The scripts and configurations in this repository are provided "as is" without warranty of any kind. Users should use them at their own risk.
