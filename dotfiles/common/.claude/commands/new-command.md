Add a new Claude slash command or skill to the dotfiles.

Dotfiles location: ~/ArchDotfiles/dotfiles/common/.claude/

## Two types

**Command** — a simple slash command (like /commit, /explain).
- File: `.claude/commands/<name>.md`
- Plain markdown, no frontmatter.
- Use `$ARGUMENTS` as the placeholder for whatever the user passes after the command name.
- Keep it focused: one clear task, written as direct instructions to Claude.

**Skill** — a heavier, reusable workflow with metadata (like /refactor).
- Directory: `.claude/skills/<name>/`
- File: `.claude/skills/<name>/SKILL.md`
- Requires YAML frontmatter:
  ```
  ---
  name: <name>
  description: <one-line description shown in skill picker>
  argument-hint: [hint (optional)]
  effort: low | medium | max
  ---
  ```
- Body is detailed instructions, phased if the task is multi-step.

## What to do

1. Read $ARGUMENTS to understand what the user wants. If unclear, ask: name, type (command or skill), and what it should do.
2. Read 1-2 existing examples for the chosen type to match the style:
   - Commands: `~/.claude/commands/explain.md`, `~/.claude/commands/commit.md`
   - Skills: `~/.claude/skills/refactor/SKILL.md`
3. Write the new file. Be concrete and direct — Claude will execute these instructions literally.
4. Confirm the file was created and show the path.

If $ARGUMENTS is empty, ask the user what command or skill they want to create before doing anything.
