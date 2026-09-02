# options.zsh: zsh behaviour only: setopt, history, completion, bindkey.
# Managed by stow (ArchDotfiles). Not here: exports (env.sh), aliases
# (aliases.sh). Replaces oh-my-zsh (dropped 2026-09-02).

mkdir -p "$XDG_STATE_HOME/zsh"
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000
setopt share_history hist_ignore_dups hist_ignore_space hist_expire_dups_first extended_history
setopt auto_cd interactive_comments no_beep

bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

fpath=(~/.local/share/zsh/site-functions $fpath)
autoload -Uz compinit
mkdir -p ~/.cache && compinit -d ~/.cache/zcompdump
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
