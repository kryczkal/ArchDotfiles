# Thin loader. Options live in ~/.config/shell/. Managed by stow (ArchDotfiles).

# p10k instant prompt: keep first, nothing may print above it.
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
