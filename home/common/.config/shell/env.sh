# Environment variables. Sourced by .zprofile (login) and .zshrc (interactive).
# Managed by stow (ArchDotfiles). Must load before path.sh.

# XDG base dirs. Everything below routes app state out of ~ into these.
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=1280000

# App state routing (xdg-ninja, 2026-09-02). Add a line here when a new tool
# litters ~, or `dots ignore` it if it has no knob.
export ANDROID_HOME=/opt/android-sdk
export ANDROID_USER_HOME="$XDG_DATA_HOME/android"
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials"
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"
export CALCHISTFILE="$XDG_CACHE_HOME/calc_history"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export DOTNET_CLI_HOME="$XDG_DATA_HOME/dotnet"
export GOPATH="$XDG_DATA_HOME/go"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NUGET_PACKAGES="$XDG_CACHE_HOME/NuGetPackages"
export OMNISHARPHOME="$XDG_CONFIG_HOME/omnisharp"
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
export WINEPREFIX="$XDG_DATA_HOME/wine"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
