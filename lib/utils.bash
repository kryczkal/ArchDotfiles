#!/usr/bin/env bash
# lib/utils.bash - Shared utility functions.
set -euo pipefail
IFS=$'\n\t'

print_message() {
  local message="$1"
  echo -e "\033[1;34m${message}\033[0m"
}

print_error_message_and_exit() {
  local message="$1"
  echo -e "\033[1;31m${message}\033[0m"
  exit 1
}

prompt_yes_no() {
  local prompt_message="$1"
  local answer
  while true; do
    read -p "${prompt_message} (y/N): " answer
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
    if [[ "$answer" =~ ^(y|yes)$ ]]; then
      return 0
    elif [[ "$answer" =~ ^(n|no)$ ]]; then
      return 1
    else
      echo "Invalid input. Please answer with 'y' or 'n'."
    fi
  done
}

append_line_to_file_if_not_exists() {
  local line="$1"
  local file="$2"
  if ! grep -Fqx "$line" "$file"; then
    echo "$line" >> "$file"
    print_message "Appended to $file: $line"
  else
    print_message "Already exists in $file: $line"
  fi
}

try_backup_file() {
  local file="$1"
  if [ -f "$file" ] && [ ! -f "${file}.bak" ]; then
    cp "$file" "${file}.bak"
    print_message "Backup created: ${file}.bak"
  fi
}
