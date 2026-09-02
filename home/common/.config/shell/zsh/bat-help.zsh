# Global aliases piping `cmd -h` / `cmd --help` through bat.
#
# HAZARD — read before moving these. Global aliases are parse-time text
# substitution: they expand anywhere on a line, in any code zsh parses AFTER
# they are defined. When these were defined in .zprofile (before oh-my-zsh
# loaded), `[[ -h "$file" ]]` inside omz's lib became a pipe inside [[ ]] —
# "diagnostics.zsh:134: parse error near `>&'" (2026-06-10). They must load
# LAST in .zshrc, after omz and p10k.
#
# Residual risk: a function autoloaded later whose file contains a bare `-h`
# word will still break. If a weird one-off parse error ever appears, suspect
# these aliases first.

alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
