# PATH — sourced by .zprofile (login) and .zshrc (interactive).
# typeset -U keeps entries unique, so double-sourcing never duplicates.
# Managed by stow (ArchDotfiles).

typeset -U path PATH
path+=(
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/.local/share/JetBrains/Toolbox/scripts"
  "$ANDROID_HOME/cmdline-tools/latest/bin"
  "$ANDROID_HOME/platform-tools"
)
export PATH
