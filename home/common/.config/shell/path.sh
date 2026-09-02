# path.sh: PATH entries only. Managed by stow (ArchDotfiles).
# Not here: exports (env.sh). Needs env.sh first. typeset -U dedupes, so
# double-sourcing is safe. An installer that appends PATH to .zshrc/.profile
# is drift: move the line here.

typeset -U path PATH
path+=(
  "$HOME/.local/bin"
  "$XDG_DATA_HOME/cargo/bin"
  "$XDG_DATA_HOME/go/bin"
  "$XDG_DATA_HOME/npm/bin"
  "$HOME/.local/share/JetBrains/Toolbox/scripts"
  "$ANDROID_HOME/cmdline-tools/latest/bin"
  "$ANDROID_HOME/platform-tools"
)
export PATH
