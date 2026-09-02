# env.sh: exported variables only. Managed by stow (ArchDotfiles).
# Not here: PATH (path.sh), aliases (aliases.sh), setopt/bindkey/completion
# (zsh/options.zsh), secrets and machine-only values (local.sh, gitignored).
# Sourced twice (.zshenv, .zshrc): every line must be idempotent.
# App state stays where apps put it (no XDG routing, decided 2026-09-02).

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=1280000
