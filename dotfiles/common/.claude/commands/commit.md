Create a git commit for the current changes.

Instructions:
1. Run `git status` and `git diff` (staged + unstaged) in parallel with `git log --oneline -5` to understand what changed and the repo's commit message style.
2. Stage relevant files. Prefer specific filenames over `git add -A`. Never stage `.env`, secrets, or unrelated files.
3. Write a concise commit message:
   - First line: `type: short summary` (types: feat, fix, perf, refactor, docs, chore, test)
   - Optional body: explain *why*, not what — only if non-obvious
   - No co-author lines
4. Commit using a HEREDOC to preserve formatting.
5. Run `git status` after to confirm success.

If $ARGUMENTS is provided, use it as guidance for the commit message or scope.
