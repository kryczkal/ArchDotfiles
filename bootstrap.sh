#!/usr/bin/env bash
# bootstrap.sh — Single entry point for setting up an Arch Linux environment.
# Usage: ./bootstrap.sh [--profile <name>] [--list] [--dry-run] [--help]
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILES_DIR="$SCRIPT_DIR/profiles"
MODULES_DIR="$SCRIPT_DIR/modules"
LIB_DIR="$SCRIPT_DIR/lib"

source "$LIB_DIR/utils.bash"

# --- Usage ---
usage() {
  cat <<EOF
Usage: ./bootstrap.sh [OPTIONS]

Bootstrap your Arch Linux environment from a fresh install.

Options:
  --profile <name>   Use a predefined profile (see --list)
  --list             List available profiles
  --dry-run          Show what would be installed without running anything
  --help             Show this help message

Available profiles:
EOF
  for f in "$PROFILES_DIR"/*.conf; do
    [[ "$(basename "$f")" == "base.conf" ]] && continue
    name=$(basename "$f" .conf)
    desc=$(head -1 "$f" | sed 's/^# *//')
    printf "  %-22s %s\n" "$name" "$desc"
  done
}

# --- Profile Parser ---
# Resolves INCLUDE directives and returns a flat, ordered list of modules.
parse_profile() {
  local profile_file="$1"
  local -A seen=()

  _parse_file() {
    local file="$1"
    while IFS= read -r line; do
      # Strip comments and whitespace
      line=$(echo "$line" | sed 's/#.*//' | xargs)
      [[ -z "$line" ]] && continue

      # Handle INCLUDE directive
      if [[ "$line" =~ ^INCLUDE[[:space:]]+(.+)$ ]]; then
        local include_file="$PROFILES_DIR/${BASH_REMATCH[1]}"
        if [[ -f "$include_file" ]]; then
          _parse_file "$include_file"
        else
          print_error_message_and_exit "Profile includes '$include_file' which does not exist."
        fi
        continue
      fi

      # Deduplicate while preserving order
      if [[ -z "${seen[$line]:-}" ]]; then
        seen["$line"]=1
        echo "$line"
      fi
    done < "$file"
  }

  _parse_file "$profile_file"
}

# --- Module Runner ---
run_module() {
  local module_path="$1"
  local script="$MODULES_DIR/${module_path}.bash"

  if [[ ! -f "$script" ]]; then
    print_error_message_and_exit "Module script not found: $script"
  fi

  print_message "━━━ Running: $module_path ━━━"
  pushd "$(dirname "$script")" > /dev/null
  bash "$(basename "$script")"
  popd > /dev/null
  print_message "━━━ Done: $module_path ━━━"
  echo
}

# --- Interactive Profile Selection ---
select_profile() {
  local profiles=()
  for f in "$PROFILES_DIR"/*.conf; do
    local name
    name=$(basename "$f" .conf)
    [[ "$name" == "base" ]] && continue
    profiles+=("$name")
  done

  echo "Available profiles:" >&2
  for i in "${!profiles[@]}"; do
    local desc
    desc=$(head -1 "$PROFILES_DIR/${profiles[$i]}.conf" | sed 's/^# *//')
    printf "  [%d] %-22s %s\n" $((i + 1)) "${profiles[$i]}" "$desc" >&2
  done
  echo >&2

  local selection
  read -rp "Select a profile [1-${#profiles[@]}]: " selection
  if [[ "$selection" =~ ^[0-9]+$ ]] && (( selection >= 1 && selection <= ${#profiles[@]} )); then
    echo "${profiles[$((selection - 1))]}"
  else
    print_error_message_and_exit "Invalid selection: $selection"
  fi
}

# --- Main ---
main() {
  local profile=""
  local dry_run=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --profile)
        profile="$2"
        shift 2
        ;;
      --list)
        usage
        exit 0
        ;;
      --dry-run)
        dry_run=true
        shift
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        print_error_message_and_exit "Unknown option: $1. Use --help for usage."
        ;;
    esac
  done

  # Interactive profile selection if none specified
  if [[ -z "$profile" ]]; then
    echo
    print_message "Welcome to ArchDotfiles Bootstrap"
    echo
    profile=$(select_profile)
  fi

  local profile_file="$PROFILES_DIR/${profile}.conf"
  if [[ ! -f "$profile_file" ]]; then
    print_error_message_and_exit "Profile '$profile' not found. Use --list to see available profiles."
  fi

  print_message "Using profile: $profile"
  echo

  # Parse profile into ordered module list
  mapfile -t modules < <(parse_profile "$profile_file")

  if [[ ${#modules[@]} -eq 0 ]]; then
    print_error_message_and_exit "Profile '$profile' has no modules."
  fi

  # Show plan
  echo "The following modules will be installed in order:"
  for mod in "${modules[@]}"; do
    echo "  → $mod"
  done
  echo

  if $dry_run; then
    print_message "Dry run complete. No changes made."
    exit 0
  fi

  read -rp "Press Enter to start, or Ctrl+C to cancel. "
  echo

  # Export profile name so modules (e.g. stow) can read it
  export DOTFILES_PROFILE="$profile"

  # Execute modules
  local total=${#modules[@]}
  local current=0
  for mod in "${modules[@]}"; do
    current=$((current + 1))
    print_message "[$current/$total] $mod"
    run_module "$mod"
  done

  print_message "Bootstrap complete! You may want to reboot."
}

main "$@"
