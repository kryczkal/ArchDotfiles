# .zshenv: every zsh (login, interactive, scripts, ssh commands). Managed by
# stow (ArchDotfiles). Only `source` lines. env.sh + path.sh are idempotent,
# so .zshrc re-sourcing them for login shells (after /etc/profile) is harmless.
source ~/.config/shell/env.sh
source ~/.config/shell/path.sh
