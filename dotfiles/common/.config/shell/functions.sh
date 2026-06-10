# Dotfiles helpers — sourced by .zshrc. Managed by stow (ArchDotfiles).

# Run git in the dotfiles repo from anywhere: dots status, dots diff, ...
dots() {
  git -C "$HOME/ArchDotfiles" "$@"
}

# One-shot sync: stage everything, commit with a generated summary, push.
dots-commit() {
  local -a changed
  changed=("${(@f)$(dots status --porcelain)}")
  if (( ${#changed} == 0 )) || [[ -z "${changed[1]}" ]]; then
    echo "dots: nothing to commit"
    return 0
  fi
  local summary
  summary=$(dots status --porcelain | awk '{print $NF}' | cut -d/ -f1-2 | sort -u | head -4 | paste -sd ',' - | sed 's/,/, /g')
  dots add -A &&
    dots commit -m "chore(sync): ${HOST}: ${#changed} file(s) — ${summary}" &&
    dots push
}
