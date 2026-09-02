# Environment variables — sourced by .zprofile (login) and .zshrc (interactive).
# Managed by stow (ArchDotfiles); edit here, not in rc files. Zsh-only setup.
# Must load before path.sh (ANDROID_HOME is used there).

export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"
export ANDROID_HOME=/opt/android-sdk
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=1280000
