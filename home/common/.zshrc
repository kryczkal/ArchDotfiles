# .zshrc: interactive-shell loader. Managed by stow (ArchDotfiles).
# .zshenv loads env.sh + path.sh for every shell; they are re-sourced here
# because /etc/profile runs in between for login shells.
# Only `source` lines, in this order. Options live in ~/.config/shell/:
#   env.sh        exports          path.sh       PATH
#   zsh/options.zsh  setopt/keys   aliases.sh    aliases
#   zsh/bat-help.zsh global -h aliases (must stay last)
#   local.sh      machine-only, secrets, gitignored
# If a tool appended lines here, that is drift: move them to the right file.

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/.config/shell/env.sh
source ~/.config/shell/path.sh
source ~/.config/shell/zsh/options.zsh
source ~/.config/shell/aliases.sh

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ ! -r /usr/share/clippy/clippy.zsh ]] || source /usr/share/clippy/clippy.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Parse-time global aliases: nothing with a bare -h/--help may be parsed after this.
source ~/.config/shell/zsh/bat-help.zsh
# Machine-local overrides and secrets. Gitignored.
[[ ! -f ~/.config/shell/local.sh ]] || source ~/.config/shell/local.sh
