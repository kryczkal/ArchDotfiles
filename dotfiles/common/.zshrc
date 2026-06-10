# Thin loader — actual options live in ~/.config/shell/. Edit those, not this.
# Managed by stow (ArchDotfiles).

# Powerlevel10k instant prompt. Keep at the top; anything that prints during
# init must go above this block.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# User completions — must be in fpath before oh-my-zsh runs compinit.
fpath=(~/.local/share/zsh/site-functions $fpath)

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

# Topical option files. env+path also load from .zprofile for login shells;
# re-sourcing here covers non-login shells and is idempotent (typeset -U).
source ~/.config/shell/env.sh
source ~/.config/shell/path.sh
source ~/.config/shell/aliases.sh
source ~/.config/shell/functions.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Parse-time global aliases — MUST stay last (see comments in the file).
source ~/.config/shell/zsh/bat-help.zsh

# Machine-local overrides, gitignored. Secrets go here, never in tracked files.
[[ ! -f ~/.config/shell/local.sh ]] || source ~/.config/shell/local.sh
