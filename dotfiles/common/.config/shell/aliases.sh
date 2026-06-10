# Shell aliases — sourced by .zshrc. Managed by stow (ArchDotfiles).
# Global -h/--help aliases live in zsh/bat-help.zsh (load-order sensitive).

# Spawn a new terminal in the current directory
alias .='$TERM --working-directory=$(pwd) & disown'

# Modern CLI replacements (lsd, bat)
alias ls="lsd"
alias l="lsd -lah"
alias cat="bat -p"

alias paru='paru --color=always'
