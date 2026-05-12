#!/usr/bin/env bash
# cwt — claude worktree lifecycle (generic, repo-agnostic)
#
# Usage:
#   cwt new <name> [branch]   create worktree at ../<repo>.<name>, open claude
#   cwt ls                    list worktrees in the current repo
#   cwt rm <name>             remove the worktree and its tmux window
#
# Conventions:
#   - Worktree path: sibling of current repo, named <repo>.<name>.
#   - Branch: defaults to <name>. Existing branch is reused; otherwise a new
#     branch is created from current HEAD.
#   - Tmux window name (when running inside tmux): <repo>.<name>.
#
# Per-repo hooks (opt-in, repo-tracked):
#   <worktree>/.cwt-hooks/post-new      run after worktree creation, before tmux
#   <worktree>/.cwt-hooks/pre-remove    run before worktree removal
#
# Hooks receive these env vars:
#   CWT_WORKTREE    absolute path to the worktree
#   CWT_NAME        short name passed to cwt (e.g. "find-tool")
#   CWT_BRANCH      branch name
#   CWT_REPO        basename of the main repo dir
#   CWT_REPO_ROOT   absolute path to the main repo
#
# Hook failures print a warning but do not abort the cwt operation.
#
# Spawned claude defaults to --dangerously-skip-permissions.
# Set CWT_SKIP_PERMS=0 to opt out (e.g. for a more cautious session).
#
# Claude Code session sharing: by default the worktree's per-project session
# dir (~/.claude/projects/<encoded-cwd>) is symlinked to the main worktree's
# session dir. All worktrees see + resume + fork each other's sessions.
# Set CWT_SHARE_SESSIONS=0 to opt out (each worktree gets its own dir).

set -euo pipefail

# Build the claude command with the permissions-skip flag by default.
claude_cmd="claude"
[[ "${CWT_SKIP_PERMS:-1}" != "0" ]] && claude_cmd="claude --dangerously-skip-permissions"

root()           { git rev-parse --show-toplevel 2>/dev/null || { echo "cwt: not in a git repo" >&2; exit 1; }; }
repo()           { basename "$(root)"; }
path_for()       { echo "$(dirname "$(root)")/$(repo).$1"; }
win_for()        { echo "$(repo).$1"; }
main_worktree()  { git worktree list | awk 'NR==1{print $1}'; }
encode_path()    { echo "${1//\//-}"; }
sessions_dir()   { echo "$HOME/.claude/projects/$(encode_path "$1")"; }

share_sessions() {
  [[ "${CWT_SHARE_SESSIONS:-1}" == "0" ]] && return 0
  local wt="$1"
  local main_dir wt_dir
  main_dir=$(sessions_dir "$(main_worktree)")
  wt_dir=$(sessions_dir "$wt")

  mkdir -p "$main_dir"

  if [[ -e "$wt_dir" || -L "$wt_dir" ]]; then
    if [[ -L "$wt_dir" ]] && [[ "$(readlink -f "$wt_dir")" == "$(readlink -f "$main_dir")" ]]; then
      return 0
    fi
    echo "cwt: $wt_dir exists and is not the expected symlink — session-sharing skipped" >&2
    return 0
  fi
  ln -s "$main_dir" "$wt_dir"
  echo "cwt: claude sessions symlinked → $main_dir"
}

unshare_sessions() {
  local wt="$1"
  local wt_dir
  wt_dir=$(sessions_dir "$wt")
  [[ -L "$wt_dir" ]] && rm "$wt_dir" || true
}

run_hook() {
  local event="$1" wt="$2" name="$3" branch="$4"
  local hook="$wt/.cwt-hooks/$event"
  [[ -x "$hook" ]] || return 0
  echo "cwt: running $event hook"
  CWT_WORKTREE="$wt" \
  CWT_NAME="$name" \
  CWT_BRANCH="$branch" \
  CWT_REPO="$(repo)" \
  CWT_REPO_ROOT="$(root)" \
  "$hook" || echo "cwt: $event hook exited $?" >&2
}

cmd="${1:-}"; shift || true

case "$cmd" in
  new)
    name="${1:-}"; [[ -z "$name" ]] && { echo "Usage: cwt new <name> [branch]" >&2; exit 1; }
    branch="${2:-$name}"
    wt=$(path_for "$name")

    if git show-ref --verify --quiet "refs/heads/$branch"; then
      git worktree add "$wt" "$branch"
      echo "cwt: reused existing branch '$branch'"
    else
      base=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD)
      git worktree add -b "$branch" "$wt"
      echo "cwt: created branch '$branch' from '$base'"
    fi

    share_sessions "$wt"
    run_hook post-new "$wt" "$name" "$branch"

    win=$(win_for "$name")
    if [[ -n "${TMUX:-}" ]]; then
      tmux new-window -n "$win" -c "$wt" "$claude_cmd"
    else
      printf '\nWorktree:  %s\nBranch:    %s\nOpen:      cd %s && %s\n' "$wt" "$branch" "$wt" "$claude_cmd"
    fi
    ;;

  ls|list)
    git worktree list
    ;;

  rm|remove)
    name="${1:-}"; [[ -z "$name" ]] && { echo "Usage: cwt rm <name>" >&2; exit 1; }
    wt=$(path_for "$name")
    [[ -d "$wt" ]] || { echo "cwt: no worktree at $wt" >&2; exit 1; }

    # Read branch before removal for the pre-remove hook
    branch=$(git -C "$wt" symbolic-ref --short HEAD 2>/dev/null || echo "")

    run_hook pre-remove "$wt" "$name" "$branch"
    unshare_sessions "$wt"

    git worktree remove "$wt"
    if [[ -n "${TMUX:-}" ]]; then
      tmux kill-window -t "$(win_for "$name")" 2>/dev/null || true
    fi
    echo "cwt: removed $wt"
    ;;

  ""|-h|--help|help)
    sed -n '2,/^$/p' "$0" | sed 's/^# \?//'
    ;;

  *)
    echo "cwt: unknown command '$cmd'" >&2
    echo "Run 'cwt help' for usage." >&2
    exit 1
    ;;
esac
