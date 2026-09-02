# path.sh: PATH entries only. Managed by stow (ArchDotfiles). Sourced by .zshenv and .zshrc.
# Not here: exports (env.sh). typeset -U dedupes, so double-sourcing is safe.
# An installer that appends PATH to .zshrc/.profile is drift: move the line
# here if every machine needs it, to local.sh if only this one does.

typeset -U path PATH
path+=("$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/go/bin")
export PATH
