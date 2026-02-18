#!/usr/bin/env bash
# Shell aliases — sourced by .bashrc / .zshrc
# Managed by stow, edit this file instead of appending to rc files.

# Terminal spawning
alias .='$TERM --working-directory=$(pwd) & disown'

# Modern CLI replacements (lsd, bat)
alias ls="lsd"
alias l="lsd -lah"
alias cat="bat"

# Colored help/man via bat
alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
